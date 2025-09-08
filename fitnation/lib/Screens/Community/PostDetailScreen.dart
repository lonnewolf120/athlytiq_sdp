import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:fitnation/models/PostModel.dart';
import 'package:fitnation/providers/data_providers.dart';
import 'package:fitnation/widgets/community/UserProfileModal.dart';

// Helper to format time (reuse from PostCard)
String timeAgo(DateTime dt) {
  Duration diff = DateTime.now().difference(dt);
  if (diff.inDays > 365) return "${(diff.inDays / 365).floor()}y ago";
  if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo ago";
  if (diff.inDays > 7) return "${(diff.inDays / 7).floor()}w ago";
  if (diff.inDays > 0) return "${diff.inDays}d ago";
  if (diff.inHours > 0) return "${diff.inHours}h ago";
  if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
  return "just now";
}

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  Post? post;
  List<dynamic> comments = []; // TODO: Create Comment model
  bool isLoading = true;
  String? error;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = ref.read(apiServiceProvider);
      final fetchedPost = await apiService.getPostById(widget.postId);
      final fetchedComments = await apiService.getPostComments(widget.postId);
      
      if (mounted) {
        setState(() {
          post = fetchedPost;
          comments = fetchedComments;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.addComment(widget.postId, _commentController.text.trim());
      
      _commentController.clear();
      _loadPostDetails(); // Refresh comments
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.cardForeground,
        title: const Text('Post Details'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Post Content
          Expanded(
            child: _buildContent(theme),
          ),
          
          // Comment Input
          _buildCommentInput(theme),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load post',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPostDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (post == null) {
      return const Center(
        child: Text('Post not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(theme),
          const SizedBox(height: 16),
          
          // Post Content
          _buildPostContent(theme),
          const SizedBox(height: 16),
          
          // Post Actions
          _buildPostActions(theme),
          const SizedBox(height: 24),
          
          // Comments Section
          _buildCommentsSection(theme),
        ],
      ),
    );
  }

  Widget _buildPostHeader(ThemeData theme) {
    if (post?.author == null) return const SizedBox();

    final userName = post!.author?.displayName ?? 'Unknown User';
    final userHandle = post!.author?.username ?? 'unknown';
    final userImageUrl = post!.author?.avatarUrl ?? 'https://avatar.iran.liara.run/public';

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (post!.author?.id != null) {
              showDialog(
                context: context,
                builder: (context) => UserProfileModal(userId: post!.author!.id),
              );
            }
          },
          child: CircleAvatar(
            radius: 24,
            backgroundImage: CachedNetworkImageProvider(userImageUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.cardForeground,
                ),
              ),
              Text(
                '$userHandle • ${timeAgo(post!.createdAt)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Text
        if (post!.content != null && post!.content!.isNotEmpty)
          Text(
            post!.content!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.cardForeground,
            ),
          ),
        
        // Post Image
        if (post!.mediaUrl != null && post!.mediaUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post!.mediaUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: AppColors.mutedBackground,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: AppColors.mutedBackground,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          context,
          icon: Icons.favorite_border_outlined,
          label: '${post?.reactCount ?? 0}',
          onTap: () {
            // TODO: Implement like functionality
          },
        ),
        _buildActionItem(
          context,
          icon: Icons.chat_bubble_outline,
          label: '${comments.length}',
          onTap: () {
            // Scroll to comments or focus comment input
          },
        ),
        _buildActionItem(
          context,
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: () {
            // TODO: Implement share functionality
          },
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${comments.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.cardForeground,
          ),
        ),
        const SizedBox(height: 16),
        
        // Comments List
        if (comments.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No comments yet. Be the first to comment!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final authorName = comment['author']?['display_name'] ?? 'Unknown User';
              final authorUsername = comment['author']?['username'] ?? 'unknown';
              final commentContent = comment['content'] ?? '';
              final createdAt = comment['created_at'] ?? '';
              final authorId = comment['author']?['id'];
              final authorImageUrl = comment['author']?['profile_picture_url'] ?? 'https://avatar.iran.liara.run/public';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mutedBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author avatar
                    GestureDetector(
                      onTap: () {
                        if (authorId != null) {
                          showDialog(
                            context: context,
                            builder: (context) => UserProfileModal(userId: authorId),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: CachedNetworkImageProvider(authorImageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Comment content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author info
                          Row(
                            children: [
                              Text(
                                authorName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cardForeground,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '@$authorUsername',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeAgo(DateTime.parse(createdAt)),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Comment text
                          Text(
                            commentContent,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.cardForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.mutedForeground.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.cardForeground,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.mutedForeground.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.mutedForeground.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                  ),
                ),
                filled: true,
                fillColor: AppColors.mutedBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _addComment(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _addComment,
            icon: const Icon(
              Icons.send,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
