import 'package:fitnation/models/CommunityContentModel.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback? onTap;
  final VoidCallback? onJoinToggle;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.onJoinToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0), // Margin between cards
      clipBehavior: Clip.antiAlias, // Ensures child respects border radius
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Card padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community Image (Rounded Square)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Rounded square
                child: CachedNetworkImage(
                  imageUrl: group.image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.mutedBackground),
                  errorWidget: (context, url, error) => const Icon(Icons.group, size: 40, color: AppColors.mutedForeground),
                ),
              ),
              const SizedBox(width: 16),
              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: textTheme.headlineSmall?.copyWith(color: AppColors.cardForeground)),
                    const SizedBox(height: 4),
                    Text(
                      group.description,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: group.categories
                          .map((category) => Chip(
                                label: Text(category),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.group_outlined, size: 16, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text('${group.memberCount} members', style: textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.post_add_outlined,
                          size: 16,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text('${group.postCount} posts', style: textTheme.labelSmall),
                     
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Join Button
              ElevatedButton(
                onPressed: onJoinToggle ?? () {
                  // TODO: Implement join/leave logic
                  print("Toggle join for ${group.name}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: group.joined ? AppColors.secondary : AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)
                ),
                child: Text(group.joined ? 'Joined' : 'Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}