# Fitnation Backend API Documentation

## Overview

The Fitnation Backend is a comprehensive fitness application API built with FastAPI that provides functionality for workout management, social networking, nutrition tracking, e-commerce, challenges, and real-time chat. This documentation covers all available endpoints, their purposes, request/response formats, and authentication requirements.

## Base Information

- **API Version**: v0.1.0
- **Base URL**: `/api/v1`
- **Framework**: FastAPI
- **Authentication**: OAuth2 Bearer Token
- **WebSocket Endpoint**: `/ws/chat`

## Authentication System

The API uses OAuth2 Bearer token authentication with JWT tokens. The authentication system supports:

- **JWT Access Tokens**: Short-lived tokens for API access
- **Refresh Tokens**: Long-lived tokens for token renewal
- **Google OAuth**: OAuth integration with Google Sign-In
- **Password Reset**: Email-based password reset functionality
- **Firebase Integration**: Used for additional authentication features

### Authentication Flow

1. **Register/Login**: Get access and refresh tokens
2. **API Requests**: Include `Authorization: Bearer <access_token>` header
3. **Token Refresh**: Use refresh token to get new access token when expired
4. **Logout**: Invalidate refresh token

### Security Headers

Most endpoints require the `Authorization` header:
```
Authorization: Bearer <your_access_token>
```

---

## API Endpoints by Category

## 1. Authentication (`/api/v1/auth`)

### POST `/api/v1/auth/register`
**Purpose**: Register a new user account

**Request Body** (`UserCreate`):
```json
{
  "username": "string",
  "email": "user@example.com",
  "password": "string",
  "full_name": "string"
}
```

**Response** (`UserPublic`):
```json
{
  "id": "uuid",
  "username": "string",
  "email": "user@example.com",
  "full_name": "string",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

### POST `/api/v1/auth/login`
**Purpose**: Login with username/email and password

**Request Body** (`LoginRequest`):
```json
{
  "email": "user@example.com",
  "password": "string"
}
```

**Response** (`Token`):
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "refresh_token_string"
}
```

### POST `/api/v1/auth/refresh`
**Purpose**: Refresh access token using refresh token

**Query Parameters**:
- `refresh_token` (required): The refresh token

**Response** (`Token`): New access and refresh tokens

### POST `/api/v1/auth/logout`
**Purpose**: Logout and invalidate refresh token

**Query Parameters**:
- `refresh_token` (required): The refresh token to invalidate

### POST `/api/v1/auth/forgot-password`
**Purpose**: Request password reset email

**Request Body** (`PasswordResetRequest`):
```json
{
  "email": "user@example.com"
}
```

### POST `/api/v1/auth/reset-password`
**Purpose**: Reset password using reset token

**Request Body** (`PasswordReset`):
```json
{
  "token": "reset_token",
  "new_password": "new_password"
}
```

### POST `/api/v1/auth/google-login`
**Purpose**: Authenticate using Google OAuth token

**Request Body** (`GoogleOAuthToken`):
```json
{
  "token": "google_oauth_token"
}
```

---

## 2. User Management (`/api/v1/users`)

### GET `/api/v1/users/me`
**Purpose**: Get current user's profile information
**Authentication**: Required

