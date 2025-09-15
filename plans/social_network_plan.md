# Social Network Feature Plan for FitNation

This document outlines a phased plan to implement social networking features in FitNation: posts, comments, likes/reacts, follows/friendships, feeds, and notifications. It covers both backend (FastAPI + PostgreSQL) and frontend (Flutter) design, API contract, database schema, security, and implementation steps.

---

## Goals
- Allow users to create posts (text, images, workout posts, challenges).
- Support comments and threaded replies.
- Support likes/reacts (emoji-based).
- Implement follow/unfollow to create personalized feeds.
- Provide a feed endpoint with pagination, filters, and ranking.
- Add basic notifications for key events (new follower, comment on your post, like/react, mention).
- Offline-friendly frontend with optimistic updates and local cache.

---

## High-level components
- Backend: FastAPI, SQLAlchemy models in `app/models_db.py`, Pydantic schemas, CRUD modules, endpoints under `app/api/v1/endpoints/`.
- Frontend: Flutter screens under `lib/Screens/`, models under `lib/models/`, providers under `lib/providers/`, API wiring via `ApiService`.
- DB: PostgreSQL (use existing `users`, `posts` tables) with new tables for `follows`, `comments`, `reactions`, `notifications`.

---

## Database schema (summary)
- posts (existing) will be extended if needed; core new tables:
  - follows (id, follower_id, followee_id, created_at)
  - comments (id, post_id, user_id, parent_comment_id, content, created_at, updated_at)
  - reactions (id, post_id, user_id, reaction_type, created_at)
  - notifications (id, user_id, actor_user_id, type, data JSONB, read boolean, created_at)
  - post_media (id, post_id, url, media_type, created_at)

Indexes on (post.created_at), (follows follower/followee), (comments post_id), (reactions post_id,user_id) unique constraint for one reaction per user per post.

---

## Backend API design (core endpoints)
- Posts
  - POST /api/v1/posts/ - create post (auth)
  - GET /api/v1/posts/{id} - fetch post details
  - GET /api/v1/posts/ - feed endpoint; query: ?skip=&limit=&user_id=&type=&following_only=true
  - PUT /api/v1/posts/{id} - update post (owner only)
  - DELETE /api/v1/posts/{id} - delete post (owner only)
- Comments
  - POST /api/v1/posts/{post_id}/comments - add comment
  - GET /api/v1/posts/{post_id}/comments - list comments (paginated)
  - DELETE /api/v1/comments/{comment_id} - delete comment (owner or post owner)
- Reactions
  - POST /api/v1/posts/{post_id}/react - add/update reaction (body: {type: 'like'|'love'|...})
  - DELETE /api/v1/posts/{post_id}/react - remove reaction
- Follows
  - POST /api/v1/users/{user_id}/follow - follow user
  - POST /api/v1/users/{user_id}/unfollow - unfollow user
- Notifications
  - GET /api/v1/notifications/ - list notifications
  - POST /api/v1/notifications/mark_read - mark as read

---

## Backend design details
- Use `get_current_user` dependency to ensure auth and associate actions with users.
- Use background tasks for notification creation after actions (e.g., after comment, reaction, follow).
- Protect endpoints with permission checks.
- CRUD helpers in `app/crud/post_crud.py`, `comment_crud.py`, `reaction_crud.py`, `follow_crud.py`, `notification_crud.py`.
- Add Pydantic schemas under `app/schemas/` (post_schemas.py, comment_schemas.py, reaction_schemas.py, follow_schemas.py, notification_schemas.py).

---

## Frontend design
- Screens
  - `FeedScreen` - shows feed with infinite scroll; uses `feedProvider` (Future/Stream) and supports pull-to-refresh.
  - `CreatePostScreen` - create text/image/workout post; upload media via API service and get media URLs.
  - `PostDetailsScreen` - show full post, comments, reactions.
  - `ProfileScreen` - show user profile, posts, followers, following.
  - `NotificationsScreen` - list notifications; tap to open post/profile.

- Providers (Riverpod)
  - `feedProvider` - paginated, supports filters; offline cache.
  - `postProvider` - manage single post state.
  - `commentsProvider` - paginated comments for a post.
  - `reactionsProvider` - local optimistic update and sync.
  - `followProvider` - follow/unfollow actions.
  - `notificationsProvider` - fetch and mark read.

- Optimistic updates
  - On like/react/comment, update UI immediately. If API fails, rollback and show error toast.

- Offline
  - Cache feed/pages in SQLite with `last_updated`. If offline, read cached feed and allow local actions (queue) to sync later.

---

