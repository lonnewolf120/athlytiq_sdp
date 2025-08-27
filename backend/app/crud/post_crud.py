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

def get_public_feed(db: Session, skip: int = 0, limit: int = 30):
    """
    Retrieves public posts for the main feed, including author details, comment counts, and react counts.
    """
    print(f"DEBUG: get_public_feed called with skip={skip}, limit={limit}")
    
    # First, let's get a simple count of public posts
    total_public_posts = db.query(Post).filter(Post.privacy == 'public').count()
    print(f"DEBUG: Total public posts in database: {total_public_posts}")
    
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

    # Build the main query step by step for better debugging
    base_query = db.query(Post).filter(Post.privacy == 'public')
    
    # Check if we have any posts after the privacy filter
    posts_after_privacy_filter = base_query.count()
    print(f"DEBUG: Posts after privacy filter: {posts_after_privacy_filter}")
    
    # Add joins - use LEFT JOIN to ensure we don't lose posts
    query = db.query(
        Post,
        User.id.label("author_user_id"),
        User.username.label("author_username"),
        User.email.label("author_email"),
        User.role.label("author_role"),
        User.created_at.label("author_created_at"),
        cast(Profile.id, String).label("author_profile_id"),
        Profile.display_name.label("author_display_name"),
        Profile.profile_picture_url.label("author_profile_picture_url"),
        comment_count_sq.c.comment_count,
        react_count_sq.c.react_count
    ).filter(Post.privacy == 'public')\
     .join(User, Post.user_id == User.id)\
     .outerjoin(Profile, User.id == Profile.user_id)\
     .outerjoin(comment_count_sq, Post.id == comment_count_sq.c.post_id)\
     .outerjoin(react_count_sq, Post.id == react_count_sq.c.post_id)\
     .options(
        joinedload(Post.workout_data).joinedload(WorkoutPost.exercises),
        joinedload(Post.challenge_data)
     )\
     .order_by(Post.created_at.desc())\
     .offset(skip)\
     .limit(limit)
    
    print(f"DEBUG: About to execute final query with offset={skip}, limit={limit}")
    
    try:
        results = query.all()
        print(f"DEBUG: Query executed successfully, got {len(results)} results")
    except Exception as e:
        print(f"DEBUG: Error executing query: {e}")
        # Fallback to simpler query
        print("DEBUG: Falling back to simpler query...")
        simple_query = db.query(Post)\
            .join(User, Post.user_id == User.id)\
            .outerjoin(Profile, User.id == Profile.user_id)\
            .filter(Post.privacy == 'public')\
            .options(
                joinedload(Post.author).joinedload(User.profile),
                joinedload(Post.workout_data).joinedload(WorkoutPost.exercises),
                joinedload(Post.challenge_data)
            )\
            .order_by(Post.created_at.desc())\
            .offset(skip)\
            .limit(limit)
        
        simple_results = simple_query.all()
        print(f"DEBUG: Simple query returned {len(simple_results)} results")
        
        # Convert to the expected format
        results = []
        for post in simple_results:
            # Create a mock row object
            class MockRow:
                def __init__(self, post):
                    self.Post = post
                    self.author_user_id = post.author.id if post.author else None
                    self.author_username = post.author.username if post.author else None
                    self.author_email = post.author.email if post.author else None
                    self.author_role = post.author.role if post.author else None
                    self.author_created_at = post.author.created_at if post.author else None
                    self.author_profile_id = str(post.author.profile.id) if post.author and post.author.profile else None
                    self.author_display_name = post.author.profile.display_name if post.author and post.author.profile else None
                    self.author_profile_picture_url = post.author.profile.profile_picture_url if post.author and post.author.profile else None
                    self.comment_count = 0  # Will be calculated separately if needed
                    self.react_count = 0    # Will be calculated separately if needed
            
            results.append(MockRow(post))

    posts_with_details = []
    for row in results:
        post_obj = row.Post
        
        # If post_obj.author is not already loaded, construct it
        if not hasattr(post_obj, 'author') or post_obj.author is None:
            # Construct author User and Profile model instances
            author_profile_instance = Profile(
                id=row.author_profile_id,
                user_id=row.author_user_id,
                display_name=row.author_display_name,
                profile_picture_url=row.author_profile_picture_url
            )

            author_user_instance = User(
                id=row.author_user_id,
                username=row.author_username,
                email=row.author_email,
                role=row.author_role,
                created_at=row.author_created_at
            )
            author_user_instance.profile = author_profile_instance
            post_obj.author = author_user_instance

        # Set counts, handling None values
        if hasattr(row, 'comment_count'):
            post_obj.commentCount = row.comment_count if row.comment_count else 0
        else:
            post_obj.commentCount = 0
            
        if hasattr(row, 'react_count'):
            post_obj.reactCount = row.react_count if row.react_count else 0
        else:
            post_obj.reactCount = 0
        
        posts_with_details.append(post_obj)
        
    print(f"DEBUG: Returning {len(posts_with_details)} posts")
    return posts_with_details