**Response** (`UserPublic`):
```json
{
  "id": "uuid",
  "username": "string",
  "email": "user@example.com",
  "full_name": "string",
  "profile_picture_url": "https://...",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

### GET `/api/v1/users/{user_id}`
**Purpose**: Get user profile by ID
**Authentication**: Optional

**Path Parameters**:
- `user_id`: User ID string

### POST `/api/v1/users/upload-pfp`
**Purpose**: Upload profile picture
**Authentication**: Required

**Request Body**: Multipart form data with file field

---

## 3. Workout Plans (`/api/v1/workouts/plans`)

### GET `/api/v1/workouts/plans/history`
**Purpose**: Retrieve user's workout plans with pagination
**Authentication**: Required

**Query Parameters**:
- `skip` (default: 0): Number of items to skip
- `limit` (default: 20, max: 100): Number of items to return

**Response**: Array of `WorkoutPublic` objects

### POST `/api/v1/workouts/plans/`
**Purpose**: Create a new workout plan
**Authentication**: Required

**Request Body** (`WorkoutCreate`):
```json
{
  "name": "Push Day Workout",
  "description": "Chest, shoulders, and triceps workout",
  "planned_exercises": [
    {
      "exercise_id": "uuid",
      "planned_sets": [
        {
          "set_number": 1,
          "planned_reps": 10,
          "planned_weight": 135.0,
          "planned_duration": 30,
          "rest_duration": 90
        }
      ],
      "notes": "Focus on form"
    }
  ],
  "scheduled_date": "2024-01-01T10:00:00Z"
}
```

### GET `/api/v1/workouts/plans/{workout_id}`
**Purpose**: Get specific workout plan details
**Authentication**: Required

**Path Parameters**:
- `workout_id`: UUID of the workout plan

---

## 4. Workout Sessions (`/api/v1/workouts`)

### POST `/api/v1/workouts/session`
**Purpose**: Log a completed workout session
**Authentication**: Required

**Request Body** (`CompletedWorkoutCreate`):
```json
{
  "name": "Morning Push Workout",
  "description": "Completed chest and triceps workout",
  "started_at": "2024-01-01T10:00:00Z",
  "ended_at": "2024-01-01T11:30:00Z",
  "completed_exercises": [
    {
      "exercise_id": "uuid",
      "completed_sets": [
        {
          "set_number": 1,
          "reps": 10,
          "weight": 135.0,
          "duration": 30,
          "rest_duration": 90
        }
      ],
      "notes": "Felt strong today"
    }
  ]
}
```

### GET `/api/v1/workouts/history`
**Purpose**: Get user's workout history
**Authentication**: Required

**Query Parameters**:
- `skip`, `limit`: Pagination parameters

### GET `/api/v1/workouts/session/{session_id}`
**Purpose**: Get specific workout session details
**Authentication**: Required

---

## 5. Workout Templates (`/api/v1/workout-templates`)

### GET `/api/v1/workout-templates/`
**Purpose**: Browse workout templates with filtering
**Authentication**: Optional

**Query Parameters**:
- `author`: Filter by author name
- `difficulty_level`: Filter by difficulty (Beginner, Intermediate, Advanced)
- `muscle_groups`: Comma-separated muscle groups
- `tags`: Comma-separated tags
- `search`: Search in names and descriptions
- `skip`, `limit`: Pagination

**Response** (`WorkoutTemplateListResponse`):
```json
{
  "templates": [
    {
      "id": "uuid",
      "name": "5x5 Strength Program",
      "description": "Classic strength building program",
      "author": "Ronnie Coleman",
      "difficulty_level": "Intermediate",
      "estimated_duration": 60,
      "exercise_count": 5,
      "muscle_groups": ["Chest", "Back", "Legs"],
      "tags": ["Strength", "Compound"]
    }
  ],
  "total": 50,
  "page": 1,
  "pages": 3
}
```

### GET `/api/v1/workout-templates/{template_id}`
**Purpose**: Get detailed template information

### POST `/api/v1/workout-templates/{template_id}/import`
**Purpose**: Import template to personal workout plans
**Authentication**: Required

**Request Body** (`ImportTemplateRequest`):
```json
{
  "custom_name": "My Custom 5x5 Program"
}
```

### GET `/api/v1/workout-templates/authors/list`
**Purpose**: Get list of template authors

### GET `/api/v1/workout-templates/tags/list`
**Purpose**: Get available tags

### GET `/api/v1/workout-templates/muscle-groups/list`
**Purpose**: Get muscle group options

---

## 6. Exercise Library (`/api/v1/exercise-library`)

### GET `/api/v1/exercise-library/library`
**Purpose**: Advanced exercise search with filtering
**Authentication**: Optional

**Query Parameters**:
- `q`: Search query
- `compound`: Filter compound movements (boolean)
- `unilateral`: Filter unilateral exercises (boolean)
- `min_popularity`: Minimum popularity score (0-5)
- `page`, `page_size`: Pagination
- `sort_by`: Sort field (default: popularity)
- `sort_order`: asc/desc

**Request Body** (Optional filters):
```json
{
  "categories": ["Strength", "Cardio"],
  "muscle_groups": ["Chest", "Triceps"],
  "equipment": ["Barbell", "Dumbbell"],
  "difficulty": [1, 2, 3]
}
```

### GET `/api/v1/exercise-library/library/{exercise_id}`
**Purpose**: Get detailed exercise information

**Response** (`ExerciseLibraryResponse`):
```json
{
  "id": "uuid",
  "name": "Bench Press",
  "description": "Classic chest exercise",
  "instructions": ["Lie on bench", "Lower bar to chest", "Press up"],
  "muscle_groups": {
    "primary": ["Chest"],
    "secondary": ["Triceps", "Shoulders"]
  },
  "equipment": ["Barbell", "Bench"],
  "difficulty": 2,
  "popularity": 4.8,
  "images": ["url1", "url2"],
  "video_url": "https://...",
  "variations": ["Incline Bench Press", "Dumbbell Press"]
}
```

### GET `/api/v1/exercise-library/quick-select`
**Purpose**: Get exercises optimized for workout creation UI

**Query Parameters**:
- `search`: Search term
- `category`: Filter by category
- `muscle_group`: Filter by muscle group
- `equipment`: Filter by equipment
- `limit`: Number of results (max: 100)

### GET `/api/v1/exercise-library/categories`
**Purpose**: Get exercise categories

### GET `/api/v1/exercise-library/muscle-groups`
**Purpose**: Get muscle groups with optional type filter

### GET `/api/v1/exercise-library/equipment`
**Purpose**: Get equipment types

### GET `/api/v1/exercise-library/popular`
**Purpose**: Get most popular exercises

### GET `/api/v1/exercise-library/similar/{exercise_id}`
**Purpose**: Get exercises similar to specified exercise

### GET `/api/v1/exercise-library/variations/{exercise_id}`
**Purpose**: Get exercise variations

---

## 7. Nutrition (`/api/v1/nutrition`)

### Food Logs

#### POST `/api/v1/nutrition/food_logs`
**Purpose**: Log food consumption
**Authentication**: Required

**Request Body** (`FoodLogCreate`):
```json
{
  "food_item_id": "uuid",
  "quantity": 100.0,
  "unit": "grams",
  "meal_type": "breakfast",
  "consumed_at": "2024-01-01T08:00:00Z",
  "notes": "Post-workout meal"
}
```

#### GET `/api/v1/nutrition/food_logs`
**Purpose**: Get user's food logs
**Authentication**: Required

#### GET/PUT/DELETE `/api/v1/nutrition/food_logs/{food_log_id}`
**Purpose**: Manage specific food log entries
**Authentication**: Required

### Health Logs

#### POST/GET `/api/v1/nutrition/health_logs`
**Purpose**: Log and retrieve health metrics (weight, body fat, etc.)
**Authentication**: Required

**Request Body** (`HealthLogCreate`):
```json
{
  "metric_type": "weight",
  "value": 70.5,
  "unit": "kg",
  "recorded_at": "2024-01-01T07:00:00Z",
  "notes": "Morning weight"
}
```

### Diet Recommendations

#### GET `/api/v1/nutrition/diet_recommendations`
**Purpose**: Get personalized diet recommendations
**Authentication**: Required

---

## 8. Meal Plans (`/api/v1/meal_plans`)

### POST `/api/v1/meal_plans/`
**Purpose**: Create a new meal plan
**Authentication**: Required

**Request Body** (`MealPlanCreate`):
```json
{
  "name": "High Protein Meal Plan",
  "description": "Muscle building focused meal plan",
  "target_calories": 2500,
  "target_protein": 150,
  "target_carbs": 250,
  "target_fat": 100,
  "planned_meals": [
    {
      "meal_type": "breakfast",
      "planned_time": "07:00:00",
      "food_items": [
        {
          "food_item_id": "uuid",
          "quantity": 100,
          "unit": "grams"
        }
      ]
    }
  ],
  "start_date": "2024-01-01",
  "end_date": "2024-01-07"
}
```

### GET `/api/v1/meal_plans/history`
**Purpose**: Get user's meal plan history
**Authentication**: Required

### GET `/api/v1/meal_plans/{meal_plan_id}`
**Purpose**: Get specific meal plan details
**Authentication**: Required

---

## 9. Meals (`/api/v1/meals`)

### POST `/api/v1/meals/`
**Purpose**: Create a meal entry
**Authentication**: Required

### GET/PUT/DELETE `/api/v1/meals/{meal_id}`
**Purpose**: Manage individual meal entries
**Authentication**: Required

### GET `/api/v1/meals/users/me/`
**Purpose**: Get user's meal entries
**Authentication**: Required

---

## 10. Shop (`/api/v1/shop`)

### Categories

#### GET/POST `/api/v1/shop/categories`
**Purpose**: Manage shop categories (POST requires admin)

### Products

#### GET `/api/v1/shop/products`
**Purpose**: Browse products with filtering

**Query Parameters**:
- `category_id`: Filter by category
- `search`: Search products
- `is_featured`: Filter featured products
- `min_price`, `max_price`: Price range
- `skip`, `limit`: Pagination

#### POST `/api/v1/shop/products`
**Purpose**: Create product (admin only)
**Authentication**: Required (Admin)

#### GET `/api/v1/shop/products/featured`
**Purpose**: Get featured products

#### GET/PUT `/api/v1/shop/products/{product_id}`
**Purpose**: Get/update specific product

### Cart Management

#### GET `/api/v1/shop/cart`
**Purpose**: Get user's shopping cart
**Authentication**: Required

#### POST `/api/v1/shop/cart/items`
**Purpose**: Add item to cart
**Authentication**: Required

**Request Body** (`CartItemCreate`):
```json
{
  "product_id": 1,
  "quantity": 2
}
```

#### PUT/DELETE `/api/v1/shop/cart/items/{item_id}`
**Purpose**: Update/remove cart item
**Authentication**: Required

#### DELETE `/api/v1/shop/cart/clear`
**Purpose**: Clear entire cart
**Authentication**: Required

### Orders

#### POST `/api/v1/shop/orders`
**Purpose**: Create order from cart
**Authentication**: Required

**Request Body** (`OrderCreate`):
```json
{
  "shipping_address": "123 Main St, City, State 12345",
  "payment_method": "credit_card"
}
```

#### GET `/api/v1/shop/orders`
**Purpose**: Get user's orders
**Authentication**: Required

#### GET `/api/v1/shop/orders/{order_id}`
**Purpose**: Get specific order details
**Authentication**: Required

### Reviews

#### POST/GET `/api/v1/shop/products/{product_id}/reviews`
**Purpose**: Create/get product reviews
**Authentication**: Required (for POST)

---

## 11. Challenges (`/api/v1/challenges`)

### GET `/api/v1/challenges`
**Purpose**: Browse challenges with filtering
**Authentication**: Required

**Query Parameters**:
- `activity_type`: Filter by activity (run, ride, swim, walk, hike, workout)
- `status`: Filter by status (active, upcoming, completed)
- `search`: Search in title, description, brand
- `skip`, `limit`: Pagination

### POST `/api/v1/challenges`
**Purpose**: Create new challenge
**Authentication**: Required

**Request Body** (`ChallengeCreate`):
```json
{
  "title": "30-Day Push-up Challenge",
  "description": "Build upper body strength with daily push-ups",
  "activity_type": "workout",
  "target_value": 1000,
  "target_unit": "reps",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "rules": "Do push-ups daily, log progress",
  "rewards": "Badge + 100 points",
  "is_public": true,
  "max_participants": 100
}
```

### GET/DELETE `/api/v1/challenges/{challenge_id}`
**Purpose**: Get/delete specific challenge
**Authentication**: Required

### POST `/api/v1/challenges/{challenge_id}/join`
**Purpose**: Join a challenge
**Authentication**: Required

### POST `/api/v1/challenges/{challenge_id}/leave`
**Purpose**: Leave a challenge
**Authentication**: Required

### PUT `/api/v1/challenges/{challenge_id}/progress`
**Purpose**: Update challenge progress
**Authentication**: Required

**Request Body** (`UpdateProgressRequest`):
```json
{
  "progress_value": 50,
  "notes": "Completed 50 push-ups today"
}
```

### GET `/api/v1/challenges/{challenge_id}/participants`
**Purpose**: Get challenge participants and leaderboard
**Authentication**: Required

### GET `/api/v1/my-challenges`
**Purpose**: Get challenges user has joined
**Authentication**: Required

### GET `/api/v1/my-created-challenges`
**Purpose**: Get challenges created by user
**Authentication**: Required

### GET `/api/v1/challenge-stats`
**Purpose**: Get user's challenge statistics
**Authentication**: Required

---

## 12. Chat System (`/api/v1/chat`)

### Rooms

#### GET `/api/v1/chat/rooms`
**Purpose**: Get user's chat rooms
**Authentication**: Required

#### POST `/api/v1/chat/rooms/direct`
**Purpose**: Create or get direct chat with another user
**Authentication**: Required

**Query Parameters**:
- `other_user_id`: UUID of the other user

#### POST `/api/v1/chat/rooms/group`
**Purpose**: Create group chat
**Authentication**: Required

**Request Body** (`ChatRoomCreate`):
```json
{
  "name": "Workout Buddies",
  "description": "Chat for workout partners",
  "participant_ids": ["uuid1", "uuid2", "uuid3"],
  "room_type": "group"
}
```

#### GET/DELETE `/api/v1/chat/rooms/{room_id}`
**Purpose**: Get room details or leave/delete room
**Authentication**: Required

### Messages

#### GET `/api/v1/chat/rooms/{room_id}/messages`
**Purpose**: Get room messages with pagination
**Authentication**: Required

**Query Parameters**:
- `before_message_id`: For pagination
- `limit`: Number of messages (max: 100)

#### POST `/api/v1/chat/rooms/{room_id}/messages`
**Purpose**: Send message to room
**Authentication**: Required

**Request Body** (`MessageCreate`):
```json
{
  "content": "Hey everyone! Ready for today's workout?",
  "message_type": "text",
  "reply_to_id": "uuid_of_message_being_replied_to"
}
```

#### PUT `/api/v1/chat/rooms/{room_id}/messages/read`
**Purpose**: Mark messages as read
**Authentication**: Required

#### GET `/api/v1/chat/messages/{message_id}`
**Purpose**: Get specific message details
**Authentication**: Required

### Room Management

#### PUT `/api/v1/chat/rooms/{room_id}/participants`
**Purpose**: Manage room participants (add/remove/promote/demote)
**Authentication**: Required

**Query Parameters**:
- `action`: add, remove, promote, demote

**Request Body**:
```json
["user_id_1", "user_id_2"]
```

#### PUT `/api/v1/chat/rooms/{room_id}/settings`
**Purpose**: Update user's room settings
**Authentication**: Required

**Query Parameters**:
- `is_muted`: boolean
- `is_pinned`: boolean

---

## 13. Friends System (`/api/v1/friends`)

### GET `/api/v1/friends/`
**Purpose**: Get user's friends list
**Authentication**: Required

**Query Parameters**:
- `search`: Search friends by name
- `online_only`: Show only online friends
- `skip`, `limit`: Pagination

### Friend Requests

#### GET `/api/v1/friends/requests`
**Purpose**: Get friend requests
**Authentication**: Required

**Query Parameters**:
- `request_type`: received, sent, all
- `status_filter`: pending, accepted, rejected, blocked
- `skip`, `limit`: Pagination

#### POST `/api/v1/friends/requests`
**Purpose**: Send friend request
**Authentication**: Required

**Query Parameters**:
- `receiver_id`: UUID of user to send request to
- `message`: Optional message

#### PUT/GET/DELETE `/api/v1/friends/requests/{request_id}`
**Purpose**: Respond to/get/cancel friend request
**Authentication**: Required

### Friend Management

#### DELETE/GET `/api/v1/friends/{friend_id}`
**Purpose**: Remove friend or get friend details
**Authentication**: Required

#### GET `/api/v1/friends/search`
**Purpose**: Search for users to add as friends
**Authentication**: Required

**Query Parameters**:
- `q`: Search query (min 2 chars)
- `exclude_friends`: Exclude current friends
- `limit`: Max results (max: 50)

#### POST/DELETE `/api/v1/friends/block/{user_id}`
**Purpose**: Block/unblock user
**Authentication**: Required

#### GET `/api/v1/friends/blocked`
**Purpose**: Get blocked users list
**Authentication**: Required

#### GET `/api/v1/friends/{friend_id}/mutual`
**Purpose**: Get mutual friends with another user
**Authentication**: Required

---

## 14. Posts/Social (`/api/v1/posts`)

### POST `/api/v1/posts/`
**Purpose**: Create new social post
**Authentication**: Required

**Request Body** (`PostCreate`):
```json
{
  "content": "Just finished an amazing workout! 💪",
  "post_type": "workout",
  "post_data": {
    "workout_id": "uuid",
    "exercises_completed": 5,
    "duration_minutes": 90
  },
  "visibility": "public",
  "tags": ["fitness", "motivation"],
  "media_urls": ["https://image1.jpg", "https://video1.mp4"]
}
```

### GET `/api/v1/posts/`
**Purpose**: Get posts with filtering
**Authentication**: Required

**Query Parameters**:
- `user_id`: Filter by specific user
- `post_type`: Filter by post type (workout, challenge, general)
- `skip`, `limit`: Pagination

### GET/PUT/DELETE `/api/v1/posts/{post_id}`
**Purpose**: Manage specific post
**Authentication**: Required (ownership required for PUT/DELETE)

### GET `/api/v1/posts/feed/public`
**Purpose**: Get public feed (no auth required)

### GET/POST `/api/v1/posts/{post_id}/comments`
**Purpose**: Get/add comments on posts
**Authentication**: Required (for POST)

---

## 15. WebSocket Chat (`/ws/chat`)

### Connection
**Purpose**: Real-time chat functionality

**Connection URL**: `ws://domain/ws/chat`

