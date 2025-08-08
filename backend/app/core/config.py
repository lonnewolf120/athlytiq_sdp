from pydantic_settings import BaseSettings
from pydantic import ValidationError
class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int
    API_V1_STR: str = "/api/v1" # Added API version string
    EMAIL_USERNAME: str
    EMAIL_SENDER: str
    EMAIL_PASSWORD: str
    FRONTEND_URL: str
    EMAIL_HOST: str
    EMAIL_PORT: int
    CLOUDINARY_CLOUD_NAME:str
    CLOUDINARY_API_KEY:str
    CLOUDINARY_API_SECRET:str
    class Config:
        env_file = ".env"
        extra = "ignore"

try:
    Settings()
except ValidationError as exc:
    print(repr(exc.errors()[0]['type']))
    
settings = Settings()
