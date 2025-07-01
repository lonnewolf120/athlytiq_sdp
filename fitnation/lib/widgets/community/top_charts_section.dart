// lib/widgets/community/top_charts_section.dart
import 'package:flutter/material.dart';
import '../../models/top_chart_category.dart';
// Import the page you want to navigate to, e.g., TopicCommunitiesPage
import '../../screens/topic_communities_page.dart';

class TopChartsSectionWidget extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final List<TopChartCategory> categories;

  const TopChartsSectionWidget({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.categories,
  });

  void _navigateToCategoryPage(BuildContext context, TopChartCategory category) {
    print("Navigating to top chart category: ${category.title}");
    // For simplicity, we'll reuse TopicCommunitiesPage.
    // In a real app, you might have a dedicated page for "Top Charts" of a category.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicCommunitiesPage(topicName: category.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0, right: 16.0),
          child: Row(
            children: [
              Icon(
                titleIcon,
                color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
                size: 22, // Adjust size as needed
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
        // Use a ListView for the categories.
        // Since this is inside another ListView (in CommunityScreen),
        // it needs shrinkWrap and NeverScrollableScrollPhysics.
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Material( // Wrap with Material for InkWell splash effect to be visible
              color: Colors.transparent, // Ensure it doesn't obscure parent background
              child: InkWell(
                onTap: () => _navigateToCategoryPage(context, category),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // Allow text to take available space and wrap if needed
                        child: Text(
                          category.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            // color: theme.colorScheme.onSurface.withOpacity(0.9)
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Divider below the entire section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Divider(
            color: theme.dividerColor.withOpacity(0.5),
            height: 1,
          ),
        )
      ],
    );
  }
}