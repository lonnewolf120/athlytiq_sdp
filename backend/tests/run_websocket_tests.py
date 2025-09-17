#!/usr/bin/env python3
"""
Test runner for WebSocket chat functionality
"""

import asyncio
import sys
import os
from pathlib import Path

# Add the backend directory to the Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

import pytest
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.database.base import Base
from app.database.connection import get_database_url

# Test database URL (use in-memory SQLite for testing)
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest.fixture(scope="session")
async def test_engine():
    """Create test database engine."""
    engine = create_async_engine(
        TEST_DATABASE_URL,
        echo=False,
        future=True
    )
    
    # Create all tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    yield engine
    
    # Clean up
    await engine.dispose()

@pytest.fixture
async def db_session(test_engine):
    """Create a test database session."""
    async_session = sessionmaker(
        test_engine, class_=AsyncSession, expire_on_commit=False
    )
    
    async with async_session() as session:
        yield session
        await session.rollback()

def run_tests():
    """Run the WebSocket chat tests."""
    print("Running WebSocket Chat Tests...")
    print("=" * 50)
    
    # Run pytest with the WebSocket test file
    test_file = Path(__file__).parent / "test_websocket_chat.py"
    
    pytest_args = [
        str(test_file),
        "-v",  # Verbose output
        "--tb=short",  # Short traceback format
        "--asyncio-mode=auto",  # Enable asyncio mode
        "-x",  # Stop on first failure
    ]
    
    exit_code = pytest.main(pytest_args)
    
    if exit_code == 0:
        print("\n" + "=" * 50)
        print("✅ All WebSocket tests passed!")
    else:
        print("\n" + "=" * 50)
        print("❌ Some WebSocket tests failed!")
    
    return exit_code

if __name__ == "__main__":
    exit_code = run_tests()
    sys.exit(exit_code)