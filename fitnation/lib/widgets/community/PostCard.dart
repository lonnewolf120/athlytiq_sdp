// import 'package:fitnation/models/workout_post_data.dart';
// import 'package:fitnation/models/challenge_post_data.dart'; // Import new models
import 'package:fitnation/core/themes/themes.dart';
import 'package:fitnation/models/ChallengePostModel.dart';
import 'package:fitnation/models/Exercise.dart';
import 'package:fitnation/models/PlannedExercise.dart';
import 'package:fitnation/models/PostModel.dart';
import 'package:fitnation/models/WorkoutPostModel.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
// import 'package:fitnation/models/User.dart'; 

// Helper to format time (from previous response)
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

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final String userName =
        post.author?.displayName ??
        post.userId; // Use name if available, else userId
    final String userHandle =
        post.author?.username != null ? '@${post.author!.username}' : '';
    final String userImageUrl =
        post.author?.profile?.profilePictureUrl ??
        'https://avatar.iran.liara.run/public'; // Default fallback

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(userImageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.cardForeground,
                        ),
                      ),
                      Text(
                        '$userHandle • ${timeAgo(post.createdAt)}',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.mutedForeground,
                  ),
                  onPressed: () {
                    /* TODO: Post options */
                  },
                  tooltip: 'More options',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post Content - Dynamically render based on post data
            if (post.workoutData != null)
              WorkoutPostContent(workoutData: post.workoutData!),
            if (post.challengeData != null)
              ChallengePostContent(challengeData: post.challengeData!),
            if (post.content != null && post.content!.isNotEmpty)
              Text(
                post.content!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.cardForeground.withOpacity(0.9),
                ),
              ),
            if (post.mediaUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: post.mediaUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder:
                        (context, url) => Container(
                          height: 200,
                          color: AppColors.mutedBackground,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: 200,
                          color: AppColors.mutedBackground,
                          child: const Icon(
                            Icons.error,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                  ),
                ),
              ),

            const SizedBox(height: 8), // Space before actions
            // Action Buttons & Counts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  context,
                  icon: Icons.favorite_border_outlined,
                  label: '${post.reactCount ?? 0}',
                  onTap: () {
                    /* TODO: Like/React action */
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentCount ?? 0}',
                  onTap: () {
                    /* TODO: Comment action */
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    /* TODO: Share action */
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mutedForeground,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: textTheme.labelSmall?.copyWith(color: AppColors.mutedForeground),
      ),
      onPressed: onTap,
    );
  }
}

// New Widget for Workout Post Content
class WorkoutPostContent extends StatefulWidget {
  final WorkoutPostData workoutData;
  const WorkoutPostContent({super.key, required this.workoutData});

  @override
  State<WorkoutPostContent> createState() => _WorkoutPostContentState();
}

