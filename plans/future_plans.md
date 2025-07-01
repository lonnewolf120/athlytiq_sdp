# PLAN.md

## Introduction
This document outlines the plan for developing a social media platform tailored for gym enthusiasts. The platform enables users to connect with gym buddies, share workouts, find nearby users, and interact with trainers and influencers. It incorporates robust data handling, location-based services, and monetization options, drawing inspiration from platforms like Instagram and Facebook.

## Core Features
The platform will include the following core features:
- **Workouts**: Create, view, and manage workout plans; track completed workouts with detailed stats; real-time tracking with timers and progress saving.
- **Community**: View community feed, join groups, create posts.
- **Feed**: Upload posts and stories with visibility options (`public`, `private`, `gym_buddies`, `buddies`); follow/unfollow users; add gym buddies or buddies.
- **Interaction**: Interact with others based on follow or buddy relationships.
- **Profile**: Manage personal details, view progress, customize settings.
- **Authentication**: Secure login/signup with email verification and password management.
- **Data Management**: Offline support with local storage and cloud sync.
- **Navigation**: Bottom navigation for easy access to main sections.

## Gym Buddies Feature
### Finding People Nearby
- **Geolocation Data**: Capture users' latitude and longitude using device GPS (with permission) or manual input.
- **Database Schema**: Add a `user_locations` table to store location data.
  ```sql
  CREATE TABLE user_locations (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      location GEOGRAPHY(POINT, 4326),
      updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
  );
  CREATE INDEX idx_user_locations_location ON user_locations USING GIST (location);
  ```
- **Geospatial Queries**: Use PostGIS to find nearby users within a specified distance.
  ```sql
  SELECT u.id, u.username, p.display_name
  FROM users u
  JOIN profiles p ON u.id = p.user_id
  JOIN user_locations ul ON u.id = ul.user_id
  WHERE ST_DWithin(
      ul.location,
      ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326),
      5000  -- 5 km in meters
  )
  AND u.id != :current_user_id;
  ```
- **Privacy**: Allow users to control who sees their location and provide options to disable sharing.

### Gym Buddies Relationships
- **Database Schema**: Add a `gym_buddies` table to manage relationships.
  ```sql
  CREATE TABLE gym_buddies (
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      buddy_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      relation
      created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
      PRIMARY KEY (user_id, buddy_id)
  );
  ```
- **Management**: Implement mutual relationships where adding a buddy inserts two rows (e.g., `(A, B)` and `(B, A)`).

### Visibility and Interaction
- **Visibility Settings**: Add a `visibility` column to `posts` and `stories`.
  ```sql
  CREATE TYPE post_visibility_enum AS ENUM ('public', 'private', 'gym_buddies', 'buddies');
  ALTER TABLE posts ADD COLUMN visibility post_visibility_enum NOT NULL DEFAULT 'public';
  ALTER TABLE stories ADD COLUMN visibility post_visibility_enum NOT NULL DEFAULT 'public';
  ```
- **Feed Query**: Filter posts and stories based on visibility and relationships.
  ```sql
  SELECT p.*
  FROM posts p
  LEFT JOIN gym_buddies gb ON p.user_id = gb.user_id AND gb.buddy_id = :current_user_id
  WHERE 
      (p.visibility = 'public') OR
      (p.visibility = 'private' AND p.user_id = :current_user_id) OR
      (p.visibility = 'gym_buddies' AND gb.buddy_id IS NOT NULL)
  ORDER BY p.created_at DESC;
  ```
- **Interaction Rules**: Check relationships before allowing comments or likes.
  ```sql
  SELECT EXISTS (
      SELECT 1 FROM gym_buddies WHERE (user_id = :poster_id AND buddy_id = :current_user_id)
  ) OR EXISTS (
      SELECT 1 FROM user_relationships WHERE (user_id = :poster_id AND related_user_id = :current_user_id)
  );
  ```

