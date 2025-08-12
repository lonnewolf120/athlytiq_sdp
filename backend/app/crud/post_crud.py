from typing import Optional, List
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, case, cast, String
from app.models_db import Post, WorkoutPost, WorkoutPostExercise, ChallengePost, User, Profile, Comment, React, post_type_enum
from app.schemas.post_schemas import PostCreate, PostUpdate, PostType, ExerciseSchema
import uuid
from datetime import datetime

def create_post(db: Session, post_data: PostCreate, user_id: str):
    db_workout_post = None
    db_challenge_post = None

    # Handle WorkoutPost creation
    if post_data.workoutData:
        db_workout_post = WorkoutPost(
            workout_type=post_data.workoutData.workoutType,
            duration_minutes=post_data.workoutData.durationMinutes,
            calories_burned=post_data.workoutData.caloriesBurned,
            notes=post_data.workoutData.notes,
        )
        db.add(db_workout_post)
        db.flush() # Flush to get the ID for relationship

        # Add exercises to WorkoutPost
        for ex_data in post_data.workoutData.exercises:
            db_exercise = WorkoutPostExercise(
                workout_post_id=db_workout_post.id,
                exercise_id=ex_data.exerciseId,
                name=ex_data.name,
                gif_url=ex_data.gifUrl,
                body_parts=ex_data.bodyParts,
                equipments=ex_data.equipments,
                target_muscles=ex_data.targetMuscles,
                secondary_muscles=ex_data.secondaryMuscles,
                instructions=ex_data.instructions,
                image_url=ex_data.imageUrl,
                exercise_type=ex_data.exerciseType,
                keywords=ex_data.keywords,
                overview=ex_data.overview,
                video_url=ex_data.videoUrl,
                exercise_tips=ex_data.exerciseTips,
                variations=ex_data.variations,
                related_exercise_ids=ex_data.relatedExerciseIds,
                sets=ex_data.sets,
                reps=ex_data.reps,
                weight=ex_data.weight,
            )
            db.add(db_exercise)

    # Handle ChallengePost creation
    if post_data.challengeData:
        db_challenge_post = ChallengePost(
            title=post_data.challengeData.title,
            description=post_data.challengeData.description,
            start_date=post_data.challengeData.startDate,
            duration_days=post_data.challengeData.durationDays,
            cover_image_url=post_data.challengeData.coverImageUrl,
            participant_count=post_data.challengeData.participantCount,
        )
        db.add(db_challenge_post)
        db.flush() # Flush to get the ID for relationship

    # Create the main Post entry
    db_post = Post(
        user_id=user_id,
        content=post_data.content,
        media_url=post_data.mediaUrl,
        post_type=[pt for pt in post_data.postType], # PostType is str, Enum, so pt is already the string value
        workout_post_id=db_workout_post.id if db_workout_post else None,
        challenge_post_id=db_challenge_post.id if db_challenge_post else None,
    )
    db.add(db_post)
    db.commit()
    db.refresh(db_post)

    # Refresh relationships for nested data
    if db_workout_post:
        db.refresh(db_workout_post)
        db_post.workout_data = db_workout_post
    if db_challenge_post:
        db.refresh(db_challenge_post)
        db_post.challenge_data = db_challenge_post
    
    # Load author profile
    db_post.author = db.query(User).options(joinedload(User.profile)).filter(User.id == db_post.user_id).first()

    return db_post

def get_post(db: Session, post_id: str):
    return db.query(Post).options(
        joinedload(Post.author).joinedload(User.profile),
        joinedload(Post.workout_data).joinedload(WorkoutPost.exercises),
        joinedload(Post.challenge_data),
        joinedload(Post.comments).joinedload(Comment.author).joinedload(User.profile),
        joinedload(Post.reacts).joinedload(React.user).joinedload(User.profile)
    ).filter(Post.id == post_id).first()

def get_posts(db: Session, user_id: Optional[str] = None, post_types: Optional[List[PostType]] = None,
              skip: int = 0, limit: int = 100):
    query = db.query(Post).options(
        joinedload(Post.author).joinedload(User.profile),
        joinedload(Post.workout_data).joinedload(WorkoutPost.exercises),
        joinedload(Post.challenge_data),
        joinedload(Post.comments).joinedload(Comment.author).joinedload(User.profile),
        joinedload(Post.reacts).joinedload(React.user).joinedload(User.profile)
    )

    if user_id:
        query = query.filter(Post.user_id == user_id)
    
    if post_types:
        # Filter by any of the provided post_types
        query = query.filter(Post.post_type.overlap([pt.value for pt in post_types]))

    # Add counts for comments and reacts
    query = query.add_columns(
        func.count(Comment.id).filter(Comment.post_id == Post.id).label("comment_count"),
        func.count(React.post_id).filter(React.post_id == Post.id).label("react_count")
    ).outerjoin(Comment, Comment.post_id == Post.id).outerjoin(React, React.post_id == Post.id).group_by(Post.id)


    query = query.order_by(Post.created_at.desc()).offset(skip).limit(limit)
    
    # Execute query and map results to Post objects with counts
    results = query.all()
    
    posts_with_counts = []
    for post_obj, comment_count, react_count in results:
        post_obj.commentCount = comment_count
        post_obj.reactCount = react_count
        posts_with_counts.append(post_obj)

    return posts_with_counts


