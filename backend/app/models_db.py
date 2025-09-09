import uuid
from sqlalchemy import Column,ForeignKey,DateTime
from datetime import datetime

from sqlalchemy import (
    Column, String, Integer, Float, Double, Text, Boolean, DateTime, Time, ForeignKey, Enum, UniqueConstraint, Index, JSON, TIMESTAMP
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
    
    # Shop relationships
    cart = relationship("Cart", back_populates="user", uselist=False)
    orders = relationship("Order", back_populates="user")
    product_reviews = relationship("ProductReview", back_populates="user")


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
    exercise_id = Column(String(255), nullable=False) 
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


# Shop Models
class ShopCategory(Base):
    __tablename__ = "shop_categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    image_url = Column(String(1024))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Relationship
    products = relationship("ShopProduct", back_populates="category")

class ShopProduct(Base):
    __tablename__ = "shop_products"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    price = Column(Float, nullable=False)
    sale_price = Column(Float) 
    image_urls = Column(JSON)  
    category_id = Column(Integer, ForeignKey("shop_categories.id"))
    brand = Column(String(255))
    sku = Column(String(100), unique=True)
    stock_quantity = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    is_featured = Column(Boolean, default=False)
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    tags = Column(JSON) 
    specifications = Column(JSON) 
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    category = relationship("ShopCategory", back_populates="products")
    cart_items = relationship("CartItem", back_populates="product")
    order_items = relationship("OrderItem", back_populates="product")
    reviews = relationship("ProductReview", back_populates="product")

class Cart(Base):
    __tablename__ = "carts"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="cart")
    items = relationship("CartItem", back_populates="cart", cascade="all, delete-orphan")

class CartItem(Base):
    __tablename__ = "cart_items"
    
    id = Column(Integer, primary_key=True, index=True)
    cart_id = Column(Integer, ForeignKey("carts.id"))
    product_id = Column(Integer, ForeignKey("shop_products.id"))
    quantity = Column(Integer, nullable=False)
    added_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Relationships
    cart = relationship("Cart", back_populates="items")
    product = relationship("ShopProduct", back_populates="cart_items")

class Order(Base):
    __tablename__ = "orders"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    order_number = Column(String(100), unique=True, nullable=False)
    status = Column(String(50), default="pending")  
    total_amount = Column(Float, nullable=False)
    shipping_address = Column(JSON) 
    payment_method = Column(String(100))
    payment_status = Column(String(50), default="pending") 
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")

class OrderItem(Base):
    __tablename__ = "order_items"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    product_id = Column(Integer, ForeignKey("shop_products.id"))
    quantity = Column(Integer, nullable=False)
    price = Column(Float, nullable=False) 
    
    # Relationships
    order = relationship("Order", back_populates="items")
    product = relationship("ShopProduct", back_populates="order_items")

class ProductReview(Base):
    __tablename__ = "product_reviews"
    
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("shop_products.id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    rating = Column(Integer, nullable=False)  # 1-5 stars
    comment = Column(Text)
    is_verified_purchase = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Relationships
    product = relationship("ShopProduct", back_populates="reviews")
    user = relationship("User", back_populates="product_reviews")


# Legacy Exercise model - keeping for backward compatibility
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
    
    # New relationship to normalized exercise library
    exercise_library_id = Column(UUID(as_uuid=True), ForeignKey('exercise_library.id'), nullable=True)
    exercise_library = relationship("ExerciseLibrary", foreign_keys=[exercise_library_id])


# --- NEW ENHANCED EXERCISE LIBRARY MODELS ---

class ExerciseCategory(Base):
    __tablename__ = 'exercise_categories'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), nullable=False, unique=True)
    description = Column(Text, nullable=True)
    color_code = Column(String(7), nullable=True)  # Hex color
    icon_name = Column(String(50), nullable=True)  # For UI icons
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    exercises = relationship("ExerciseLibrary", back_populates="category")


class MuscleGroup(Base):
    __tablename__ = 'muscle_groups'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), nullable=False, unique=True)
    group_type = Column(String(20), nullable=False)  # primary, secondary, stabilizer
    parent_id = Column(UUID(as_uuid=True), ForeignKey('muscle_groups.id'), nullable=True)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Self-referential relationship for hierarchical structure
    parent = relationship("MuscleGroup", remote_side=[id])
    children = relationship("MuscleGroup", back_populates="parent")
    
    # Many-to-many relationship with exercises
    exercises = relationship("ExerciseMuscleGroup", back_populates="muscle_group")