## Implementation plan
### Phase 1 - Backend scaffolding (1-2 days)
- Add DDL and SQLAlchemy models to `models_db.py`.
- Add Pydantic schemas.
- Implement CRUD functions.
- Add endpoints with basic tests.

### Phase 2 - Frontend scaffolding (1-2 days)
- Add screens and models (Post, Comment, Reaction, Notification).
- Wire ApiService methods.
- Implement providers with basic UI.

### Phase 3 - Polishing (2-3 days)
- Add media upload, background processing.
- Add notification delivery and push integration (optional).
- Add analytics and moderation controls.

---

## Security & performance notes
- Rate-limit endpoints that mutate content.
- Sanitize/validate post/comment content.
- Use pagination and limits for feed and comments.
- Consider caching popular posts in Redis for heavy read load.

---

## Next steps (short-term)
1. I will add a `plans/social_network_plan.md` (this file).
2. If you approve the plan, I can create DB DDL and Pydantic schemas next.
3. Then I will scaffold backend CRUD and endpoints, and produce a Postman collection and frontend provider stubs.

---

Notes: I intentionally kept the plan modular so we can iterate. If you want realtime (WebSocket) feed or push notifications, I can add a realtime appendix.

## Addendum: Stories, Privacy, Buddies, and Communities

Based on your new requirements, the social network plan should also include the following features:

- Stories
  - Short ephemeral media posts visible for 24 hours.
  - Users can create/remove stories; stories can be public, buddies-only, or private (only user).
  - Stories are stored in a `stories` table with media references and expire timestamp; a background job or DB TTL removes them after expiry.
  - API endpoints:
    - `POST /api/v1/stories/` - upload a story (auth)
    - `GET /api/v1/stories/{user_id}` - fetch a user's active stories
    - `GET /api/v1/stories/feed` - fetch stories for current user (buddies first, then public)
  - Frontend:
    - `StoriesCarousel` on top of `FeedScreen`, prefetch thumbnails, show auto-advance and pause on press.
    - `CreateStoryScreen` or in-line composer with camera/gallery and quick stickers/text.

- Privacy & Buddies (friend/follow model)
  - Each `post` and `story` will include a `privacy` field with options: `public`, `buddies`, `private`.
  - Implement a `buddies` relationship (mutual friendship) and `follows` (one-way) depending on UX decisions; we'll implement `buddies` for mutual connections and also support `follow` for content discovery.
  - DB changes:
    - `buddies` table: (id, user_a_id, user_b_id, status [requested/accepted], created_at)
    - `follows` table: (follower_id, followee_id, created_at) — optional if follow model is needed.
  - Endpoints:
    - `POST /api/v1/users/{user_id}/add_buddy` - send buddy request
    - `POST /api/v1/users/{user_id}/respond_buddy` - accept/decline
    - `GET /api/v1/users/{user_id}/buddies` - list buddies
    - `GET /api/v1/users/search?q=` - search users
  - Privacy enforcement:
    - `feed` and `post` endpoints filter results according to `privacy` and buddy relationships. `GET /api/v1/posts/` with `following_only=true` or `buddies_only=true` flags.

- Search, View, Add Buddies
  - Search endpoint supports querying username/displayName/email with pagination and fuzzy matching (ILIKE on PostgreSQL).
  - Adding buddies triggers notifications (incoming request) and email/push optionally.
  - Frontend UI: `UserSearchScreen` with add/request button, pending state, and mutual-buddy UX.

- Challenges -> Auto Communities & Community Communication
  - When a challenge is created and reaches a threshold or when the creator opts-in, automatically create a `community` associated to that challenge.
  - Community features:
    - Community pages with member lists, rules, pinned posts, and a message board (simple chat/forum).
    - Community types: `challenge_group`, `topic_group`, `local_group`.
    - Messages: `community_messages` table with (id, community_id, user_id, content, attachments, created_at). This is not a real-time chat but a forum-style stream; we can add WebSocket later.
  - Endpoints:
    - `POST /api/v1/communities/` - create community
    - `GET /api/v1/communities/{id}` - get community info
    - `POST /api/v1/communities/{id}/messages` - post message
    - `GET /api/v1/communities/{id}/messages` - list messages (paginated)

## Data model deltas (summary)
- stories: id, user_id, media_url, caption, privacy, expires_at, created_at
- buddies: id, requester_id, requestee_id, status, created_at
- communities: id, name, type, challenge_id (optional), description, creator_id, created_at
- community_messages: id, community_id, user_id, content, attachments_json, created_at