def update_post(db: Session, post_id: str, post_update: PostUpdate):
    db_post = db.query(Post).filter(Post.id == post_id).first()
    if not db_post:
        return None

    # Update main Post fields
    if post_update.content is not None:
        db_post.content = post_update.content
    if post_update.mediaUrl is not None:
        db_post.media_url = post_update.mediaUrl
    if post_update.postType is not None:
        db_post.post_type = [pt.value for pt in post_update.postType]

    # Handle nested WorkoutPost update
    if post_update.workoutData:
        if db_post.workout_data: # Update existing
            db_post.workout_data.workout_type = post_update.workoutData.workoutType
            db_post.workout_data.duration_minutes = post_update.workoutData.durationMinutes
            db_post.workout_data.calories_burned = post_update.workoutData.caloriesBurned
            db_post.workout_data.notes = post_update.workoutData.notes
            # For exercises, it's more complex: typically delete old and create new, or diff
            # For simplicity, let's assume full replacement for now
            db.query(WorkoutPostExercise).filter(WorkoutPostExercise.workout_post_id == db_post.workout_data.id).delete()
            for ex_data in post_update.workoutData.exercises:
                db_exercise = WorkoutPostExercise(
                    workout_post_id=db_post.workout_data.id,
                    exercise_id=ex_data.exerciseId,
                    name=ex_data.name,
                    gif_url=ex_data.gifUrl,
                    body_parts=ex_data.bodyParts,
                    equipments=ex_data.equipments,
                    target_muscles=ex_data.targetMuscles,
                    secondary_muscles=ex_data.secondaryMuscles,
                    instructions=ex_data.instructions,
                    image_url=ex_data.imageUrl,
                    exercise_type=ex_data.exerciseType,
                    keywords=ex_data.keywords,
                    overview=ex_data.overview,
                    video_url=ex_data.videoUrl,
                    exercise_tips=ex_data.exerciseTips,
                    variations=ex_data.variations,
                    related_exercise_ids=ex_data.relatedExerciseIds,
                    sets=ex_data.sets,
                    reps=ex_data.reps,
                    weight=ex_data.weight,
                )
                db.add(db_exercise)
        else: # Create new WorkoutPost
            db_workout_post = WorkoutPost(
                workout_type=post_update.workoutData.workoutType,
                duration_minutes=post_update.workoutData.durationMinutes,
                calories_burned=post_update.workoutData.caloriesBurned,
                notes=post_update.workoutData.notes,
            )
            db.add(db_workout_post)
            db.flush()
            db_post.workout_post_id = db_workout_post.id
            db_post.workout_data = db_workout_post
            for ex_data in post_update.workoutData.exercises:
                db_exercise = WorkoutPostExercise(
                    workout_post_id=db_workout_post.id,
                    exercise_id=ex_data.exerciseId,
                    name=ex_data.name,
                    gif_url=ex_data.gifUrl,
                    body_parts=ex_data.bodyParts,
                    equipments=ex_data.equipments,
                    target_muscles=ex_data.targetMuscles,
                    secondary_muscles=ex_data.secondaryMuscles,
                    instructions=ex_data.instructions,
                    image_url=ex_data.imageUrl,
                    exercise_type=ex_data.exerciseType,
                    keywords=ex_data.keywords,
                    overview=ex_data.overview,
                    video_url=ex_data.videoUrl,
                    exercise_tips=ex_data.exerciseTips,
                    variations=ex_data.variations,
                    related_exercise_ids=ex_data.relatedExerciseIds,
                    sets=ex_data.sets,
                    reps=ex_data.reps,
                    weight=ex_data.weight,
                )
                db.add(db_exercise)
    elif post_update.workoutData is None and db_post.workout_data: # Remove existing
        db.delete(db_post.workout_data)
        db_post.workout_post_id = None
        db_post.workout_data = None

    # Handle nested ChallengePost update
    if post_update.challengeData:
        if db_post.challenge_data: # Update existing
            db_post.challenge_data.title = post_update.challengeData.title
            db_post.challenge_data.description = post_update.challengeData.description
            db_post.challenge_data.start_date = post_update.challengeData.startDate
            db_post.challenge_data.duration_days = post_update.challengeData.durationDays
            db_post.challenge_data.cover_image_url = post_update.challengeData.coverImageUrl
            db_post.challenge_data.participant_count = post_update.challengeData.participantCount
        else: # Create new ChallengePost
            db_challenge_post = ChallengePost(
                title=post_update.challengeData.title,
                description=post_update.challengeData.description,
                start_date=post_update.challengeData.startDate,
                duration_days=post_update.challengeData.durationDays,
                cover_image_url=post_update.challengeData.coverImageUrl,
                participant_count=post_update.challengeData.participantCount,
            )
            db.add(db_challenge_post)
            db.flush()
            db_post.challenge_post_id = db_challenge_post.id
            db_post.challenge_data = db_challenge_post
    elif post_update.challengeData is None and db_post.challenge_data: # Remove existing
        db.delete(db_post.challenge_data)
        db_post.challenge_post_id = None
        db_post.challenge_data = None

    db.commit()
    db.refresh(db_post)
    
    # Load author profile
    db_post.author = db.query(User).options(joinedload(User.profile)).filter(User.id == db_post.user_id).first()

    return db_post