**Authentication**: Pass token as query parameter or in headers

**Message Format**:
```json
{
  "type": "message",
  "room_id": "uuid",
  "content": "Hello everyone!",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

**Event Types**:
- `message`: New message
- `typing`: User typing indicator
- `user_joined`: User joined room
- `user_left`: User left room
- `message_read`: Message read receipt

---

## Error Handling

The API uses standard HTTP status codes:

- `200`: Success
- `201`: Created
- `204`: No Content (successful deletion)
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `422`: Validation Error
- `500`: Internal Server Error

### Error Response Format

```json
{
  "detail": "Error message description",
  "type": "validation_error",
  "errors": [
    {
      "loc": ["field_name"],
      "msg": "Field is required",
      "type": "missing"
    }
  ]
}
```

---

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **Authentication endpoints**: 5 requests per minute
- **General endpoints**: 100 requests per minute
- **WebSocket connections**: 1 connection per user per room

---

## Data Models

### Key Data Types

- **UUID**: String format UUID for entity IDs
- **DateTime**: ISO 8601 format (`2024-01-01T12:00:00Z`)
- **Pagination**: Most list endpoints support `skip` and `limit` parameters
- **Enums**: 
  - `ActivityTypeEnum`: run, ride, swim, walk, hike, workout
  - `ChallengeStatusEnum`: active, upcoming, completed
  - `PostType`: workout, challenge, general
  - `MessageType`: text, image, video, audio

### Common Response Fields

Most entities include:
- `id`: Unique identifier
- `created_at`: Creation timestamp
- `updated_at`: Last modification timestamp
- `user_id`: Associated user (where applicable)

---

## File Upload

File uploads use multipart/form-data:

```
Content-Type: multipart/form-data

