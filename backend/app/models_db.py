import uuid
from sqlalchemy import Column,ForeignKey,DateTime
from datetime import datetime

from sqlalchemy import (
    Column, String, Integer, Float, Double, Text, Boolean, DateTime, ForeignKey, Enum, UniqueConstraint, Index, JSON, TIMESTAMP
)
from sqlalchemy.dialects.postgresql import UUID, ENUM as PGEnum, JSONB, ARRAY
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from enum import Enum as PyEnum # Import Python's Enum

class PrivacyType(PyEnum):
    public = "public"
    private = "private"
    gymbuddies = "gymbuddies"
    close = "close"


Base = declarative_base()

# ENUM types
ride_activity_enum = PGEnum(
    'mountain', 'road', 'tandem', 'cyclocross', 'running', 'hiking', 'other_workout',
    name='ride_activity_type'
)
community_member_role_enum = PGEnum(
    'member', 'moderator', 'admin',
    name='community_member_role'
)
post_type_enum = PGEnum(
    'text', 'workout', 'challenge',
    name='post_type_enum'
)
privacy_type_enum = PGEnum(
    'public', 'private', 'gymbuddies', 'close', # Matches the ENUM in tables.sql
    name='privacy_type_enum',
    create_type=False # Assume type already exists in DB or will be created by tables.sql
)

class User(Base):
    __tablename__ = 'users'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    username = Column(String(100), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=True) #for google/fb OAuth this will be null
    google_id = Column(String(255), unique=True, nullable=True) # For Google OAuth
    role = Column(String(50), nullable=False, default='user') # Consider using an Enum if roles are fixed
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    profile = relationship("Profile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    posts = relationship("Post", back_populates="author", cascade="all, delete-orphan")
    comments = relationship("Comment", back_populates="author", cascade="all, delete-orphan")
    reacts = relationship("React", back_populates="user", cascade="all, delete-orphan")
    # Planned Workouts (templates)
    planned_workouts = relationship("Workout", back_populates="user", cascade="all, delete-orphan")
    # Completed Workout Sessions
    completed_workouts = relationship("CompletedWorkout", back_populates="user", cascade="all, delete-orphan")
    health_logs = relationship("HealthLog", back_populates="user", cascade="all, delete-orphan")
    food_logs = relationship("FoodLog", back_populates="user", cascade="all, delete-orphan")
    meals = relationship("Meal", back_populates="user", cascade="all, delete-orphan") # New relationship for meals
    diet_recommendations = relationship("DietRecommendation", back_populates="user", cascade="all, delete-orphan")
    refresh_tokens = relationship("RefreshToken", back_populates="user", cascade="all, delete-orphan")
    # organized_rides = relationship("RidesActivities", back_populates="organizer", foreign_keys="[RidesActivities.organizer_user_id]", cascade="all, delete-orphan")
    # ride_participations = relationship("RideActivityParticipant", back_populates="user", cascade="all, delete-orphan") # Handled by association table
    created_communities = relationship("Community", back_populates="creator", foreign_keys="[Community.creator_user_id]", cascade="all, delete-orphan")
    # community_memberships = relationship("CommunityMember", back_populates="user", cascade="all, delete-orphan") # Handled by association table


class Profile(Base):
    __tablename__ = 'profiles'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False)
    bio = Column(Text, nullable=True)
    profile_picture_url = Column(String(1024), nullable=True)
    fitness_goals = Column(Text, nullable=True)
    display_name = Column(String(150), nullable=True)
    height_cm = Column(Float, nullable=True)
    weight_kg = Column(Float, nullable=True)
    age = Column(Integer, nullable=True)
    gender = Column(String(50), nullable=True)
    # activity_level = Column(String(255), nullable=True) # New field for activity level
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="profile", foreign_keys=[user_id])


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    token = Column(Text, unique=True, nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)


