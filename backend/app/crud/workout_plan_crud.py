import uuid
from typing import List, Optional

from sqlalchemy.orm import Session, selectinload
from sqlalchemy import desc

from app.models_db import Workout, PlannedExercise, User # Import necessary models
from app.schemas import workout as workout_schemas # Alias to avoid name collision

def create_workout_plan(
    db: Session, *, user_id: uuid.UUID, workout_in: workout_schemas.WorkoutCreate
) -> Workout:
    """
    Creates a new workout plan along with its planned exercises.
    """
    db_workout = Workout(
        user_id=user_id,
        name=workout_in.name,
        icon_url=workout_in.icon_url,
        prompt=workout_in.prompt,
        equipment_selected=workout_in.equipment_selected,
        one_rm_goal=workout_in.one_rm_goal,
        type=workout_in.type
    )
    db.add(db_workout)
    db.flush() # Flush to get the db_workout.id for planned_exercises

    for ex_in in workout_in.exercises:
        db_planned_exercise = PlannedExercise(
            workout_id=db_workout.id,
            exercise_id=ex_in.exercise_id,
            exercise_name=ex_in.exercise_name,
            exercise_equipments=ex_in.exercise_equipments,
            exercise_gif_url=ex_in.exercise_gif_url,
            type=ex_in.type,
            planned_sets=ex_in.planned_sets,
            planned_reps=ex_in.planned_reps,
            planned_weight=ex_in.planned_weight
        )
        db.add(db_planned_exercise)

    db.commit()
    # print(f"Created workout: {db_workout}")
    db.refresh(db_workout) # Refresh to get all relationships populated if lazy loaded
    return db_workout

def get_workout_plans_by_user(
    db: Session, *, user_id: uuid.UUID, skip: int = 0, limit: int = 20
) -> List[Workout]:
    """
    Retrieves a list of workout plans for a specific user,
    ordered by most recent first, eagerly loading planned exercises.
    """
    return (
        db.query(Workout)
        .filter(Workout.user_id == user_id)
        .order_by(desc(Workout.created_at))
        .options(selectinload(Workout.planned_exercises))
        .offset(skip)
        .limit(limit)
        .all()
    )

def get_workout_plan_details(
    db: Session, *, user_id: uuid.UUID, workout_id: uuid.UUID
) -> Optional[Workout]:
    """
    Retrieves a specific workout plan by its ID, ensuring it belongs to the user,
    eagerly loading planned exercises.
    """
    return (
        db.query(Workout)
        .filter(Workout.id == workout_id, Workout.user_id == user_id)
        .options(selectinload(Workout.planned_exercises))
        .first()
    )