file: [binary data]
```

Supported file types:
- **Images**: JPG, PNG, GIF (max 10MB)
- **Videos**: MP4, MOV (max 100MB)
- **Profile Pictures**: JPG, PNG (max 5MB)

---

## Pagination

List endpoints use offset-based pagination:

**Request Parameters**:
- `skip`: Number of items to skip (default: 0)
- `limit`: Number of items to return (default varies, max usually 100)

**Response Format**:
```json
{
  "items": [...],
  "total": 150,
  "page": 1,
  "pages": 8,
  "has_next": true,
  "has_prev": false
}
```

---

## Filtering and Search

Many endpoints support filtering:

**Query Parameters**:
- Text search: `search=term` or `q=term`
- Exact filters: `category=fitness`
- Range filters: `min_price=10&max_price=50`
- Boolean filters: `is_featured=true`
- Date ranges: `start_date=2024-01-01&end_date=2024-01-31`

---

## WebSocket Events

Real-time updates are sent via WebSocket for:

- **Chat messages**: New messages in subscribed rooms
- **Friend status**: Online/offline status changes
- **Challenge updates**: Progress updates from friends
- **Notifications**: System notifications

---

## Development Notes

### Database
- **PostgreSQL**: Primary database
- **Alembic**: Database migrations
- **SQLAlchemy**: ORM

### External Services
- **Cloudinary**: Image/video storage
- **Firebase**: Authentication and push notifications
- **Email Service**: Password reset and notifications

### Security Features
- **JWT tokens**: Secure authentication
- **Password hashing**: bcrypt
- **CORS**: Configured for allowed origins
- **Input validation**: Pydantic schemas
- **SQL injection protection**: SQLAlchemy ORM

---

This documentation covers all major API functionality. For detailed schema definitions and additional examples, refer to the OpenAPI specification at `/docs` when the server is running.