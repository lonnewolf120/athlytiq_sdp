import 'package:flutter/material.dart';

class TopicCommunitiesPage extends StatelessWidget {
  final String topicName;

  const TopicCommunitiesPage({
    super.key,
    required this.topicName,
  });

  // Helper to get a somewhat relevant icon based on topic name (basic example)
  IconData _getTopicIcon(String topic) {
    String lowerTopic = topic.toLowerCase();
    if (lowerTopic.contains("run")) return Icons.directions_run;
    if (lowerTopic.contains("lift") || lowerTopic.contains("weight") || lowerTopic.contains("strength")) return Icons.fitness_center;
    if (lowerTopic.contains("yoga") || lowerTopic.contains("pilates")) return Icons.self_improvement;
    if (lowerTopic.contains("nutrition") || lowerTopic.contains("recipe")) return Icons.restaurant_menu;
    if (lowerTopic.contains("cycle")) return Icons.directions_bike;
    if (lowerTopic.contains("swim")) return Icons.pool;
    if (lowerTopic.contains("meditation") || lowerTopic.contains("wellness")) return Icons.spa_outlined;
    if (lowerTopic.contains("cardio")) return Icons.favorite_border;
    if (lowerTopic.contains("motivation")) return Icons.lightbulb_outline;
    return Icons.forum_outlined; // Default community/topic icon
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // The Scaffold and AppBar will use styles from the MaterialApp's theme
    return Scaffold(
      appBar: AppBar(
        title: Text(topicName),
        // elevation: 1.0, // Uncomment if you prefer a slight shadow
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                _getTopicIcon(topicName),
                size: 80.0,
                color: theme.colorScheme.secondary, // Use accent color from theme
              ),
              const SizedBox(height: 24.0),
              Text(
                'Welcome to "$topicName"',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Here you will find communities, discussions, and posts related to $topicName. This is a placeholder page demonstrating navigation.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.titleMedium?.color?.withOpacity(0.8), // Slightly dimmer
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.group_work_outlined),
                label: const Text('View Communities'),
                // Style comes from ElevatedButtonThemeData in MaterialApp
                onPressed: () {
                  print("TopicCommunitiesPage: 'View Communities' for $topicName tapped.");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Imagine browsing $topicName communities now! (Placeholder)'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),
              TextButton(
                onPressed: () {
                  print("TopicCommunitiesPage: 'Go Back' tapped.");
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Go Back',
                  style: TextStyle(color: theme.colorScheme.secondary), // Use accent color for emphasis
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}