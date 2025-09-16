from typing import List, Optional, Any
from uuid import UUID, uuid4
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime
from uuid import UUID

# Note: using raw SQL to avoid changing models_db.py; SQL DDL must be applied first.

def create_story(db: Session, *, user_id: UUID, story_in) -> dict:
    sql = text("""
        INSERT INTO stories (id, user_id, media_url, caption, privacy, expires_at, created_at)
        VALUES (:id, :user_id, :media_url, :caption, :privacy, :expires_at, now())
        RETURNING id, user_id, media_url, caption, privacy, expires_at, created_at
    """)
    sid = uuid4()
    res = db.execute(sql, {
        'id': str(sid),
        'user_id': str(user_id),
        'media_url': story_in.media_url,
        'caption': story_in.caption,
        'privacy': story_in.privacy,
        'expires_at': story_in.expires_at,
    })
    db.commit()
    row = res.fetchone()
    return dict(row._mapping)


def get_stories_for_user(db: Session, *, user_id: UUID) -> List[dict]:
    sql = text("SELECT id, user_id, media_url, caption, privacy, expires_at, created_at FROM stories WHERE user_id = :user_id AND expires_at > now() ORDER BY created_at DESC")
    res = db.execute(sql, {'user_id': str(user_id)})
    return [dict(r._mapping) for r in res.fetchall()]


def get_stories_feed(db: Session, *, user_id: UUID, skip: int = 0, limit: int = 50) -> List[dict]:
    # For MVP: return public and buddies stories. Buddy logic can be improved later.
    sql = text("""
    SELECT s.id, s.user_id, s.media_url, s.caption, s.privacy, s.expires_at, s.created_at
    FROM stories s
    LEFT JOIN buddies b ON ( (b.requester_id = :user_id AND b.requestee_id = s.user_id AND b.status = 'accepted') OR (b.requestee_id = :user_id AND b.requester_id = s.user_id AND b.status = 'accepted') )
    WHERE s.expires_at > now() AND (s.privacy = 'public' OR b.status = 'accepted')
    ORDER BY s.created_at DESC
    OFFSET :skip LIMIT :limit
    """)
    res = db.execute(sql, {'user_id': str(user_id), 'skip': skip, 'limit': limit})
    return [dict(r._mapping) for r in res.fetchall()]


def create_buddy_request(db: Session, *, requester_id: UUID, requestee_id: UUID) -> dict:
    sql = text("INSERT INTO buddies (id, requester_id, requestee_id, status, created_at) VALUES (:id, :requester_id, :requestee_id, 'requested', now()) RETURNING id, requester_id, requestee_id, status, created_at")
    bid = uuid4()
    try:
        res = db.execute(sql, {'id': str(bid), 'requester_id': str(requester_id), 'requestee_id': str(requestee_id)})
        db.commit()
        row = res.fetchone()
        return dict(row._mapping)
    except Exception as e:
        db.rollback()
        raise


def respond_buddy_request(db: Session, *, requester_id: UUID, requestee_id: UUID, accept: bool) -> Optional[dict]:
    # Find request and update
    new_status = 'accepted' if accept else 'declined'
    sql = text("UPDATE buddies SET status = :status WHERE requester_id = :requester_id AND requestee_id = :requestee_id RETURNING id, requester_id, requestee_id, status, created_at")
    res = db.execute(sql, {'status': new_status, 'requester_id': str(requester_id), 'requestee_id': str(requestee_id)})
    db.commit()
    row = res.fetchone()
    if row:
        return dict(row._mapping)
    return None


def list_buddies(db: Session, *, user_id: UUID) -> List[dict]:
    sql = text("""
    SELECT CASE WHEN requester_id = :user_id THEN requestee_id ELSE requester_id END AS buddy_id
    FROM buddies
    WHERE (requester_id = :user_id OR requestee_id = :user_id) AND status = 'accepted'
    """)
    res = db.execute(sql, {'user_id': str(user_id)})
    return [dict(r._mapping) for r in res.fetchall()]


