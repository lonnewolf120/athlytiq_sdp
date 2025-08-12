import uuid
from typing import List, Optional

from sqlalchemy.orm import Session, joinedload, selectinload
from sqlalchemy import desc # For ordering

# Assuming your models are in app/models_db.py and schemas in app/schemas/workout_schemas.py
from app.models_db import CompletedWorkout, CompletedWorkoutExercise, CompletedWorkoutSet, User # Import specific models
from app.schemas import workout_schemas # Schemas are in app/schemas

def create_completed_workout(db: Session, *, user_id: uuid.UUID, workout_in: workout_schemas.CompletedWorkoutCreate) -> CompletedWorkout:
    """
    Creates a new completed workout session along with its exercises and sets.
    """
    db_completed_workout = CompletedWorkout( # Use direct model name
        user_id=user_id,
        workout_name=workout_in.workout_name,
        start_time=workout_in.start_time,
        end_time=workout_in.end_time,
        duration_seconds=workout_in.duration_seconds,
        intensity_score=workout_in.intensity_score
        # original_workout_id can be added if provided in workout_in
    )
    db.add(db_completed_workout)
    # db.flush() # Flush to get the db_completed_workout.id if needed before commit

    for ex_in in workout_in.exercises:
        db_ex = CompletedWorkoutExercise( # Use direct model name
            # completed_workout_id will be set by SQLAlchemy relationship back_populates or direct assignment
            exercise_id=ex_in.exercise_id,
            exercise_name=ex_in.exercise_name,
            exercise_equipments=ex_in.exercise_equipments,
            exercise_gif_url=ex_in.exercise_gif_url
        )
        # db.add(db_ex) # Add exercise to session
        db_completed_workout.exercises.append(db_ex) # Append to relationship

        for set_in in ex_in.sets:
            db_set = CompletedWorkoutSet( # Use direct model name
                # completed_workout_exercise_id will be set by SQLAlchemy relationship back_populates or direct assignment
                weight=set_in.weight,
                reps=set_in.reps
            )
            # db.add(db_set) # Add set to session
            db_ex.sets.append(db_set) # Append to relationship

    db.commit()
    db.refresh(db_completed_workout) # Refresh to get all relationships populated if lazy loaded
    return db_completed_workout

def get_completed_workouts_by_user(db: Session, *, user_id: uuid.UUID, skip: int = 0, limit: int = 20) -> List[CompletedWorkout]:
    """
    Retrieves a list of completed workout sessions for a specific user,
    ordered by most recent first.
    Eagerly loads exercises and their sets.
    """
    return (
        db.query(CompletedWorkout) # Use direct model name
        .filter(CompletedWorkout.user_id == user_id)
        .order_by(desc(CompletedWorkout.start_time)) # Show most recent first
        .options(
            selectinload(CompletedWorkout.exercises) # Use direct model name
            .selectinload(CompletedWorkoutExercise.sets) # Use direct model name
        )
        .offset(skip)
        .limit(limit)
        .all()
    )

def get_completed_workout_details(db: Session, *, user_id: uuid.UUID, session_id: uuid.UUID) -> Optional[CompletedWorkout]:
    """
    Retrieves a specific completed workout session by its ID, ensuring it belongs to the user.
    Eagerly loads exercises and their sets.
    """
    return (
        db.query(CompletedWorkout) # Use direct model name
        .filter(CompletedWorkout.id == session_id, CompletedWorkout.user_id == user_id)
        .options(
            selectinload(CompletedWorkout.exercises) # Use direct model name
            .selectinload(CompletedWorkoutExercise.sets) # Use direct model name
        )
        .first()
    )

# You might also need CRUD for planned workouts (Workout, Exercise tables) if not already present.
# For now, focusing on CompletedWorkout tracking.
