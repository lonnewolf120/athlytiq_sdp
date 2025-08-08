from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from uuid import UUID

class LoginRequest(BaseModel):
    email: str
    password: str

class Token(BaseModel):
    access_token:str
    refresh_token:str
    token_type:str = 'bearer'

class TokenData(BaseModel):
    email: str
    user_id: str
    username: str

class PasswordResetRequest(BaseModel):
    email: str

class PasswordReset(BaseModel):
    token: str
    password: str

class GoogleOAuthToken(BaseModel):
    token: str