class EquipmentType(Base):
    __tablename__ = 'equipment_types'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), nullable=False, unique=True)
    category = Column(String(50), nullable=True)  # cardio, strength, bodyweight, functional
    description = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Many-to-many relationship with exercises
    exercises = relationship("ExerciseEquipment", back_populates="equipment")


class ExerciseLibrary(Base):
    __tablename__ = 'exercise_library'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    instructions = Column(Text, nullable=True)
    form_tips = Column(Text, nullable=True)
    gif_url = Column(Text, nullable=True)
    video_url = Column(Text, nullable=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey('exercise_categories.id'), nullable=True)
    difficulty_level = Column(Integer, nullable=True)  # 1-5 scale
    popularity_score = Column(Float, default=0.0)  # 0.0-5.0 rating
    is_compound = Column(Boolean, default=False)
    is_unilateral = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    category = relationship("ExerciseCategory", back_populates="exercises")
    muscle_groups = relationship("ExerciseMuscleGroup", back_populates="exercise")
    equipment = relationship("ExerciseEquipment", back_populates="exercise")
    variations_as_base = relationship("ExerciseVariation", foreign_keys="[ExerciseVariation.base_exercise_id]", back_populates="base_exercise")
    variations_as_variation = relationship("ExerciseVariation", foreign_keys="[ExerciseVariation.variation_exercise_id]", back_populates="variation_exercise")


class ExerciseMuscleGroup(Base):
    __tablename__ = 'exercise_muscle_groups'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    exercise_id = Column(UUID(as_uuid=True), ForeignKey('exercise_library.id', ondelete='CASCADE'), nullable=False)
    muscle_group_id = Column(UUID(as_uuid=True), ForeignKey('muscle_groups.id', ondelete='CASCADE'), nullable=False)
    is_primary = Column(Boolean, default=True)
    activation_level = Column(Integer, nullable=True)  # 1-5 scale
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Relationships
    exercise = relationship("ExerciseLibrary", back_populates="muscle_groups")
    muscle_group = relationship("MuscleGroup", back_populates="exercises")


class ExerciseEquipment(Base):
    __tablename__ = 'exercise_equipment'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    exercise_id = Column(UUID(as_uuid=True), ForeignKey('exercise_library.id', ondelete='CASCADE'), nullable=False)
    equipment_id = Column(UUID(as_uuid=True), ForeignKey('equipment_types.id', ondelete='CASCADE'), nullable=False)
    is_required = Column(Boolean, default=True)
    is_alternative = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Relationships
    exercise = relationship("ExerciseLibrary", back_populates="equipment")
    equipment = relationship("EquipmentType", back_populates="exercises")


class ExerciseVariation(Base):
    __tablename__ = 'exercise_variations'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    base_exercise_id = Column(UUID(as_uuid=True), ForeignKey('exercise_library.id', ondelete='CASCADE'), nullable=False)
    variation_exercise_id = Column(UUID(as_uuid=True), ForeignKey('exercise_library.id', ondelete='CASCADE'), nullable=False)
    variation_type = Column(String(50), nullable=True)  # easier, harder, alternative, progression
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Relationships
    base_exercise = relationship("ExerciseLibrary", foreign_keys=[base_exercise_id], back_populates="variations_as_base")
    variation_exercise = relationship("ExerciseLibrary", foreign_keys=[variation_exercise_id], back_populates="variations_as_variation")

# --- END OF ENHANCED EXERCISE LIBRARY MODELS ---



challenge_activity_type_enum = PGEnum(
    'run', 'ride', 'swim', 'walk', 'hike', 'workout',
    name='challenge_activity_type'
)

challenge_status_enum = PGEnum(
    'upcoming', 'active', 'completed', 'cancelled',
    name='challenge_status'
)

participant_status_enum = PGEnum(
    'joined', 'left', 'completed', 'failed',
    name='participant_status'
)