def create_community(db: Session, *, creator_id: UUID, community_in) -> dict:
    sql = text("INSERT INTO communities (id, creator_user_id, name, description, image_url, is_private, created_at, updated_at) VALUES (:id, :creator_user_id, :name, :description, :image_url, :is_private, now(), now()) RETURNING id, creator_user_id, name, description, image_url, is_private, created_at, updated_at")
    cid = uuid4()
    res = db.execute(sql, {
        'id': str(cid),
        'creator_user_id': str(creator_id),
        'name': community_in.name,
        'description': community_in.description,
        'image_url': getattr(community_in, 'image_url', None),
        'is_private': getattr(community_in, 'is_private', False),
    })
    db.commit()
    row = res.fetchone()
    return dict(row._mapping)


def get_community(db: Session, *, community_id: UUID) -> Optional[dict]:
    sql = text("SELECT id, creator_user_id, name, description, image_url, is_private, created_at, updated_at FROM communities WHERE id = :id")
    res = db.execute(sql, {'id': str(community_id)})
    row = res.fetchone()
    return dict(row._mapping) if row else None


def create_community_message(db: Session, *, community_id: UUID, user_id: UUID, message_in) -> dict:
    sql = text("INSERT INTO community_messages (id, community_id, user_id, content, attachments, created_at) VALUES (:id, :community_id, :user_id, :content, :attachments, now()) RETURNING id, community_id, user_id, content, attachments, created_at")
    mid = uuid4()
    res = db.execute(sql, {
        'id': str(mid),
        'community_id': str(community_id),
        'user_id': str(user_id),
        'content': message_in.content,
        'attachments': message_in.attachments,
    })
    db.commit()
    row = res.fetchone()
    return dict(row._mapping)


def list_community_messages(db: Session, *, community_id: UUID, skip: int = 0, limit: int = 50) -> List[dict]:
    sql = text("SELECT id, community_id, user_id, content, attachments, created_at FROM community_messages WHERE community_id = :community_id ORDER BY created_at DESC OFFSET :skip LIMIT :limit")
    res = db.execute(sql, {'community_id': str(community_id), 'skip': skip, 'limit': limit})
    return [dict(r._mapping) for r in res.fetchall()]


def join_community(db: Session, *, community_id: UUID, user_id: UUID) -> dict:
    """Add a user as a member of a community. Idempotent if already a member."""
    sql = text(
        """
        INSERT INTO community_members (community_id, user_id, role, joined_at)
        VALUES (:community_id, :user_id, 'member', now())
        ON CONFLICT (community_id, user_id) DO NOTHING
        """
    )
    db.execute(sql, {'community_id': str(community_id), 'user_id': str(user_id)})
    db.commit()
    return {"joined": True}


def leave_community(db: Session, *, community_id: UUID, user_id: UUID) -> dict:
    """Remove a user from a community membership."""
    sql = text("DELETE FROM community_members WHERE community_id = :community_id AND user_id = :user_id")
    db.execute(sql, {'community_id': str(community_id), 'user_id': str(user_id)})
    db.commit()
    return {"joined": False}


def add_post_to_community(db: Session, *, community_id: UUID, post_id: UUID) -> dict:
    """Associate an existing post with a community."""
    sql = text(
        """
        INSERT INTO community_posts (community_id, post_id)
        VALUES (:community_id, :post_id)
        ON CONFLICT (community_id, post_id) DO NOTHING
        """
    )
    db.execute(sql, {'community_id': str(community_id), 'post_id': str(post_id)})
    db.commit()
    return {"ok": True}


