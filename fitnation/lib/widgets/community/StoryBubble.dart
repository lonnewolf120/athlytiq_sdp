import 'package:fitnation/models/CommunityContentModel.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnation/Screens/Community/StoryScreen.dart';
import 'package:fitnation/Screens/Community/CreateStoryScreen.dart';

class StoryBubble extends StatelessWidget {
  final Story story;
  final ValueChanged<StoryContentItem?>? onYourStoryTap;

  const StoryBubble({
    super.key,
    required this.story,
    this.onYourStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    bool hasSeen = false; // Placeholder for story seen logic

    return SizedBox(
      width: 80, // Fixed width for each story item
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (story.isYourStory) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateStoryScreen(),
                  ),
                ).then((newContent) {
                  if (onYourStoryTap != null) {
                    onYourStoryTap!(newContent as StoryContentItem?);
                  }
                });
              } else {
                if (story.storyContent != null && story.storyContent!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryScreen(
                        storyContent: story.storyContent!,
                        userName: story.name,
                        userImage: story.image,
                      ),
                    ),
                  );
                } else {
                  print("View story: ${story.name} (No content to display)");
                }
              }
            },
            child: Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(2.5), // For the ring
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    story.isYourStory ||
                            hasSeen // Simple gradient for unread stories
                        ? null
                        : const LinearGradient(
                          colors: [
                            AppColors.primary,
                            Colors.pinkAccent,
                          ], // Example gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                border:
                    story.isYourStory || hasSeen
                        ? Border.all(
                          color: AppColors.mutedForeground,
                          width: 1.5,
                        )
                        : null,
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.mutedBackground,
                child:
                    story.image != null
                        ? CachedNetworkImage(
                          imageUrl: story.image!,
                          imageBuilder:
                              (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Center(
                                child: Icon(
                                  Icons.error,
                                  color:
                                      AppColors
                                          .error, // This should now be defined
                                  size: 30,
                                ),
                              ),
                        )
                        : (story.isYourStory
                        ? const Icon(
                              Icons.add,
                              color: AppColors.primaryForeground,
                              size: 30,
                            )
                        : (story.image == null
                            ? Text(
                                  story.name[0].toUpperCase(),
                                  style: textTheme.headlineSmall,
                                )
                                : null)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            story.name,
            style: textTheme.labelSmall?.copyWith(color: AppColors.foreground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
