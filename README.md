# Pulse

A cross-platform fitness and community app with a modern Flutter frontend and a FastAPI backend, using Supabase for authentication and data storage.

---

## Table of Contents

- Overview
- Project Structure
- Flutter App (fitnation)
- Backend API (backend)
- Database & Models
- Setup & Development
- License

---

## Overview

Pulse is a fitness and social platform featuring:
- Personalized workout plans and tracking
- Nutrition logging and meal planning
- Community groups, posts, and challenges
- User profiles with health, fitness, and preference data
- Secure authentication and cloud sync

---

## Project Structure

```
pulse_sdp/
│
├── fitnation/      # Flutter mobile app
│
├── backend/        # FastAPI backend (Python)
│
└── README.md       # Project documentation
```

---

## Flutter App (fitnation)

### Features

- **Workouts:** Create, view, and track workout plans, history, and stats.
- **Nutrition:** Log meals, track macros, and generate meal plans.
- **Community:** Join groups, post updates, and participate in challenges.
- **Profile:** Manage personal info, health data (height, weight, gender, preferences, health conditions, injuries), and app settings.
- **Authentication:** Secure login/signup, password reset, and email verification.
- **Theming:** Light/dark/system themes, custom splash screen, and branding.
- **Offline Support:** Local data storage with sqflite, cloud sync with Supabase.

### Setup

1. `cd fitnation`
2. Use Flutter 3.29.1+ and Dart 3+
3. `flutter pub get`
4. Configure your Supabase project and update `.env`
5. Run with `flutter run`

### App Branding

-- **App Name:** Pulse
- **Logo:** `assets/logos/logo.png`
- **Splash Screen:** Displays the app logo on launch

---

## Backend API (backend)

### Features

- **User Auth:** Signup, login, JWT tokens, password reset, OTP verification
- **Profile Management:** Update and fetch user profile, including health and fitness data
- **API Docs:** Swagger UI (`/docs`), ReDoc (`/redoc`)
- **Docker Support:** Containerized deployment

### Setup

1. `cd backend`
2. Copy `.env.example` to `.env` and fill in Supabase credentials
3. Install dependencies:
   - With pip:  
     `python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`
   - Or with Poetry:  
     `poetry install && poetry shell`
4. Run locally:  
   `uvicorn app.main:app --reload`
5. API docs:  
   [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)

### Docker

- Build: `docker build -t fitnation-auth .`
- Run:  
  `docker run -d --name fitnation-auth --env-file .env -p 8000:80 fitnation-auth`

---

## Database & Models

### Supabase (PostgreSQL)

- **Users Table:**  
  - `id` (UUID, PK)
  - `username`, `email`, `role`, `created_at`, `updated_at`
- **Profiles Table:**  
  - `id` (UUID, PK)
  - `user_id` (FK to users)
  - `display_name`, `bio`, `profile_picture_url`
  - `fitness_goals`, `height_cm`, `weight_kg`, `age`, `gender`, `activity_level`
  - (Extendable for preferences, health conditions, injuries, etc.)

#### Example Pydantic Schemas

```python
# UserPublic (backend/app/schemas/user.py)
class UserPublic(BaseModel):
    id: UUID
    username: str
    email: EmailStr
    role: str
    created_at: datetime
    profile: Optional[ProfilePublic]

# ProfilePublic (backend/app/schemas/profile.py)
class ProfilePublic(BaseModel):
    id: UUID
    user_id: UUID
    display_name: Optional[str]
    bio: Optional[str]
    profile_picture_url: Optional[str]
    fitness_goals: Optional[str]
    height_cm: Optional[float]
    weight_kg: Optional[float]
    age: Optional[int]
    gender: Optional[str]
    activity_level: Optional[str]
```

---

## Setup & Development

### Flutter

- See [/fitnation/README.MD](fitnation/README.md) for detailed setup, features, and development notes.

### Backend

- See [/backend/README.md](backend/README.md) for API endpoints, environment setup, and deployment.

---

## License

This project is licensed under the MIT License.

---

**For more details, see the individual README.md files in each subproject.**