from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta, timezone
from typing import Optional
import hashlib
import os # No longer needed for getenv for these settings
from dotenv import load_dotenv # No longer needed here

load_dotenv() # Not needed, rely on config.py

from app.core.config import settings # Import the settings object

secret_key = os.getenv("SECRET_KEY", "dummy") # Use settings.SECRET_KEY
print(secret_key) # This can be removed or adapted if still needed for debugging settings.SECRET_KEY
algo = os.getenv("ALGORITHM", "HS256") # Use settings.ALGORITHM
token_expire_minutes = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30000)) # Use settings.ACCESS_TOKEN_EXPIRE_MINUTES

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)) # Use settings
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM) # Use settings

def hash_token(token:str) -> str :
    # refresh_token_hash = jwt.encode(token, settings.SECRET_KEY, algorithm=settings.ALGORITHM) # Use settings
    refresh_token_hash = hashlib.sha256(token.encode()).hexdigest()
    return refresh_token_hash

def decode_token(token:str) -> dict:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]) # Use settings, and algorithm should be a list
    except JWTError:
        return None