## UX & Frontend notes
- Stories carousel should be lightweight and prefetch only necessary thumbnails.
- Privacy controls in the post composer: quick toggle (Public/Buddies/Only Me) and advanced visibility (restrict by list or group) as future enhancement.
- Buddy UX: clear request/accepted states, pending requests tab, buddy suggestions.
- Community UX: challenge pages should show a CTA to join the community; community message board similar to post threads but scoped.

## Security & moderation
- Add report/flag endpoints for posts, stories, messages. Store reports in `reports` table for review by admins.
- Rate-limit story creation and message posting to prevent spam.

## Implementation priority
1. Privacy + Buddies model + search (ensures feed filtering works)
2. Stories MVP (upload/view/expire)
3. Communities (auto from challenges) + message board
4. Polishing, moderation, notifications, real-time improvements

---

If this looks good I will update the implementation todo items and then start by scaffolding the DB DDL and Pydantic schemas for `stories`, `buddies`, `communities`, and `community_messages`.


## 🏗️ **Database Design & Scalability Analysis**

### Current Issues:
- **Single PostgreSQL instance** won't scale beyond ~100K active users
- **No partitioning strategy** for time-series data (posts, stories, messages)
- **Missing denormalization** for read-heavy operations (feed generation)
- **Inefficient privacy filtering** with complex JOINs

### Scalability Improvements:

**1. Database Architecture Evolution:**
```sql
-- Partition posts by time (monthly partitions)
CREATE TABLE posts_2025_01 PARTITION OF posts FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- Denormalized feed table for faster reads
CREATE TABLE user_feeds (
  user_id UUID,
  post_id UUID,
  created_at TIMESTAMP,
  post_author_id UUID,
  engagement_score FLOAT,
  PRIMARY KEY (user_id, created_at, post_id)
);
```

**2. Caching Strategy:**
- **Redis for hot data**: Active feeds, trending posts, user sessions
- **Application-level caching**: User relationships, privacy settings
- **CDN for media**: Images, videos, profile pictures

**3. Read Replicas & Sharding:**
- Read replicas for feed generation and analytics
- Shard by user_id for horizontal scaling (when reaching 1M+ users)

## 📈 **Feed Algorithm & Performance**

### Current Issues:
- **Real-time feed generation** is computationally expensive
- **No ranking algorithm** beyond chronological ordering
- **Missing engagement metrics** for content prioritization

### Scalable Feed Architecture:

**1. Hybrid Feed Strategy:**
```python
# Pre-computed feeds for active users (push model)
async def update_follower_feeds(post_id: UUID, author_id: UUID):
    followers = await get_active_followers(author_id, limit=10000)
    for follower_id in followers:
        await redis.zadd(f"feed:{follower_id}", {post_id: timestamp})

# Real-time generation for less active users (pull model)
async def generate_feed_realtime(user_id: UUID, limit: int):
    following = await get_following(user_id)
    return await get_recent_posts(following, limit)
```

**2. Engagement-Based Ranking:**
```python
def calculate_engagement_score(post: Post) -> float:
    time_decay = exp(-(now - post.created_at).seconds / 3600)  # 1-hour half-life
    engagement = (likes * 1.0 + comments * 2.0 + shares * 3.0)
    return engagement * time_decay * author_influence_score
```

**3. Feed Optimization:**
- **Batch processing**: Update feeds in background jobs
- **Smart pagination**: Cursor-based pagination with engagement scores
- **Content diversity**: Ensure feed variety (posts, stories, community content)

## ⚡ **Real-time Features & WebSocket Integration**

### Missing Real-time Capabilities:
```python
# WebSocket manager for real-time features
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[UUID, WebSocket] = {}
    
    async def notify_new_story(self, story: Story):
        # Notify followers about new story
        followers = await get_active_followers(story.user_id)
        for follower_id in followers:
            if follower_id in self.active_connections:
                await self.active_connections[follower_id].send_json({
                    "type": "new_story",
                    "story": story.dict()
                })
```

## 🔒 **Privacy & Security at Scale**

### Enhanced Privacy Model:
```python
# Efficient privacy filtering with pre-computed access lists
class PrivacyEngine:
    async def can_view_content(self, viewer_id: UUID, content: Content) -> bool:
        if content.privacy == "public":
            return True
        
        # Use cached relationship data
        relationships = await redis.get(f"relationships:{viewer_id}")
        
        if content.privacy == "buddies":
            return content.author_id in relationships.get("buddies", [])
        
        return content.author_id == viewer_id  # private content
```

