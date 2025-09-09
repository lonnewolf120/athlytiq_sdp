"""add trainer features

Revision ID: 9f8a2d4b3e1c
Revises: previous_revision_id
Create Date: 2025-08-31 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '9f8a2d4b3e1c'
down_revision = 'previous_revision_id'  # Update this to your last migration
branch_labels = None
depends_on = None


def create_trainer_specialization_enum():
    return postgresql.ENUM(
        'weight_training',
        'cardio',
        'yoga',
        'pilates',
        'crossfit',
        'martial_arts',
        'dance',
        'sports',
        'rehabilitation',
        'nutrition',
        name='trainerspecialization'
    )


def create_application_status_enum():
    return postgresql.ENUM(
        'pending',
        'in_review',
        'approved',
        'rejected',
        'additional_info_needed',
        name='trainerapplicationstatus'
    )


def upgrade():
    # Create enums
    trainer_specialization = create_trainer_specialization_enum()
    trainer_specialization.create(op.get_bind())

    application_status = create_application_status_enum()
    application_status.create(op.get_bind())

    # Create trainer applications table
    op.create_table(
        'trainer_applications',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('full_name', sa.String(), nullable=False),
        sa.Column('bio', sa.Text(), nullable=False),
        sa.Column('years_of_experience', sa.Integer(), nullable=False),
        sa.Column('specializations', postgresql.ARRAY(trainer_specialization), nullable=False),
        sa.Column('certification_details', sa.Text(), nullable=False),
        sa.Column('id_document_url', sa.String(), nullable=False),
        sa.Column('certification_document_urls', postgresql.ARRAY(sa.String()), nullable=False),
        sa.Column('profile_photo_url', sa.String(), nullable=False),
        sa.Column('contact_email', sa.String(), nullable=False),
        sa.Column('phone_number', sa.String(), nullable=False),
        sa.Column('social_links', sa.Text()),
        sa.Column('status', application_status, default='pending'),
        sa.Column('feedback', sa.Text()),
        sa.Column('reviewed_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('reviewed_at', sa.DateTime()),
        sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), default=sa.func.now(), onupdate=sa.func.now()),
    )

    # Create trainer posts table
    op.create_table(
        'trainer_posts',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('trainer_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('title', sa.String(), nullable=False),
        sa.Column('content', sa.Text(), nullable=False),
        sa.Column('category', trainer_specialization, nullable=False),
        sa.Column('tags', postgresql.ARRAY(sa.String()), default=[]),
        sa.Column('image_urls', postgresql.ARRAY(sa.String()), default=[]),
        sa.Column('likes_count', sa.Integer(), default=0),
        sa.Column('comments_count', sa.Integer(), default=0),
        sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), default=sa.func.now(), onupdate=sa.func.now()),
    )

    # Create trainer post comments table
    op.create_table(
        'trainer_post_comments',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('post_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('trainer_posts.id')),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('content', sa.Text(), nullable=False),
        sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
    )

    # Create trainer post likes table
    op.create_table(
        'trainer_post_likes',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('post_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('trainer_posts.id')),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
    )

    # Create plan verifications table
    op.create_table(
        'plan_verifications',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('plan_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('plan_type', sa.String(), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('trainer_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('status', sa.String(), default='pending'),
        sa.Column('feedback', sa.Text()),
        sa.Column('is_approved', sa.Boolean()),
        sa.Column('suggestions', postgresql.ARRAY(sa.String())),
        sa.Column('notes', sa.Text()),
        sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
        sa.Column('completed_at', sa.DateTime()),
    )

    # Create trainer chat rooms table
    op.create_table(
        'trainer_chat_rooms',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('trainer_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
        sa.Column('last_message', sa.Text()),
        sa.Column('last_message_at', sa.DateTime()),
        sa.Column('trainer_unread_count', sa.Integer(), default=0),
        sa.Column('user_unread_count', sa.Integer(), default=0),
    )

    # Create trainer chats table
    op.create_table(
        'trainer_chats',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('room_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('trainer_chat_rooms.id')),
        sa.Column('sender_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id')),
        sa.Column('message', sa.Text(), nullable=False),
        sa.Column('attachment_urls', postgresql.ARRAY(sa.String()), default=[]),
        sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
        sa.Column('read_at', sa.DateTime()),
    )

    # Create indexes
    op.create_index('ix_trainer_applications_user_id', 'trainer_applications', ['user_id'])
    op.create_index('ix_trainer_posts_trainer_id', 'trainer_posts', ['trainer_id'])
    op.create_index('ix_trainer_post_comments_post_id', 'trainer_post_comments', ['post_id'])
    op.create_index('ix_trainer_post_likes_post_id', 'trainer_post_likes', ['post_id'])
    op.create_index('ix_plan_verifications_plan_id', 'plan_verifications', ['plan_id'])
    op.create_index('ix_trainer_chat_rooms_trainer_id', 'trainer_chat_rooms', ['trainer_id'])
    op.create_index('ix_trainer_chat_rooms_user_id', 'trainer_chat_rooms', ['user_id'])
    op.create_index('ix_trainer_chats_room_id', 'trainer_chats', ['room_id'])


def downgrade():
    # Drop tables
    op.drop_table('trainer_chats')
    op.drop_table('trainer_chat_rooms')
    op.drop_table('plan_verifications')
    op.drop_table('trainer_post_likes')
    op.drop_table('trainer_post_comments')
    op.drop_table('trainer_posts')
    op.drop_table('trainer_applications')

    # Drop enums
    op.execute('DROP TYPE trainerapplicationstatus')
    op.execute('DROP TYPE trainerspecialization')