def delete_post(db: Session, post_id: str):
    db_post = db.query(Post).filter(Post.id == post_id).first()
    if db_post:
        db.delete(db_post)
        db.commit()
        return True
    return False

def get_public_feed(db: Session, skip: int = 0, limit: int = 20):
    """
    Retrieves public posts for the main feed, including author details, comment counts, and react counts.
    """
    # Subquery for comment counts
    comment_count_sq = db.query(
        Comment.post_id,
        func.count(Comment.id).label("comment_count")
    ).group_by(Comment.post_id).subquery()

    # Subquery for react counts
    react_count_sq = db.query(
        React.post_id,
        func.count(React.user_id).label("react_count") # Counting distinct users who reacted
    ).group_by(React.post_id).subquery()

    query = db.query(
        Post,
        User.id.label("author_user_id"),
        User.username.label("author_username"),
        User.email.label("author_email"),
        User.role.label("author_role"),
        User.created_at.label("author_created_at"),
        cast(Profile.id, String).label("author_profile_id"), # Include Profile.id and cast to String
        Profile.display_name.label("author_display_name"),
        Profile.profile_picture_url.label("author_profile_picture_url"),
        comment_count_sq.c.comment_count,
        react_count_sq.c.react_count
    ).join(User, Post.user_id == User.id)\
     .join(Profile, User.id == Profile.user_id)\
     .outerjoin(comment_count_sq, Post.id == comment_count_sq.c.post_id)\
     .outerjoin(react_count_sq, Post.id == react_count_sq.c.post_id)\
     .filter(Post.privacy == 'public')\
     .options(
        joinedload(Post.workout_data).joinedload(WorkoutPost.exercises), # Eager load workout data if needed
        joinedload(Post.challenge_data) # Eager load challenge data if needed
     )\
     .order_by(Post.created_at.desc())\
     .offset(skip)\
     .limit(limit)
    
    results = query.all()

    posts_with_details = []
    for row in results:
        post_obj = row.Post
        
        # Construct author User and Profile model instances
        # These are in-memory instances for Pydantic serialization, not new DB records.
        author_profile_instance = Profile(
            id=row.author_profile_id, # Pass the profile ID
            user_id=row.author_user_id, # user_id is required for Profile
            display_name=row.author_display_name,
            profile_picture_url=row.author_profile_picture_url
            # Other Profile fields like bio, fitness_goals, created_at, updated_at
            # will use their defaults (e.g., None or a default function like uuid.uuid4 for id)
            # if not explicitly set here. This is generally fine for read operations
            # as long as the UserPublic schema (used in PostResponse) doesn't strictly require them.
        )

        author_user_instance = User(
            id=row.author_user_id,
            username=row.author_username,
            email=row.author_email,
            role=row.author_role, # This is a string from the DB, matching User.role type
            created_at=row.author_created_at # This is a datetime object from the DB
            # password_hash is not needed for this public representation.
        )
        # Link the profile to the user instance
        author_user_instance.profile = author_profile_instance
        
        # Assign the fully formed User instance to the post's author relationship
        post_obj.author = author_user_instance

        post_obj.commentCount = row.comment_count if row.comment_count else 0
        post_obj.reactCount = row.react_count if row.react_count else 0
        
        # Ensure nested data is loaded if present (already handled by joinedload options)
        # if post_obj.workout_post_id and not post_obj.workout_data:
        #     post_obj.workout_data = db.query(WorkoutPost).filter(WorkoutPost.id == post_obj.workout_post_id).first()
        # if post_obj.challenge_post_id and not post_obj.challenge_data:
        #     post_obj.challenge_data = db.query(ChallengePost).filter(ChallengePost.id == post_obj.challenge_post_id).first()

        posts_with_details.append(post_obj)
        
    return posts_with_details
