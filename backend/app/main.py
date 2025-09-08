from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from app.api.v1.endpoints import plans # Existing planned workout router
from app.api.v1.endpoints import workouts # New completed workout router
from app.api.v1.endpoints import user
from app.api.v1.endpoints import auth
from app.api.v1.endpoints import posts # New posts router
from app.api.v1.endpoints import nutrition # New nutrition router
from app.api.v1.endpoints import meal_plans # NEW: Import meal_plans router
from app.api.v1.endpoints import meals # NEW: Import meals router
from app.api.v1.endpoints import shop # NEW: Import shop router
from app.api.v1.endpoints import challenges # NEW: Import challenges router
from app.database.base import Base, engine # Imports Base and engine
import app.models_db # This import ensures all models in models_db.py are registered with Base
from app.middleware.logger import LoggerMiddleware
import cloudinary
from app.core.config import settings


load_dotenv()

cloudinary.config(
    cloud_name=settings.CLOUDINARY_CLOUD_NAME,
    api_key=settings.CLOUDINARY_API_KEY,
    api_secret=settings.CLOUDINARY_API_SECRET,
    secure=True
)
origins = [
    '*'
]

##Creates tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Fitnation Backend",
    description="Backend of Fitnation App",
    version="0.1.0",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins = origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(plans.router, prefix="/api/v1/workouts/plans", tags=["Workout Plans"]) # Updated prefix and tag
app.include_router(workouts.router, prefix="/api/v1/workouts", tags=["Workout Sessions"]) # Updated prefix and tag
app.include_router(meal_plans.router, prefix="/api/v1/meal_plans", tags=["Meal Plans"]) # NEW: Include meal_plans router
app.include_router(meals.router, prefix="/api/v1/meals", tags=["Meals"]) # NEW: Include meals router
app.include_router(shop.router, prefix="/api/v1/shop", tags=["Shop"]) # NEW: Include shop router
app.include_router(challenges.router, prefix="/api/v1", tags=["Challenges"]) # Fixed: challenges router has its own /api/v1 paths
app.include_router(user.router, prefix="/api/v1/users", tags=["users"])
app.include_router(auth.router,prefix="/api/v1/auth",tags=["auth"])
app.include_router(posts.router, prefix="/api/v1/posts", tags=["posts"]) # Include new posts router
app.include_router(nutrition.router, prefix="/api/v1/nutrition", tags=["nutrition"]) # Include new nutrition router
# app.include_router(exercise.router,prefix="/api/v1/exercises",tags=["exercises"])
# app.include_router(workoutHistory.router,prefix="/api/v1/workoutHistory",tags=["workoutHistory"])
app.add_middleware(LoggerMiddleware)


@app.get("/")
def root():
    return {"message": "Welcome to Fitnation Backend"}


# uvicorn app.main:app --reload