class Post(Base):
    __tablename__ = 'posts'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    content = Column(Text, nullable=True)
    media_url = Column(String(1024), nullable=True)
    post_type = Column(ARRAY(post_type_enum), nullable=False) # Array of enum values
    workout_post_id = Column(UUID(as_uuid=True), ForeignKey('workout_posts.id', ondelete='SET NULL'), nullable=True)
    challenge_post_id = Column(UUID(as_uuid=True), ForeignKey('challenge_posts.id', ondelete='SET NULL'), nullable=True)
    privacy = Column(privacy_type_enum, nullable=False, default='public', server_default='public') # Added privacy column
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    # community_id = Column(UUID(as_uuid=True), ForeignKey('communities.id', ondelete='SET NULL'), nullable=True)

    author = relationship("User", back_populates="posts")
    comments = relationship("Comment", back_populates="post", cascade="all, delete-orphan")
    reacts = relationship("React", back_populates="post", cascade="all, delete-orphan")
    workout_data = relationship("WorkoutPost", back_populates="post", uselist=False, cascade="all, delete-orphan", single_parent=True)
    challenge_data = relationship("ChallengePost", back_populates="post", uselist=False, cascade="all, delete-orphan", single_parent=True)


class Comment(Base):
    __tablename__ = 'post_comments' # Renamed to match schema.sql
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey('posts.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    post = relationship("Post", back_populates="comments")
    author = relationship("User", back_populates="comments")

class React(Base):
    __tablename__ = 'post_reacts' # Renamed to match schema.sql
    # id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4) # Reacts usually identified by post_id and user_id
    post_id = Column(UUID(as_uuid=True), ForeignKey('posts.id', ondelete='CASCADE'), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    react_type = Column(String(50), default='like', nullable=False) # e.g., 'like', 'love', 'haha'
    emoji = Column(String(10), default='👍', nullable=True) # Store actual emoji

    post = relationship("Post", back_populates="reacts")
    user = relationship("User", back_populates="reacts")

# For PLANNED Workouts (Templates)

class Workout(Base):
    __tablename__ = "workouts"
    id = Column(UUID(as_uuid=True),primary_key=True,unique=True,nullable=False,default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    name = Column(Text,index=True)
    icon_url = Column(Text, nullable=True)
    description = Column(Text, nullable=True)
    equipment_selected = Column(Text, nullable=True)
    one_rm_goal = Column(Text, nullable=True)
    type = Column(Text, nullable=True)
    prompt = Column(JSONB, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    user = relationship("User", back_populates="planned_workouts")
    planned_exercises = relationship("PlannedExercise", back_populates="workout_plan", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<A Workout object {self}>"
   
# For Exercises within a PLANNED Workout (Template)
class PlannedExercise(Base):
    __tablename__ = 'planned_exercises' # Renamed to match schema.sql
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    workout_id = Column(UUID(as_uuid=True), ForeignKey('workouts.id', ondelete='CASCADE'), nullable=False) # FK to planned Workout
    # exercise_db_id = Column(String(255), nullable=True) # Optional: If linking to a master exercise DB
    exercise_id = Column(String(255), nullable=False) # Reference to exercises.exercise_id (external)
    exercise_name = Column(String(255), nullable=False)
    exercise_equipments = Column(ARRAY(String), nullable=True)
    exercise_gif_url = Column(String(1024), nullable=True)
    type = Column(String(50), nullable=True) # e.g., "weight_reps"
    planned_sets = Column(Integer, nullable=False)
    planned_reps = Column(Integer, nullable=False)
    planned_weight = Column(String(50), nullable=True) # Could be String to accommodate "bodyweight"
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    # No updated_at for planned_exercises in schema.sql

    workout_plan = relationship("Workout", back_populates="planned_exercises")


# --- NEW MODELS FOR COMPLETED WORKOUT TRACKING ---

class CompletedWorkout(Base):
    __tablename__ = 'completed_workouts'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    original_workout_id = Column(UUID(as_uuid=True), ForeignKey('workouts.id', ondelete='SET NULL'), nullable=True) # Link to the planned workout template if used
    workout_name = Column(String(255), nullable=False)
    workout_icon_url = Column(String(1024), nullable=True)
    start_time = Column(DateTime(timezone=True), nullable=False)
    end_time = Column(DateTime(timezone=True), nullable=False)
    duration_seconds = Column(Integer, nullable=False)
    intensity_score = Column(Float, nullable=False) # e.g., RPE 1-10
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow) # Though completed workouts might not be updated often

    user = relationship("User", back_populates="completed_workouts")
    original_workout_plan = relationship("Workout", foreign_keys=[original_workout_id]) # Relationship to the planned workout
    exercises = relationship("CompletedWorkoutExercise", back_populates="completed_workout_session", cascade="all, delete-orphan", lazy="selectin")


class CompletedWorkoutExercise(Base):
    __tablename__ = 'completed_workout_exercises'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    completed_workout_id = Column(UUID(as_uuid=True), ForeignKey('completed_workouts.id', ondelete='CASCADE'), nullable=False)
    # exercise_db_id = Column(String(255), nullable=True) # Optional: If linking to a master exercise DB
    exercise_id = Column(String(255), nullable=False) # Could be an ID from an external exercise API or a user-defined one
    exercise_name = Column(String(255), nullable=False)
    exercise_equipments = Column(ARRAY(String), nullable=True) # Using PostgreSQL ARRAY type
    exercise_gif_url = Column(String(1024), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    # No updated_at typically for these records once created as part of a session

    completed_workout_session = relationship("CompletedWorkout", back_populates="exercises")
    sets = relationship("CompletedWorkoutSet", back_populates="completed_exercise", cascade="all, delete-orphan", lazy="selectin")


class CompletedWorkoutSet(Base):
    __tablename__ = 'completed_workout_sets'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    completed_workout_exercise_id = Column(UUID(as_uuid=True), ForeignKey('completed_workout_exercises.id', ondelete='CASCADE'), nullable=False)
    weight = Column(String(50), nullable=False) # String to allow "BW" or "10 kg"
    reps = Column(String(50), nullable=False)   # String to allow "10-12" or "AMRAP"
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    # No updated_at typically

    completed_exercise = relationship("CompletedWorkoutExercise", back_populates="sets")


# --- END OF NEW MODELS FOR COMPLETED WORKOUT TRACKING ---

# --- NEW MODELS FOR MEAL TRACKING ---
class Meal(Base):
    __tablename__ = 'meals'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    meal_type = Column(String(50), nullable=False)
    logged_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    total_calories = Column(Float, nullable=False)
    total_protein = Column(Float, nullable=False)
    total_carbs = Column(Float, nullable=False)
    total_fat = Column(Float, nullable=False)
    image_url = Column(String(1024), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="meals")
    food_items = relationship("FoodItem", back_populates="meal", cascade="all, delete-orphan", lazy="selectin")

class FoodItem(Base):
    __tablename__ = 'food_items'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    meal_id = Column(UUID(as_uuid=True), ForeignKey('meals.id', ondelete='CASCADE'), nullable=False)
    name = Column(String(255), nullable=False)
    calories = Column(Float, nullable=False)
    protein = Column(Float, nullable=False)
    carbs = Column(Float, nullable=False)
    fat = Column(Float, nullable=False)
    quantity = Column(Float, nullable=False, default=1.0)
    unit = Column(String(50), nullable=False, default='item')
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    meal = relationship("Meal", back_populates="food_items")
# --- END OF NEW MODELS FOR MEAL TRACKING ---

class MealPlan(Base):
    __tablename__ = "meal_plans"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    name = Column(Text, nullable=False)
    description = Column(Text, nullable=True)
    user_goals = Column(Text, nullable=True)
    linked_workout_plan_id = Column(UUID(as_uuid=True), ForeignKey("workouts.id"), nullable=True)
    meals_json = Column(JSON, nullable=False) # Stores list of Meal objects as JSONB
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", backref="meal_plans") # Backref for simplicity
    linked_workout_plan = relationship("Workout") # Relationship to Workout model

    def __repr__(self):
        return f"<MealPlan {self.name} by User {self.user_id}>"


class HealthLog(Base):
    __tablename__ = 'health_logs'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    log_type = Column(String(100), nullable=False) # e.g., 'weight', 'sleep_hours', 'water_intake_ml'
    log_date = Column(DateTime(timezone=True), nullable=True)
    sleep_hours = Column(Float, nullable=True)
    water_intake_ml = Column(Float, nullable=True)
    notes = Column(Text, nullable=True)
    value = Column(Float, nullable=False)
    log_date = Column(DateTime(timezone=True), default=datetime.utcnow) # Date the log pertains to
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="health_logs")

class FoodLog(Base):
    __tablename__ = 'food_logs'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    food_name = Column(String(255), nullable=False)
    external_food_id = Column(String(255), nullable=True) # If using a food API like Edamam
    calories = Column(Float, nullable=True)
    protein_g = Column(Float, nullable=True)
    carbs_g = Column(Float, nullable=True)
    fat_g = Column(Float, nullable=True)
    notes = Column(String(255), nullable=True)
    serving_size = Column(String(100), nullable=True)
    meal_type = Column(String(50), nullable=True) # e.g., 'breakfast', 'lunch', 'dinner', 'snack'
    log_date = Column(DateTime(timezone=True), default=datetime.utcnow) # Date the log pertains to
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="food_logs")

class DietRecommendation(Base):
    __tablename__ = 'diet_recommendations'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    recommendation_text = Column(Text, nullable=False)
    # generated_at = Column(DateTime(timezone=True), default=datetime.utcnow) # When the AI generated this
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    # No updated_at, recommendations are typically point-in-time

    user = relationship("User", back_populates="diet_recommendations")

class RefreshToken(Base):
    __tablename__ = 'refresh_tokens'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4) # Or use token_hash as PK if truly unique and indexed
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    token_hash = Column(String(255), unique=True, nullable=False, index=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    revoked_at = Column(DateTime(timezone=True), nullable=True) # To mark token as revoked

    user = relationship("User", back_populates="refresh_tokens")

# class RideActivityParticipant(Base):
#     __tablename__ = 'ride_activity_participants'
#     ride_activity_id = Column(UUID(as_uuid=True), ForeignKey('rides_activities.id', ondelete='CASCADE'), primary_key=True)
#     user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
#     joined_at = Column(DateTime(timezone=True), default=datetime.utcnow)

#     ride_activity = relationship(
#         "RidesActivities",
#         back_populates="participants",
#         foreign_keys=[ride_activity_id]
#     )
#     user = relationship("User") # No back_populates needed if User doesn't directly list participations often

# class RidesActivities(Base):
#     __tablename__ = 'ride_activities' # Renamed to match schema.sql
#     id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
#     organizer_user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
#     name = Column(String(255), nullable=False)
#     description = Column(Text, nullable=True)
#     image_url = Column(String(1024), nullable=True)
#     distance_km = Column(Float, nullable=True)
#     elevation_meters = Column(Integer, nullable=True)
#     type = Column(ride_activity_enum, nullable=False)
#     route_coordinates = Column(JSONB, nullable=True) # Store as GeoJSON or list of lat/lng
#     location_name = Column(String(255), nullable=True)
#     park_name = Column(String(255), nullable=True)
#     start_time = Column(DateTime(timezone=True), nullable=True)
#     created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
#     updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # organizer = relationship("User", back_populates="organized_rides") # Commented out with User.organized_rides
    # participants = relationship("RideActivityParticipant", back_populates="ride_activity", cascade="all, delete-orphan", foreign_keys=[RideActivityParticipant.ride_activity_id])

class Community(Base):
    __tablename__ = 'communities'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    creator_user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    name = Column(String(255), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(String(1024), nullable=True)
    is_private = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    creator = relationship("User", back_populates="created_communities")
    members = relationship("CommunityMember", back_populates="community", cascade="all, delete-orphan")

class CommunityMember(Base):
    __tablename__ = 'community_members'
    community_id = Column(UUID(as_uuid=True), ForeignKey('communities.id', ondelete='CASCADE'), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    role = Column(community_member_role_enum, nullable=False, default='member')
    joined_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    community = relationship("Community", back_populates="members")
    user = relationship("User") # No back_populates needed if User doesn't directly list memberships often

# New models for Post types
class WorkoutPost(Base):
    __tablename__ = 'workout_posts'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    workout_type = Column(String(255), nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    calories_burned = Column(Integer, nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    post = relationship("Post", back_populates="workout_data", uselist=False)
    exercises = relationship("WorkoutPostExercise", back_populates="workout_post", cascade="all, delete-orphan")

class WorkoutHistory(Base):
    __tablename__="workout_history"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    original_workout_id = Column(UUID(as_uuid=True), ForeignKey('workouts.id', ondelete='SET NULL'), nullable=True)
    workout_name = Column(Text, nullable=False)
    workout_icon_url = Column(Text)
    start_time = Column(TIMESTAMP(timezone=True), nullable=False)
    end_time = Column(TIMESTAMP(timezone=True), nullable=False)
    duration_seconds = Column(Integer, nullable=False)
    intensity_score = Column(Double, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
class WorkoutSets(Base):
    __tablename__="workout_sets"
    id=Column(UUID(as_uuid=True),primary_key=True,unique=True,nullable=False,default=uuid.uuid4)
    user_id=Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    weight=Column(Float)
    reps=Column(Integer)
    isCompleted=Column(Boolean)

class WorkoutPostExercise(Base):
    __tablename__ = 'workout_post_exercises'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    workout_post_id = Column(UUID(as_uuid=True), ForeignKey('workout_posts.id', ondelete='CASCADE'), nullable=False)
    exercise_id = Column(String(255), nullable=False) # Reference to external exercise ID
    name = Column(String(255), nullable=False)
    gif_url = Column(String(1024), nullable=True)
    body_parts = Column(ARRAY(String), nullable=True)
    equipments = Column(ARRAY(String), nullable=True)
    target_muscles = Column(ARRAY(String), nullable=True)
    secondary_muscles = Column(ARRAY(String), nullable=True)
    instructions = Column(ARRAY(String), nullable=True)
    image_url = Column(String(1024), nullable=True)
    exercise_type = Column(String(50), nullable=True)
    keywords = Column(ARRAY(String), nullable=True)
    overview = Column(Text, nullable=True)
    video_url = Column(String(1024), nullable=True)
    exercise_tips = Column(ARRAY(String), nullable=True)
    variations = Column(ARRAY(String), nullable=True)
    related_exercise_ids = Column(ARRAY(String), nullable=True)
    sets = Column(String(50), nullable=True)
    reps = Column(String(50), nullable=True)
    weight = Column(String(50), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    workout_post = relationship("WorkoutPost", back_populates="exercises")

class ChallengePost(Base):
    __tablename__ = 'challenge_posts'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    start_date = Column(DateTime(timezone=True), nullable=False)
    duration_days = Column(Integer, nullable=False)
    cover_image_url = Column(String(1024), nullable=True)
    participant_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    post = relationship("Post", back_populates="challenge_data", uselist=False)


class Exercise(Base):
    __tablename__="exercises"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(Text, nullable=False)
    gifUrl = Column(Text,nullable=False)
    bodyParts = Column(Text)
    equipments = Column(Text)
    
    sets = Column(Integer)
    reps = Column(Integer)
    weight = Column(Float)
    duration_seconds = Column(Integer)
    notes = Column(Text)
    order_in_workout = Column(Integer)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow)

# Ensure all models that have an updated_at field also have onupdate=datetime.utcnow for auto-update
# (Added this to User, Profile, Post, Comment, Workout, Exercise, HealthLog, FoodLog, RidesActivities, Community)
# CompletedWorkout, CompletedWorkoutExercise, CompletedWorkoutSet typically don't get updated after creation,
# but added onupdate to CompletedWorkout for consistency if some metadata might change.