class _WorkoutPostContentState extends State<WorkoutPostContent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Card(
          color: AppColors.mutedBackground, // Slightly lighter black
          elevation: 0, // No shadow for nested card
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              8.0,
            ), // Smaller radius for inner card
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Inner padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.workoutData.workoutType,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.workoutData.durationMinutes} min',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_fire_department_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.workoutData.caloriesBurned} cal',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Expandable Exercises Section
          // Inside the _WorkoutPostContentState build method, replace the existing block
        // that starts with `if (_isExpanded && widget.workoutData.exercises.isNotEmpty) ...[`
        if (_isExpanded && widget.workoutData.exercises.isNotEmpty) ...[
          const SizedBox(
            height: 16,
          ), // Increased space based on UI margin guidelines
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Exercises:',
              style: textTheme.bodyLarge?.copyWith(
                // Use bodyLarge for section title
                fontWeight: FontWeight.w600,
                color: AppColors.foreground, // Ensure good contrast
              ),
            ),
          ),
          const SizedBox(height: 12), // Space after title
          // Map exercises to a list of Widgets
          ...widget.workoutData.exercises.asMap().entries.map((entry) {
            int index = entry.key;
            Exercise exercise = entry.value;
            return Column(
              // Use Column to stack the exercise Row and the Divider
              children: [
                Padding(
                  // Padding for the exercise item itself
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                  ), // Space between items
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Optional: Add a small icon before the exercise name
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8), // Space between icon and text

                      Expanded(
                        // Allows the text to take up available space
                        child: RichText(
                          // Use RichText to style parts of the string
                          text: TextSpan(
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedForeground,
                            ), // Default style for details
                            children: [
                              // Exercise Name (Bold, Foreground color)
                              TextSpan(
                                text: exercise.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight:
                                      FontWeight.w600, // Semibold for name
                                  color:
                                      AppColors
                                          .foreground, // Foreground color for name
                                ),
                              ),
                              // Separator and Details (Muted color)
                              TextSpan(text: ': '), // Colon separator
                              if (exercise.sets != null &&
                                  exercise.reps != null)
                                TextSpan(
                                  text: '${exercise.sets} x ${exercise.reps}',
                                ), //

                              // Reps
                              // Weight (Highlighted in Primary color if exists)
                              
                              TextSpan(
                                text:
                                    (exercise.weight != null &&
                                            exercise.weight!.isNotEmpty)
                                        ? ' • ${exercise.weight}'
                                        : ' • bodyweight', // Weight with separator
                                style: textTheme.bodyMedium?.copyWith(
                                  color:
                                      AppColors
                                          .primary, // Highlight weight in red
                                  fontWeight:
                                      FontWeight.w500, // Slightly bolder
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Add a Divider after each exercise except the last one
                if (index < widget.workoutData.exercises.length - 1)
                  Divider(
                    color: AppColors.mutedBackground,
                    height: 16,
                  ), // Divider with some height/padding
              ],
            );
          }).toList(), // Convert the map result back to a List of Widgets
        ],

        // Notes Section (if expanded)
        if (_isExpanded &&
            widget.workoutData.notes != null &&
            widget.workoutData.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(widget.workoutData.notes!, style: textTheme.bodyMedium),
        ],

        // Toggle Button
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'Show less' : 'Show details',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// New Widget for Challenge Post Content
class ChallengePostContent extends StatelessWidget {
  final ChallengePostData challengeData;
  const ChallengePostContent({super.key, required this.challengeData});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Image & Title
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: AspectRatio(
            aspectRatio: 16 / 9, // Or adjust as needed
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      challengeData.coverImageUrl ??
                      'https://via.placeholder.com/800x450.png/1A1A1A/FFFFFF?text=Challenge',
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          Container(color: AppColors.mutedBackground),
                  errorWidget:
                      (context, url, error) => Container(
                        color: AppColors.mutedBackground,
                        child: const Icon(
                          Icons.error,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                ),
                Container(
                  // Gradient Overlay
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                ),
                Positioned(
                  // Position title at the bottom left
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    challengeData.title,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryForeground,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Description
        if (challengeData.description.isNotEmpty) ...[
          Text(
            challengeData.description,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.cardForeground.withOpacity(0.9),
            ),
            maxLines: 3, // Or more if needed
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],

        // Details Row (Participants, Duration, Start Date)
        Row(
          children: [
            Icon(
              Icons.group_outlined,
              size: 16,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              '${challengeData.participantCount} participants',
              style: textTheme.labelSmall,
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              '${challengeData.durationDays} days',
              style: textTheme.labelSmall,
            ),
            
          ],
        ),
        const SizedBox(height: 8), // Space before button
        // Join Button
        Row(
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 16,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),

            Text(
              'Starts ${DateFormat.yMMMd().format(challengeData.startDate)}',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 16), // Space before button
        // Join Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              /* TODO: Join challenge logic */
            },
            child: const Text('Join Challenge'),
          ),
        ),
      ],
    );
  }
}
