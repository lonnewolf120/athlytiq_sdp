from typing import List, Optional, Any
from uuid import UUID, uuid4
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime

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
    return dict(row)


def get_stories_for_user(db: Session, *, user_id: UUID) -> List[dict]:
    sql = text("SELECT id, user_id, media_url, caption, privacy, expires_at, created_at FROM stories WHERE user_id = :user_id AND expires_at > now() ORDER BY created_at DESC")
    res = db.execute(sql, {'user_id': str(user_id)})
    return [dict(r) for r in res.fetchall()]


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
    return [dict(r) for r in res.fetchall()]


def create_buddy_request(db: Session, *, requester_id: UUID, requestee_id: UUID) -> dict:
    sql = text("INSERT INTO buddies (id, requester_id, requestee_id, status, created_at) VALUES (:id, :requester_id, :requestee_id, 'requested', now()) RETURNING id, requester_id, requestee_id, status, created_at")
    bid = uuid4()
    try:
        res = db.execute(sql, {'id': str(bid), 'requester_id': str(requester_id), 'requestee_id': str(requestee_id)})
        db.commit()
        return dict(res.fetchone())
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
        return dict(row)
    return None


def list_buddies(db: Session, *, user_id: UUID) -> List[dict]:
    sql = text("""
    SELECT CASE WHEN requester_id = :user_id THEN requestee_id ELSE requester_id END AS buddy_id
    FROM buddies
    WHERE (requester_id = :user_id OR requestee_id = :user_id) AND status = 'accepted'
    """)
    res = db.execute(sql, {'user_id': str(user_id)})
    return [dict(r) for r in res.fetchall()]


def create_community(db: Session, *, creator_id: UUID, community_in) -> dict:
    sql = text("INSERT INTO communities (id, name, type, challenge_id, description, creator_id, created_at) VALUES (:id, :name, :type, :challenge_id, :description, :creator_id, now()) RETURNING id, name, type, challenge_id, description, creator_id, created_at")
    cid = uuid4()
    res = db.execute(sql, {
        'id': str(cid),
        'name': community_in.name,
        'type': community_in.type,
        'challenge_id': str(community_in.challenge_id) if getattr(community_in, 'challenge_id', None) else None,
        'description': community_in.description,
        'creator_id': str(creator_id),
    })
    db.commit()
    row = res.fetchone()
    return dict(row)


def get_community(db: Session, *, community_id: UUID) -> Optional[dict]:
    sql = text("SELECT id, name, type, challenge_id, description, creator_id, created_at FROM communities WHERE id = :id")
    res = db.execute(sql, {'id': str(community_id)})
    row = res.fetchone()
    return dict(row) if row else None


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
    return dict(row)


def list_community_messages(db: Session, *, community_id: UUID, skip: int = 0, limit: int = 50) -> List[dict]:
    sql = text("SELECT id, community_id, user_id, content, attachments, created_at FROM community_messages WHERE community_id = :community_id ORDER BY created_at DESC OFFSET :skip LIMIT :limit")
    res = db.execute(sql, {'community_id': str(community_id), 'skip': skip, 'limit': limit})
    return [dict(r) for r in res.fetchall()]


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
    return dict(row)
