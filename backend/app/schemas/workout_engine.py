from pydantic import BaseModel, Field
from typing import List, Optional
from uuid import UUID
from datetime import datetime


class WorkoutEngineRequest(BaseModel):
    """Request schema for the deterministic workout engine."""
    goal: str = Field(..., description="Fitness goal: strength, hypertrophy, endurance, general_fitness")
    split_type: str = Field("balanced", description="Split type: balanced, push_pull_legs, upper_lower, full_body")
    body_parts: List[str] = Field(default_factory=list, description="Target body parts (e.g., chest, back, legs)")
    equipment: List[str] = Field(default_factory=list, description="Available equipment (e.g., barbell, dumbbell, bodyweight)")
    duration_minutes: int = Field(45, ge=15, le=180, description="Target workout duration in minutes")
    experience_level: str = Field("intermediate", description="Experience level: beginner, intermediate, advanced")
    exercise_count: Optional[int] = Field(None, ge=3, le=12, description="Override number of exercises")
    user_id: Optional[UUID] = Field(None, description="User ID for progressive overload from history")


class GeneratedExercise(BaseModel):
    """An exercise selected by the deterministic engine from the real catalog."""
    exercise_id: str
    exercise_name: str
    exercise_equipment: List[str] = Field(default_factory=list)
    exercise_gif_url: Optional[str] = None
    body_parts_targeted: List[str] = Field(default_factory=list)
    planned_sets: int = 3
    planned_reps: int = 10
    planned_weight: Optional[str] = None
    is_compound: bool = False
    order: int = 0


class WorkoutEngineResponse(BaseModel):
    """Response from the deterministic workout engine."""
    id: str
    name: str
    split_type: str
    goal: str
    duration_minutes: int
    exercises: List[GeneratedExercise]
    generated_at: datetime = Field(default_factory=datetime.utcnow)
    source: str = "deterministic_engine"
    total_exercises: int = 0
    estimated_duration_minutes: int = 0


# --- Split type configurations ---
SPLIT_CONFIGS = {
    "push_pull_legs": {
        "push": {
            "muscles": ["chest", "shoulders", "triceps"],
            "compound_first": True,
            "push_vs_pull_ratio": 0.6,
        },
        "pull": {
            "muscles": ["back", "biceps", "rear deltoids"],
            "compound_first": True,
            "push_vs_pull_ratio": 0.4,
        },
        "legs": {
            "muscles": ["quadriceps", "hamstrings", "glutes", "calves"],
            "compound_first": True,
        },
    },
    "upper_lower": {
        "upper": {
            "muscles": ["chest", "back", "shoulders", "biceps", "triceps"],
            "compound_first": True,
            "push_vs_pull_ratio": 0.5,
        },
        "lower": {
            "muscles": ["quadriceps", "hamstrings", "glutes", "calves", "abs"],
            "compound_first": True,
        },
    },
    "full_body": {
        "full": {
            "muscles": ["chest", "back", "shoulders", "legs", "arms", "abs"],
            "compound_first": True,
        },
    },
    "balanced": {
        "balanced": {
            "muscles": ["chest", "back", "shoulders", "legs", "arms"],
            "compound_first": True,
        },
    },
}


# Broad UI words and ExerciseDB-ish body parts mapped to likely normalized muscle names.
# The deterministic engine expands these before querying the DB so plans do not fail
# just because the UI says "legs" while the DB stores "quadriceps", "hamstrings", etc.
MUSCLE_ALIASES = {
    "arms": ["biceps", "triceps", "forearms"],
    "arm": ["biceps", "triceps", "forearms"],
    "legs": ["quadriceps", "hamstrings", "glutes", "calves"],
    "leg": ["quadriceps", "hamstrings", "glutes", "calves"],
    "upper legs": ["quadriceps", "hamstrings", "glutes"],
    "lower legs": ["calves"],
    "back": ["back", "lats", "traps", "rear deltoids"],
    "chest": ["chest", "pectorals"],
    "shoulders": ["shoulders", "deltoids", "rear deltoids"],
    "shoulder": ["shoulders", "deltoids", "rear deltoids"],
    "core": ["abs", "abdominals", "obliques"],
    "waist": ["abs", "abdominals", "obliques"],
}


# Default sets/reps by goal
GOAL_CONFIGS = {
    "strength": {"default_sets": 5, "default_reps": 5, "compound_sets": 5, "compound_reps": 5, "isolation_sets": 3, "isolation_reps": 8},
    "hypertrophy": {"default_sets": 4, "default_reps": 10, "compound_sets": 4, "compound_reps": 8, "isolation_sets": 3, "isolation_reps": 12},
    "endurance": {"default_sets": 3, "default_reps": 15, "compound_sets": 3, "compound_reps": 12, "isolation_sets": 3, "isolation_reps": 15},
    "general_fitness": {"default_sets": 3, "default_reps": 10, "compound_sets": 3, "compound_reps": 10, "isolation_sets": 3, "isolation_reps": 12},
}

# Exercise count estimates by duration and split
DURATION_EXERCISE_COUNT = {
    15: (3, 4),
    30: (4, 6),
    45: (6, 8),
    60: (8, 10),
    90: (10, 12),
    120: (12, 14),
}

# Equipment priority for exercise selection
EQUIPMENT_PRIORITY = {
    "barbell": 100,
    "dumbbell": 80,
    "cable": 70,
    "machine": 60,
    "kettlebell": 50,
    "band": 40,
    "bodyweight": 30,
    "medicine ball": 35,
    "ez bar": 65,
    "trap bar": 75,
    "smith machine": 55,
}