### Content Moderation at Scale:
```python
# AI-powered content moderation pipeline
class ModerationPipeline:
    async def moderate_content(self, content: str, media_urls: List[str]) -> bool:
        # Text moderation (toxicity, spam)
        text_score = await ai_moderator.analyze_text(content)
        
        # Image moderation (NSFW, violence)
        image_scores = await asyncio.gather(*[
            ai_moderator.analyze_image(url) for url in media_urls
        ])
        
        return all(score < MODERATION_THRESHOLD for score in [text_score] + image_scores)
```

## 🎯 **API Design Improvements**

### GraphQL for Complex Queries:
```graphql
# Single query for feed with nested data
query GetFeed($limit: Int!, $cursor: String) {
  feed(limit: $limit, after: $cursor) {
    edges {
      node {
        id
        content
        author {
          id
          username
          avatar
        }
        reactions {
          count
          userReaction
        }
        comments(first: 3) {
          edges {
            node {
              id
              content
              author { username }
            }
          }
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

### Batch Operations:
```python
# Batch reaction updates
@router.post("/posts/reactions/batch")
async def batch_reactions(
    reactions: List[BatchReactionUpdate],
    current_user = Depends(get_current_user)
):
    # Process multiple reactions in single DB transaction
    async with db.begin():
        for reaction in reactions:
            await update_reaction(reaction.post_id, current_user.id, reaction.type)
```

## 📱 **Frontend Performance Optimizations**

### Advanced Caching Strategy:
```dart
// Intelligent cache management
class FeedCache {
  static const maxCacheSize = 500; // posts
  static const maxCacheAge = Duration(hours: 24);
  
  Future<List<Post>> getCachedFeed(String userId) async {
    final cached = await _storage.get('feed_$userId');
    if (cached != null && _isFresh(cached.timestamp)) {
      return cached.posts;
    }
    return [];
  }
  
  Future<void> updateCache(String userId, List<Post> posts) async {
    // LRU eviction for memory management
    await _evictOldEntries();
    await _storage.set('feed_$userId', CachedFeed(
      posts: posts,
      timestamp: DateTime.now(),
    ));
  }
}
```

### Optimistic Updates with Conflict Resolution:
```dart
// Smart optimistic updates
class OptimisticUpdateManager {
  final Map<String, PendingUpdate> _pendingUpdates = {};
  
  Future<void> likePost(String postId) async {
    // Immediate UI update
    _updateUI(postId, liked: true);
    
    // Track pending update
    _pendingUpdates[postId] = PendingUpdate(
      type: UpdateType.like,
      timestamp: DateTime.now(),
    );
    
    try {
      await apiService.likePost(postId);
      _pendingUpdates.remove(postId);
    } catch (e) {
      // Rollback on failure
      _updateUI(postId, liked: false);
      _showErrorSnackbar('Failed to like post');
    }
  }
}
```

## 🔄 **Recommended Architecture Evolution**

### Phase 1: Foundation (Current → 10K users)
- Implement Redis caching layer
- Add read replicas
- Optimize database indexes
- Implement basic feed pre-computation

### Phase 2: Scale (10K → 100K users)
- Add WebSocket support for real-time features
- Implement GraphQL alongside REST
- Add CDN for media delivery
- Implement advanced privacy filtering

### Phase 3: Enterprise Scale (100K+ users)
- Database sharding by user segments
- Microservices architecture (feed service, notification service)
- Advanced AI moderation
- Global CDN with edge computing

## 📊 **Performance Metrics & Monitoring**

### Key Metrics to Track:
```python
# Performance monitoring
class MetricsCollector:
    async def track_feed_performance(self, user_id: UUID, load_time: float):
        await metrics.histogram('feed.load_time', load_time, tags={'user_segment': get_user_segment(user_id)})
    
    async def track_engagement(self, post_id: UUID, action: str):
        await metrics.increment('post.engagement', tags={'action': action})
```

### Load Testing Targets:
- **Feed load time**: < 200ms (p95)
- **Story upload**: < 1s (p95)
- **Real-time message delivery**: < 100ms
- **Concurrent users**: Support 10K simultaneous connections

## 🎯 **Immediate Recommendations**

1. **Database**: Add Redis caching layer NOW (easy win)
2. **API**: Implement cursor-based pagination for all list endpoints
3. **Frontend**: Add intelligent image prefetching and lazy loading
4. **Monitoring**: Set up comprehensive metrics from day 1
5. **Testing**: Load test with realistic data volumes (1M posts, 100K users)

The current plan is solid for an MVP, but these enhancements will ensure it scales gracefully from thousands to millions of users. Would you like me to implement any of these specific improvements, or shall we prioritize certain areas based on your expected user growth timeline?
```