class Challenge(Base):
    __tablename__ = 'challenges'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    brand = Column(String(100), nullable=False)
    brand_logo = Column(String(10), nullable=True) 
    background_image = Column(String(1024), nullable=True)
    distance = Column(String(100), nullable=False) 
    duration = Column(String(200), nullable=False)  
    start_date = Column(DateTime(timezone=True), nullable=False)
    end_date = Column(DateTime(timezone=True), nullable=False)
    activity_type = Column(challenge_activity_type_enum, nullable=False, default='run')
    status = Column(challenge_status_enum, nullable=False, default='upcoming')
    brand_color = Column(String(7), nullable=False, default='#FF6B35')  # Hex color code
    max_participants = Column(Integer, nullable=True)  
    is_public = Column(Boolean, nullable=False, default=True)
    created_by = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    creator = relationship("User", back_populates="created_challenges")
    participants = relationship("ChallengeParticipant", back_populates="challenge", cascade="all, delete-orphan")
    
    # Indexes
    __table_args__ = (
        Index('idx_challenges_activity_type', 'activity_type'),
        Index('idx_challenges_status', 'status'),
        Index('idx_challenges_start_date', 'start_date'),
        Index('idx_challenges_end_date', 'end_date'),
        Index('idx_challenges_created_by', 'created_by'),
    )