## Trainer and Influencer Functionality
### Training Plans
- **Database Schema**: Add tables for training plans and user access.
  ```sql
  CREATE TYPE plan_visibility_enum AS ENUM ('public', 'paid');
  CREATE TABLE training_plans (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      trainer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      title VARCHAR(255) NOT NULL,
      description TEXT,
      price DECIMAL(10, 2),
      visibility plan_visibility_enum NOT NULL DEFAULT 'public',
      created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
  );
  CREATE TABLE training_plan_workouts (
      training_plan_id UUID NOT NULL REFERENCES training_plans(id) ON DELETE CASCADE,
      workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
      order_num INTEGER NOT NULL,
      PRIMARY KEY (training_plan_id, workout_id)
  );
  CREATE TABLE user_training_plans (
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      training_plan_id UUID NOT NULL REFERENCES training_plans(id) ON DELETE CASCADE,
      purchased_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
      PRIMARY KEY (user_id, training_plan_id)
  );
  ```
- **Uploading Plans**: Trainers create plans with workouts, set visibility (`public` or `paid`), and price.
- **Monetization**: Integrate payment gateways (e.g., Stripe) for purchasing paid plans.

### Public Profiles
- **Visibility**: Add `is_public` to `profiles` to allow sharing.
  ```sql
  ALTER TABLE profiles ADD COLUMN is_public BOOLEAN NOT NULL DEFAULT FALSE;
  ```
- **Display**: Query public profiles to show followed plans and activities.
  ```sql
  SELECT p.display_name, tp.title AS training_plan, cw.workout_name
  FROM profiles p
  LEFT JOIN user_training_plans utp ON p.user_id = utp.user_id
  LEFT JOIN training_plans tp ON utp.training_plan_id = tp.id
  LEFT JOIN completed_workouts cw ON p.user_id = cw.user_id
  WHERE p.user_id = :user_id AND p.is_public = TRUE;
  ```

### Direct Training
- **Booking System**: Add a `bookings` table for one-on-one sessions.
  ```sql
  CREATE TABLE bookings (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      trainer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      session_time TIMESTAMP WITH TIME ZONE NOT NULL,
      price DECIMAL(10, 2),
      status VARCHAR(50) NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
  );
  ```
- **Integration**: Use calendar APIs (e.g., Google Calendar) and payment systems for scheduling and fees.

## Additional Recommended Features
- **Group Challenges**: Create and join challenges with leaderboards.
- **Progress Tracking**: Visualize and share workout statistics.
- **Gym Check-ins**: Allow users to check in at gyms and share with buddies.
- **Gym Finder**: Locate nearby gyms with reviews and ratings.
- **Class Bookings**: Book gym classes or trainer sessions.
- **Wearable Integration**: Sync with fitness trackers for accurate data.
- **Content Tools**: Provide templates for trainers to create workout videos or reels.
- **Forums**: Discussion boards for community support.
- **Badges and Rewards**: Award badges for milestones to gamify the experience.

## Data Handling and Scalability
- **Database Choices**: Use PostgreSQL with PostGIS for geospatial data; consider NoSQL (e.g., MongoDB) for unstructured data like posts.
- **Optimization**: Add indexes (e.g., geospatial indexes) and ensure data consistency with transactions.
- **Scalability**: Implement caching (e.g., Redis), asynchronous tasks (e.g., RabbitMQ), and cloud services (e.g., AWS) for hosting and load balancing.
- **Security**: Use HTTPS, encrypt sensitive data (e.g., passwords with bcrypt), validate inputs, and comply with privacy laws (e.g., GDPR).

## Implementation Steps
1. **Set Up Geospatial Support**: Enable PostGIS and create the `user_locations` table.
2. **Implement Location Features**: Develop APIs to capture and query location data for finding nearby users.
3. **Add Relationship Tables**: Create the `gym_buddies` table to manage relationships.
4. **Update Post and Story Tables**: Add `visibility` columns and adjust feed queries accordingly.
5. **Develop Trainer Features**: Implement training plan tables, monetization logic, and public profile settings.
6. **Integrate Additional Features**: Prioritize based on user feedback and available resources.
7. **Optimize and Scale**: Add caching, queues, and monitor performance as the platform grows.

## Conclusion
This plan provides a comprehensive roadmap for building a feature-rich social media platform for gym enthusiasts. By following these steps, the platform can offer a seamless experience for users to connect, share, and achieve their fitness goals while providing opportunities for trainers and influencers to monetize their expertise.