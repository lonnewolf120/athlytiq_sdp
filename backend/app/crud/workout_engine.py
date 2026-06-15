"""
Deterministic Workout Engine

Queries the REAL exercise library database to build workout plans.
NO AI involved — pure rule-based logic with progressive overload from history.
Every exercise_id returned is a real UUID from the exercises database.
"""
import uuid
from typing import List, Dict, Optional, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_
from app.models_db import (
    ExerciseLibrary, ExerciseMuscleGroup, MuscleGroup,
    ExerciseEquipment, EquipmentType,
    CompletedWorkout, CompletedWorkoutExercise
)
from app.schemas.workout_engine import (
    WorkoutEngineRequest, WorkoutEngineResponse, GeneratedExercise,
    SPLIT_CONFIGS, GOAL_CONFIGS, DURATION_EXERCISE_COUNT, MUSCLE_ALIASES
)


class WorkoutEngine:
    """
    Pure deterministic workout plan generator.

    Flow:
    1. Determine split type and target body parts
    2. Calculate exercise count from duration
    3. For each target body part, query the exercise library
    4. Prioritize compound exercises first, then isolation
    5. Apply equipment filtering
    6. Assign sets/reps based on goal
    7. Apply progressive overload if user history is available
    8. Return a WorkoutEngineResponse with ONLY real exercise IDs
    """

    def __init__(self, db: Session):
        self.db = db

    def generate(self, request: WorkoutEngineRequest) -> WorkoutEngineResponse:
        split_config = SPLIT_CONFIGS.get(request.split_type, SPLIT_CONFIGS["balanced"])
        goal_config = GOAL_CONFIGS.get(request.goal, GOAL_CONFIGS["general_fitness"])
        requested_body_parts = self._expand_muscle_terms(request.body_parts)

        # Determine exercise count
        min_ex, max_ex = self._get_exercise_count(request.duration_minutes)
        if request.exercise_count:
            min_ex = max_ex = request.exercise_count

        exercises: List[GeneratedExercise] = []
        order = 0

        # For each body group in the split, query exercises
        for group_name, group_config in split_config.items():
            target_muscles = group_config.get("muscles", [])
            
            # If user specified body_parts, filter to those
            if requested_body_parts:
                target_muscles = [
                    m for m in target_muscles 
                    if self._matches_any_muscle_term(m, requested_body_parts)
                ]
                # If a user requests a valid body part that does not appear in this split
                # group, skip this group. If all groups skip, global fallback below fills.
                if not target_muscles:
                    continue

            target_muscles = self._expand_muscle_terms(target_muscles)

            # Query compound exercises first
            compound_exercises = self._query_exercises(
                target_muscles=target_muscles,
                equipment=request.equipment,
                is_compound=True,
                experience_level=request.experience_level,
                limit=max_ex // 2 + 1,
            )

            # Query isolation exercises
            isolation_exercises = self._query_exercises(
                target_muscles=target_muscles,
                equipment=request.equipment,
                is_compound=False,
                experience_level=request.experience_level,
                limit=max_ex,
            )

            # Interleave: compound first, then isolation
            group_exercises = []
            used_ids = set()

            for ex in compound_exercises:
                if len(group_exercises) >= max_ex:
                    break
                if ex.id not in used_ids:
                    group_exercises.append(ex)
                    used_ids.add(ex.id)

            for ex in isolation_exercises:
                if len(group_exercises) >= max_ex:
                    break
                if ex.id not in used_ids:
                    group_exercises.append(ex)
                    used_ids.add(ex.id)

            # Assign sets/reps and build GeneratedExercise objects
            for ex in group_exercises:
                is_compound_ex = getattr(ex, 'is_compound', False)
                if is_compound_ex:
                    sets = goal_config["compound_sets"]
                    reps = goal_config["compound_reps"]
                else:
                    sets = goal_config["isolation_sets"]
                    reps = goal_config["isolation_reps"]

                # Get equipment names
                equip_names = []
                if hasattr(ex, 'equipment') and ex.equipment:
                    for ee in ex.equipment:
                        if hasattr(ee, 'equipment') and ee.equipment:
                            equip_names.append(ee.equipment.name)

                # Get muscle group names
                muscle_names = []
                if hasattr(ex, 'muscle_groups') and ex.muscle_groups:
                    for emg in ex.muscle_groups:
                        if hasattr(emg, 'muscle_group') and emg.muscle_group:
                            muscle_names.append(emg.muscle_group.name)

                # Get suggested weight from progressive overload
                suggested_weight = self._get_progressive_overload(
                    user_id=request.user_id,
                    exercise_name=ex.name,
                    goal=request.goal,
                )

                order += 1
                exercises.append(GeneratedExercise(
                    exercise_id=str(ex.id),
                    exercise_name=ex.name,
                    exercise_equipment=equip_names,
                    exercise_gif_url=getattr(ex, 'gif_url', None),
                    body_parts_targeted=muscle_names,
                    planned_sets=sets,
                    planned_reps=reps,
                    planned_weight=suggested_weight,
                    is_compound=is_compound_ex,
                    order=order,
                ))

        # Limit total exercises
        if len(exercises) > max_ex:
            exercises = exercises[:max_ex]
        elif len(exercises) < min_ex and requested_body_parts:
            # Try to fill with any exercises targeting requested body parts
            self._fill_missing_exercises(exercises, request, min_ex, goal_config, order)

        if len(exercises) < min_ex:
            self._fill_from_popular_exercises(exercises, request, min_ex, goal_config, order)

        # Generate a name
        goal_labels = {
            "strength": "Strength",
            "hypertrophy": "Hypertrophy",
            "endurance": "Endurance",
            "general_fitness": "General Fitness",
        }
        split_labels = {
            "push_pull_legs": "PPL",
            "upper_lower": "Upper/Lower",
            "full_body": "Full Body",
            "balanced": "Balanced",
        }
        goal_label = goal_labels.get(request.goal, "Workout")
        split_label = split_labels.get(request.split_type, "")
        workout_name = f"{goal_label} {split_label}".strip()

        # Estimate duration
        est_duration = len(exercises) * 5 + 5  # ~5 min per exercise + warmup

        return WorkoutEngineResponse(
            id=str(uuid.uuid4()),
            name=workout_name,
            split_type=request.split_type,
            goal=request.goal,
            duration_minutes=request.duration_minutes,
            exercises=exercises,
            total_exercises=len(exercises),
            estimated_duration_minutes=est_duration,
            source="deterministic_engine",
        )

    def _get_exercise_count(self, duration_minutes: int) -> Tuple[int, int]:
        """Get min/max exercise count for a given duration."""
        closest = min(DURATION_EXERCISE_COUNT.keys(), key=lambda k: abs(k - duration_minutes))
        return DURATION_EXERCISE_COUNT[closest]

    def _expand_muscle_terms(self, terms: List[str]) -> List[str]:
        """Expand broad UI/body-part terms into likely DB muscle names."""
        expanded: List[str] = []
        for term in terms or []:
            normalized = term.strip().lower()
            if not normalized:
                continue
            expanded.append(normalized)
            expanded.extend(MUSCLE_ALIASES.get(normalized, []))

        # Preserve order while deduplicating.
        seen = set()
        return [t for t in expanded if not (t in seen or seen.add(t))]

    def _matches_any_muscle_term(self, muscle: str, terms: List[str]) -> bool:
        lower = muscle.lower()
        return any(term in lower or lower in term for term in terms)

    def _query_exercises(
        self,
        target_muscles: List[str],
        equipment: List[str],
        is_compound: bool,
        experience_level: str,
        limit: int,
    ) -> List[ExerciseLibrary]:
        """Query the real exercise library by muscle groups and equipment."""
        if not target_muscles:
            return []

        target_muscles = self._expand_muscle_terms(target_muscles)

        # Find matching muscle groups in DB
        muscle_group_records = (
            self.db.query(MuscleGroup)
            .filter(or_(*[MuscleGroup.name.ilike(f"%{m}%") for m in target_muscles]))
            .all()
        )
        muscle_group_ids = [mg.id for mg in muscle_group_records]

        if not muscle_group_ids:
            return []

        # Query ExerciseLibrary through ExerciseMuscleGroup junction
        query = (
            self.db.query(ExerciseLibrary)
            .options(
                joinedload(ExerciseLibrary.category),
                joinedload(ExerciseLibrary.muscle_groups).joinedload(ExerciseMuscleGroup.muscle_group),
                joinedload(ExerciseLibrary.equipment).joinedload(ExerciseEquipment.equipment),
            )
            .join(ExerciseMuscleGroup, ExerciseLibrary.id == ExerciseMuscleGroup.exercise_id)
            .filter(
                ExerciseLibrary.is_active == True,
                ExerciseMuscleGroup.muscle_group_id.in_(muscle_group_ids),
                ExerciseLibrary.is_compound == is_compound,
            )
            .distinct()
        )

        # Filter by equipment if specified
        if equipment:
            normalized_equipment = [e.strip().lower() for e in equipment if e and e.strip()]
            if not normalized_equipment:
                return []
            equipment_records = (
                self.db.query(EquipmentType)
                .filter(or_(*[EquipmentType.name.ilike(f"%{e}%") for e in normalized_equipment]))
                .all()
            )
            equip_ids = [eq.id for eq in equipment_records]
            if equip_ids:
                query = query.join(ExerciseEquipment, ExerciseLibrary.id == ExerciseEquipment.exercise_id).filter(
                    ExerciseEquipment.equipment_id.in_(equip_ids)
                )

        # Order by popularity and limit
        exercises = (
            query.order_by(ExerciseLibrary.popularity_score.desc())
            .limit(limit)
            .all()
        )

        # Deduplicate by ID
        seen = set()
        unique_exercises = []
        for ex in exercises:
            if ex.id not in seen:
                seen.add(ex.id)
                unique_exercises.append(ex)

        return unique_exercises

    def _get_progressive_overload(
        self,
        user_id: Optional[uuid.UUID],
        exercise_name: str,
        goal: str,
    ) -> Optional[str]:
        """Check user's workout history and suggest progressive overload."""
        if not user_id:
            return None

        # Query recent history for this exercise
        seven_days_ago = datetime.utcnow() - timedelta(days=7)
        recent = (
            self.db.query(CompletedWorkoutExercise)
            .join(CompletedWorkout, CompletedWorkoutExercise.completed_workout_id == CompletedWorkout.id)
            .filter(
                CompletedWorkout.user_id == user_id,
                CompletedWorkoutExercise.exercise_name.ilike(f"%{exercise_name}%"),
                CompletedWorkout.end_time >= seven_days_ago,
            )
            .order_by(CompletedWorkout.end_time.desc())
            .first()
        )

        if not recent:
            return None

        # Try to get weight from the sets
        if hasattr(recent, 'sets') and recent.sets:
            weights = []
            for s in recent.sets:
                if hasattr(s, 'weight') and s.weight:
                    try:
                        w = float(s.weight)
                        weights.append(w)
                    except (ValueError, TypeError):
                        pass
            if weights:
                avg_weight = sum(weights) / len(weights)
                # Progressive overload: increase by 2.5kg for strength, 5% for hypertrophy
                if goal == "strength":
                    new_weight = avg_weight + 2.5
                elif goal in ("hypertrophy", "endurance"):
                    new_weight = avg_weight * 1.05
                else:
                    new_weight = avg_weight * 1.025

                return f"{new_weight:.1f}"

        return None

    def _fill_missing_exercises(
        self,
        exercises: List[GeneratedExercise],
        request: WorkoutEngineRequest,
        min_count: int,
        goal_config: Dict,
        current_order: int,
    ):
        """If we don't have enough exercises, fill with any matching exercises."""
        needed = min_count - len(exercises)
        if needed <= 0:
            return

        # Query ANY exercises matching body parts & equipment
        for bp in self._expand_muscle_terms(request.body_parts):
            if len(exercises) >= min_count:
                break
            more = self._query_exercises(
                target_muscles=[bp],
                equipment=request.equipment,
                is_compound=True,
                experience_level=request.experience_level,
                limit=needed,
            )
            for ex in more:
                if len(exercises) >= min_count:
                    break
                if not any(e.exercise_id == str(ex.id) for e in exercises):
                    current_order += 1
                    equip_names = []
                    if hasattr(ex, 'equipment') and ex.equipment:
                        for ee in ex.equipment:
                            if hasattr(ee, 'equipment') and ee.equipment:
                                equip_names.append(ee.equipment.name)
                    muscle_names = []
                    if hasattr(ex, 'muscle_groups') and ex.muscle_groups:
                        for emg in ex.muscle_groups:
                            if hasattr(emg, 'muscle_group') and emg.muscle_group:
                                muscle_names.append(emg.muscle_group.name)
                    exercises.append(GeneratedExercise(
                        exercise_id=str(ex.id),
                        exercise_name=ex.name,
                        exercise_equipment=equip_names,
                        exercise_gif_url=getattr(ex, 'gif_url', None),
                        body_parts_targeted=muscle_names,
                        planned_sets=goal_config["default_sets"],
                        planned_reps=goal_config["default_reps"],
                        planned_weight=None,
                        is_compound=getattr(ex, 'is_compound', False),
                        order=current_order,
                    ))

    def _fill_from_popular_exercises(
        self,
        exercises: List[GeneratedExercise],
        request: WorkoutEngineRequest,
        min_count: int,
        goal_config: Dict,
        current_order: int,
    ):
        """Last-resort deterministic fallback: popular active exercises, optionally equipment-filtered."""
        if len(exercises) >= min_count:
            return

        query = self.db.query(ExerciseLibrary).options(
            joinedload(ExerciseLibrary.muscle_groups).joinedload(ExerciseMuscleGroup.muscle_group),
            joinedload(ExerciseLibrary.equipment).joinedload(ExerciseEquipment.equipment),
        ).filter(ExerciseLibrary.is_active == True)

        if request.equipment:
            normalized_equipment = [e.strip().lower() for e in request.equipment if e and e.strip()]
            if not normalized_equipment:
                return
            equipment_records = (
                self.db.query(EquipmentType)
                .filter(or_(*[EquipmentType.name.ilike(f"%{e}%") for e in normalized_equipment]))
                .all()
            )
            equip_ids = [eq.id for eq in equipment_records]
            if equip_ids:
                query = query.join(ExerciseEquipment, ExerciseLibrary.id == ExerciseEquipment.exercise_id).filter(
                    ExerciseEquipment.equipment_id.in_(equip_ids)
                )

        for ex in query.order_by(ExerciseLibrary.is_compound.desc(), ExerciseLibrary.popularity_score.desc()).limit(min_count * 3).all():
            if len(exercises) >= min_count:
                break
            if any(e.exercise_id == str(ex.id) for e in exercises):
                continue

            current_order += 1
            equip_names = [ee.equipment.name for ee in (ex.equipment or []) if getattr(ee, 'equipment', None)]
            muscle_names = [emg.muscle_group.name for emg in (ex.muscle_groups or []) if getattr(emg, 'muscle_group', None)]
            is_compound = getattr(ex, 'is_compound', False)
            exercises.append(GeneratedExercise(
                exercise_id=str(ex.id),
                exercise_name=ex.name,
                exercise_equipment=equip_names,
                exercise_gif_url=getattr(ex, 'gif_url', None),
                body_parts_targeted=muscle_names,
                planned_sets=goal_config["compound_sets"] if is_compound else goal_config["isolation_sets"],
                planned_reps=goal_config["compound_reps"] if is_compound else goal_config["isolation_reps"],
                planned_weight=None,
                is_compound=is_compound,
                order=current_order,
            ))