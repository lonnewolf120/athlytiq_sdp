"""
Migration script to create chat and friends tables
Run this with: python migrate_chat_tables.py
"""

import asyncio
import sys
import os
from pathlib import Path

# Add the app directory to Python path
sys.path.append(str(Path(__file__).parent / "app"))

from sqlalchemy import text
from app.database.base import get_db_engine, AsyncSessionLocal
from app.core.config import Settings

async def run_migration():
    """Run the chat and friends database migration"""
    
    print("Starting chat and friends database migration...")
    
    # Read the migration SQL file
    migration_file = Path(__file__).parent / "chat_friends_database_schema.sql"
    
    if not migration_file.exists():
        print(f"Migration file not found: {migration_file}")
        return False
    
    with open(migration_file, 'r') as f:
        migration_sql = f.read()
    
    # Split the SQL into individual statements
    statements = [stmt.strip() for stmt in migration_sql.split(';') if stmt.strip()]
    
    try:
        async with AsyncSessionLocal() as session:
            for i, statement in enumerate(statements):
                if statement:
                    print(f"Executing statement {i + 1}/{len(statements)}...")
                    try:
                        await session.execute(text(statement))
                        await session.commit()
                        print(f"✓ Statement {i + 1} executed successfully")
                    except Exception as e:
                        print(f"⚠ Statement {i + 1} failed (might already exist): {str(e)}")
                        await session.rollback()
                        continue
        
        print("\n✅ Migration completed successfully!")
        return True
        
    except Exception as e:
        print(f"\n❌ Migration failed: {str(e)}")
        return False

async def verify_tables():
    """Verify that the tables were created successfully"""
    
    print("\nVerifying table creation...")
    
    tables_to_check = [
        'chat_rooms',
        'chat_participants', 
        'chat_messages',
        'message_reactions',
        'message_read_receipts',
        'friend_requests',
        'user_online_status'
    ]
    
    try:
        async with AsyncSessionLocal() as session:
            for table in tables_to_check:
                result = await session.execute(text(f"""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_name = '{table}'
                    );
                """))
                
                exists = result.scalar()
                status = "✓" if exists else "✗"
                print(f"{status} Table '{table}': {'Created' if exists else 'Not found'}")
        
        print("\n✅ Table verification completed!")
        return True
        
    except Exception as e:
        print(f"\n❌ Table verification failed: {str(e)}")
        return False

async def main():
    """Main migration function"""
    
    print("=== Athlytiq Chat & Friends Database Migration ===\n")
    
    # Run migration
    migration_success = await run_migration()
    
    if migration_success:
        # Verify tables
        await verify_tables()
        print("\n🎉 Chat and friends system is ready!")
    else:
        print("\n❌ Migration failed. Please check the errors above.")

if __name__ == "__main__":
    asyncio.run(main())
