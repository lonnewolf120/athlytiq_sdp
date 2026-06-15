import os
import uuid
from datetime import datetime, timedelta
from types import SimpleNamespace
from unittest.mock import Mock, patch

import pytest
from fastapi.testclient import TestClient

os.environ["SKIP_DB_CREATE_ALL"] = "1"

from app.api import dependencies
from app.api import deps
from app.database import base as database_base
from app.main import app
from app.schemas.workout_engine import GeneratedExercise, WorkoutEngineResponse


@pytest.fixture(name="test_user")
def test_user_fixture():
    return SimpleNamespace(id=uuid.uuid4(), username="nonai_user", email="nonai@example.com")


@pytest.fixture(name="client")
def client_fixture(test_user):
    def override_get_db():
        yield Mock(name="db_session")

    def override_current_user():
        return test_user

    app.dependency_overrides[database_base.get_db] = override_get_db
    app.dependency_overrides[dependencies.get_db] = override_get_db
    app.dependency_overrides[deps.get_db] = override_get_db
    app.dependency_overrides[dependencies.get_current_user] = override_current_user
    app.dependency_overrides[deps.get_current_user] = override_current_user
    app.dependency_overrides[deps.get_current_active_user] = override_current_user

    with TestClient(app) as c:
        yield c

    app.dependency_overrides.clear()


def test_workout_engine_config_endpoints(client):
    split_response = client.get("/api/v1/workouts/split-types")
    assert split_response.status_code == 200
    assert "balanced" in split_response.json()["split_types"]

    goal_response = client.get("/api/v1/workouts/goal-configs")
    assert goal_response.status_code == 200
    assert "hypertrophy" in goal_response.json()["goals"]


def test_generate_engine_workout_api_contract(client, test_user):
    workout_id = uuid.uuid4()
    exercise_id = uuid.uuid4()
    expected_response = WorkoutEngineResponse(
        id=str(workout_id),
        name="Hypertrophy Balanced",
        split_type="balanced",
        goal="hypertrophy",
        duration_minutes=45,
        exercises=[
            GeneratedExercise(
                exercise_id=str(exercise_id),
                exercise_name="Bench Press",
                exercise_equipment=["barbell"],
                body_parts_targeted=["chest"],
                planned_sets=4,
                planned_reps=8,
                is_compound=True,
                order=1,
            )
        ],
        total_exercises=1,
        estimated_duration_minutes=10,
    )

    with patch("app.api.v1.endpoints.workout_engine.WorkoutEngine") as engine_cls:
        engine = engine_cls.return_value
        engine.generate.return_value = expected_response

        response = client.post(
            "/api/v1/workouts/generate-engine",
            json={
                "goal": "hypertrophy",
                "split_type": "balanced",
                "body_parts": ["chest"],
                "equipment": ["barbell"],
                "duration_minutes": 45,
                "experience_level": "intermediate",
            },
        )

    assert response.status_code == 200
    data = response.json()
    assert data["source"] == "deterministic_engine"
    assert data["exercises"][0]["exercise_id"] == str(exercise_id)
    assert data["exercises"][0]["planned_sets"] == 4
    generated_request = engine.generate.call_args.args[0]
    assert generated_request.user_id == test_user.id


def test_nutrition_barcode_lookup_normalizes_open_food_facts(client):
    mock_response = Mock()
    mock_response.raise_for_status.return_value = None
    mock_response.json.return_value = {
        "status": 1,
        "product": {
            "product_name": "Test Protein Bar",
            "brands": "Athlytiq Foods",
            "serving_size": "50 g",
            "nutriments": {
                "energy-kcal_100g": 400,
                "proteins_100g": 20,
                "carbohydrates_100g": 45,
                "fat_100g": 12,
            },
        },
    }

    with patch("app.api.v1.endpoints.nutrition.httpx.get", return_value=mock_response):
        response = client.post("/api/v1/nutrition/barcode-lookup", json={"barcode": "123456789"})

    assert response.status_code == 200
    data = response.json()
    assert data["found"] is True
    assert data["name"] == "Test Protein Bar"
    assert data["brand"] == "Athlytiq Foods"
    assert data["protein_g"] == 20


class _FakeQuery:
    def __init__(self, rows):
        self._rows = rows

    def filter(self, *_, **__):
        return self

    def order_by(self, *_, **__):
        return self

    def limit(self, *_):
        return self

    def all(self):
        return self._rows


class _FakeDb:
    def __init__(self, rows):
        self._rows = rows

    def query(self, *_):
        return _FakeQuery(self._rows)


def test_nutrition_favorites_and_history_summary(test_user):
    now = datetime.utcnow()
    rows = [
        SimpleNamespace(user_id=test_user.id, food_name="Oats", calories=200, protein_g=8, carbs_g=30, fat_g=4, serving_size="50g", meal_type="breakfast", log_date=now, created_at=now),
        SimpleNamespace(user_id=test_user.id, food_name="Oats", calories=220, protein_g=9, carbs_g=32, fat_g=5, serving_size="55g", meal_type="breakfast", log_date=now - timedelta(days=1), created_at=now),
        SimpleNamespace(user_id=test_user.id, food_name="Chicken", calories=300, protein_g=40, carbs_g=0, fat_g=8, serving_size="150g", meal_type="lunch", log_date=now, created_at=now),
    ]
    fake_db = _FakeDb(rows)

    def override_get_db():
        yield fake_db

    def override_current_user():
        return test_user

    app.dependency_overrides[database_base.get_db] = override_get_db
    app.dependency_overrides[deps.get_current_user] = override_current_user
    app.dependency_overrides[deps.get_current_active_user] = override_current_user

    with TestClient(app) as c:
        favorites = c.get("/api/v1/nutrition/favorites?limit=5")
        summary = c.get("/api/v1/nutrition/history-summary?days=7")

    app.dependency_overrides.clear()

    assert favorites.status_code == 200
    favorite_data = favorites.json()
    assert favorite_data[0]["food_name"] == "Oats"
    assert favorite_data[0]["count"] == 2
    assert favorite_data[0]["avg_calories"] == 210

    assert summary.status_code == 200
    summary_data = summary.json()
    assert summary_data["totals"]["calories"] == 720
    assert summary_data["by_meal_type"]["breakfast"]["protein_g"] == 17
    assert summary_data["by_meal_type"]["lunch"]["protein_g"] == 40