def list_community_posts(db: Session, *, community_id: UUID, skip: int = 0, limit: int = 20) -> list[dict]:
    """Return posts for a community with basic author info and counts."""
    sql = text(
        """
        SELECT p.id,
               p.user_id,
               p.content,
               p.media_url,
               p.post_type,
               p.created_at,
               p.updated_at,
               u.username,
               pr.profile_picture_url,
               COALESCE(pc.comment_count, 0) AS comment_count,
               COALESCE(prc.react_count, 0) AS react_count
        FROM community_posts cp
        JOIN posts p ON p.id = cp.post_id
        JOIN users u ON u.id = p.user_id
        LEFT JOIN profiles pr ON pr.user_id = u.id
        LEFT JOIN (
            SELECT post_id, COUNT(*) AS comment_count
            FROM post_comments
            GROUP BY post_id
        ) pc ON pc.post_id = p.id
        LEFT JOIN (
            SELECT post_id, COUNT(*) AS react_count
            FROM post_reacts
            GROUP BY post_id
        ) prc ON prc.post_id = p.id
        WHERE cp.community_id = :community_id
        ORDER BY p.created_at DESC
        OFFSET :skip LIMIT :limit
        """
    )
    res = db.execute(sql, {'community_id': str(community_id), 'skip': skip, 'limit': limit})
    return [dict(r._mapping) for r in res.fetchall()]


def create_report(db: Session, *, reporter_id: UUID, report_in) -> dict:
    sql = text("INSERT INTO reports (id, reporter_id, target_type, target_id, reason, created_at, handled) VALUES (:id, :reporter_id, :target_type, :target_id, :reason, now(), false) RETURNING id, reporter_id, target_type, target_id, reason, created_at, handled")
    rid = uuid4()
    res = db.execute(sql, {
        'id': str(rid),
        'reporter_id': str(reporter_id),
        'target_type': report_in.target_type,
        'target_id': str(report_in.target_id),
        'reason': report_in.reason,
    })
    db.commit()
    row = res.fetchone()
    return dict(row._mapping)


def list_communities(db: Session, *, user_id: Optional[UUID] = None, joined_only: bool = False, skip: int = 0, limit: int = 50) -> List[dict]:
    """
    List communities with member_count and a joined flag for the provided user_id.
    If joined_only=True, only return communities where the user is a member.
    """
    if joined_only:
        sql = text(
            """
            SELECT c.id,
                   c.name,
                   c.description,
                   c.creator_user_id,
                   c.created_at,
                   c.updated_at,
                   COALESCE(mc.member_count, 0) AS member_count,
                   TRUE AS joined
            FROM communities c
            JOIN community_members cm ON cm.community_id = c.id AND cm.user_id = :user_id
            LEFT JOIN (
                SELECT community_id, COUNT(*) AS member_count
                FROM community_members
                GROUP BY community_id
            ) mc ON mc.community_id = c.id
            ORDER BY c.created_at DESC
            OFFSET :skip LIMIT :limit
            """
        )
        params = {'user_id': str(user_id), 'skip': skip, 'limit': limit}
    else:
        sql = text(
            """
            SELECT c.id,
                   c.name,
                   c.description,
                   c.creator_user_id,
                   c.created_at,
                   c.updated_at,
                   COALESCE(mc.member_count, 0) AS member_count,
                   CASE WHEN cm.user_id IS NULL THEN FALSE ELSE TRUE END AS joined
            FROM communities c
            LEFT JOIN (
                SELECT community_id, COUNT(*) AS member_count
                FROM community_members
                GROUP BY community_id
            ) mc ON mc.community_id = c.id
            LEFT JOIN community_members cm ON cm.community_id = c.id AND cm.user_id = :user_id
            ORDER BY c.created_at DESC
            OFFSET :skip LIMIT :limit
            """
        )
        params = {'user_id': str(user_id) if user_id else None, 'skip': skip, 'limit': limit}

    res = db.execute(sql, params)
    rows = res.fetchall()
    # Convert SQLAlchemy Row objects to plain dicts
    return [dict(r._mapping) for r in rows]
