import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database.base import Base
from app.main import app
from app.core.config import settings
from app.crud.user import get_password_reset_token, get_User_by_email
from app.models_db import User
from app.core.auth import get_password_hash, verify_password
from unittest.mock import patch

# Setup a test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_db.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(name="db_session")
def db_session_fixture():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(name="client")
def client_fixture(db_session):
    def override_get_db():
        yield db_session
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()

@pytest.fixture
def test_user_data():
    return {
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpassword",
        "role": "user"
    }

@pytest.fixture
def registered_user(client, test_user_data):
    response = client.post("/api/v1/auth/register", json=test_user_data)
    assert response.status_code == 200
    return response.json()

@patch('app.core.email.send_email')
def test_forgot_password_success(mock_send_email, client, db_session, registered_user):
    email = registered_user["email"]
    response = client.post("/api/v1/auth/forgot-password", json={"email": email})
    assert response.status_code == 200
    assert response.json() == {"message": "Password reset email sent"}
    mock_send_email.assert_called_once()

    # Verify token is created in DB
    user_id = registered_user["id"]
    token_record = get_password_reset_token(db_session, user_id=user_id)
    assert token_record is not None
    assert token_record.user_id == user_id
    assert token_record.token is not None

@patch('app.core.email.send_email')
def test_forgot_password_user_not_found(mock_send_email, client):
    response = client.post("/api/v1/auth/forgot-password", json={"email": "nonexistent@example.com"})
    assert response.status_code == 404
    assert response.json() == {"detail": "User not found"}
    mock_send_email.assert_not_called()

@patch('app.core.email.send_email')
def test_reset_password_success(mock_send_email, client, db_session, registered_user):
    email = registered_user["email"]
    
    # Request password reset to get a token
    response = client.post("/api/v1/auth/forgot-password", json={"email": email})
    assert response.status_code == 200
    
    # Manually retrieve the token from the database for testing
    user_id = registered_user["id"]
    token_record = get_password_reset_token(db_session, user_id=user_id)
    reset_token = token_record.token
    
    new_password = "newtestpassword"
    response = client.post(
        "/api/v1/auth/reset-password",
        json={"token": reset_token, "password": new_password}
    )
    assert response.status_code == 200
    assert response.json() == {"message": "Password reset successfully"}

    # Verify password is changed
    user = get_User_by_email(db_session, email)
    assert user is not None
    assert verify_password(new_password, user.password_hash)

    # Verify token is deleted
    deleted_token = get_password_reset_token(db_session, token=reset_token)
    assert deleted_token is None

@patch('app.core.email.send_email')
def test_reset_password_invalid_token(mock_send_email, client):
    response = client.post(
        "/api/v1/auth/reset-password",
        json={"token": "invalid_token", "password": "newpassword"}
    )
    assert response.status_code == 400
    assert response.json() == {"detail": "Invalid token"}

@patch('app.core.email.send_email')
def test_reset_password_expired_token(mock_send_email, client, db_session, registered_user):
    email = registered_user["email"]
    
    # Request password reset to get a token
    response = client.post("/api/v1/auth/forgot-password", json={"email": email})
    assert response.status_code == 200
    
    # Manually retrieve the token and set its expiry to past
    user_id = registered_user["id"]
    token_record = get_password_reset_token(db_session, user_id=user_id)
    token_record.expires_at = datetime.utcnow() - timedelta(hours=1)
    db_session.add(token_record)
    db_session.commit()
    
    reset_token = token_record.token
    new_password = "newtestpassword"
    response = client.post(
        "/api/v1/auth/reset-password",
        json={"token": reset_token, "password": new_password}
    )
    assert response.status_code == 400
    assert response.json() == {"detail": "Token expired"}

    # Verify password is NOT changed
    user = get_User_by_email(db_session, email)
    assert user is not None
    assert not verify_password(new_password, user.password_hash) # Should still be old password