class ChallengeParticipant(Base):
    __tablename__ = 'challenge_participants'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    challenge_id = Column(UUID(as_uuid=True), ForeignKey('challenges.id'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    status = Column(participant_status_enum, nullable=False, default='joined')
    progress = Column(Float, nullable=False, default=0.0)  # Progress value as decimal
    progress_percentage = Column(Float, nullable=False, default=0.0)  # 0.0 to 100.0
    completion_proof_url = Column(String(1024), nullable=True)  # Screenshot/proof image
    joined_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    notes = Column(Text, nullable=True)
    
    # Relationships
    challenge = relationship("Challenge", back_populates="participants")
    participant = relationship("User", back_populates="challenge_participations")
    
    # Constraints
    __table_args__ = (
        UniqueConstraint('challenge_id', 'user_id', name='unique_challenge_participant'),
        Index('idx_challenge_participants_challenge_id', 'challenge_id'),
        Index('idx_challenge_participants_user_id', 'user_id'),
        Index('idx_challenge_participants_status', 'status'),
    )

# Add relationships to User model
User.created_challenges = relationship("Challenge", back_populates="creator")
User.challenge_participations = relationship("ChallengeParticipant", back_populates="participant")



class TrainerProfile(Base):
    __tablename__ = 'trainer_profiles'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, unique=True)
    bio = Column(Text, nullable=True)
    certifications = Column(Text, nullable=True)
    specialties = Column(Text, nullable=True)
    rating = Column(Float, nullable=True, default=0.0)
    hourly_rate = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship('User')
    availabilities = relationship('TrainerAvailability', back_populates='trainer', cascade='all, delete-orphan')
    sessions = relationship('TrainerSession', back_populates='trainer', cascade='all, delete-orphan')


class TrainerAvailability(Base):
    __tablename__ = 'trainer_availabilities'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trainer_id = Column(UUID(as_uuid=True), ForeignKey('trainer_profiles.id', ondelete='CASCADE'), nullable=False)
    weekday = Column(Integer, nullable=False)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    trainer = relationship('TrainerProfile', back_populates='availabilities')


class TrainerSession(Base):
    __tablename__ = 'trainer_sessions'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trainer_id = Column(UUID(as_uuid=True), ForeignKey('trainer_profiles.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    start_time = Column(DateTime(timezone=True), nullable=False)
    end_time = Column(DateTime(timezone=True), nullable=False)
    status = Column(String(50), nullable=False, default='pending')
    notes = Column(Text, nullable=True)
    price = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    trainer = relationship('TrainerProfile', back_populates='sessions')
    user = relationship('User')

# Chat and Friends Models
class ChatRoom(Base):
    __tablename__ = 'chat_rooms'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    type = Column(String(20), nullable=False, default='direct')  # 'direct' or 'group'
    name = Column(String(255), nullable=True)  # For group chats
    description = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    created_by = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    last_message_at = Column(DateTime(timezone=True), nullable=True)
    last_message_content = Column(Text, nullable=True)
    last_message_sender_id = Column(UUID(as_uuid=True), nullable=True)
    is_archived = Column(Boolean, default=False)

    # Relationships
    creator = relationship('User', foreign_keys=[created_by])
    participants = relationship('ChatParticipant', back_populates='room', cascade='all, delete-orphan')
    messages = relationship('ChatMessage', back_populates='room', cascade='all, delete-orphan')

class ChatParticipant(Base):
    __tablename__ = 'chat_participants'
    
    room_id = Column(UUID(as_uuid=True), ForeignKey('chat_rooms.id', ondelete='CASCADE'), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    role = Column(String(20), nullable=False, default='member')  # 'admin', 'member'
    joined_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    left_at = Column(DateTime(timezone=True), nullable=True)
    last_read_at = Column(DateTime(timezone=True), nullable=True)
    unread_count = Column(Integer, default=0)
    is_muted = Column(Boolean, default=False)
    is_pinned = Column(Boolean, default=False)

    # Relationships
    room = relationship('ChatRoom', back_populates='participants')
    user = relationship('User')

class ChatMessage(Base):
    __tablename__ = 'chat_messages'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    room_id = Column(UUID(as_uuid=True), ForeignKey('chat_rooms.id', ondelete='CASCADE'), nullable=False)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    message_type = Column(String(20), nullable=False, default='text')  # 'text', 'image', 'video', 'audio', 'file', 'location', 'workout', 'system'
    content = Column(Text, nullable=True)
    media_urls = Column(JSONB, nullable=True)  # Array of media URLs
    metadata = Column(JSONB, nullable=True)  # Additional data like location, workout details, etc.
    reply_to_id = Column(UUID(as_uuid=True), ForeignKey('chat_messages.id'), nullable=True)
    forwarded_from_id = Column(UUID(as_uuid=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    edited_at = Column(DateTime(timezone=True), nullable=True)
    is_deleted = Column(Boolean, default=False)
    deleted_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    room = relationship('ChatRoom', back_populates='messages')
    sender = relationship('User', foreign_keys=[sender_id])
    reply_to = relationship('ChatMessage', remote_side=[id])
    reactions = relationship('MessageReaction', back_populates='message', cascade='all, delete-orphan')
    read_receipts = relationship('MessageReadReceipt', back_populates='message', cascade='all, delete-orphan')

class MessageReaction(Base):
    __tablename__ = 'message_reactions'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    message_id = Column(UUID(as_uuid=True), ForeignKey('chat_messages.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    emoji = Column(String(10), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    # Relationships
    message = relationship('ChatMessage', back_populates='reactions')
    user = relationship('User')
    
    # Unique constraint
    __table_args__ = (UniqueConstraint('message_id', 'user_id', 'emoji', name='_message_user_emoji_uc'),)

class MessageReadReceipt(Base):
    __tablename__ = 'message_read_receipts'
    
    message_id = Column(UUID(as_uuid=True), ForeignKey('chat_messages.id', ondelete='CASCADE'), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    read_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    # Relationships
    message = relationship('ChatMessage', back_populates='read_receipts')
    user = relationship('User')

class FriendRequest(Base):
    __tablename__ = 'friend_requests'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    receiver_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    message = Column(Text, nullable=True)
    status = Column(String(20), nullable=False, default='pending')  # 'pending', 'accepted', 'rejected', 'blocked'
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    responded_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    sender = relationship('User', foreign_keys=[sender_id])
    receiver = relationship('User', foreign_keys=[receiver_id])
    
    # Unique constraint
    __table_args__ = (UniqueConstraint('sender_id', 'receiver_id', name='_sender_receiver_uc'),)

class UserOnlineStatus(Base):
    __tablename__ = 'user_online_status'
    
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    is_online = Column(Boolean, default=False)
    last_seen = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship('User')

# Add Buddies model if it doesn't exist (extending existing social system)
class Buddy(Base):
    __tablename__ = 'buddies'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    buddy_user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    status = Column(String(20), nullable=False, default='accepted')  # 'accepted', 'blocked'
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    # Relationships
    user = relationship('User', foreign_keys=[user_id])
    buddy = relationship('User', foreign_keys=[buddy_user_id])
    
    # Unique constraint
    __table_args__ = (UniqueConstraint('user_id', 'buddy_user_id', name='_user_buddy_uc'),)
