import 'package:flutter/material.dart';

// Individual chip widget - kept private as it's specific to this section
class _TopicChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // The Chip widget automatically uses ChipThemeData from the MaterialApp's theme
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        // You can override specific properties here if the theme isn't sufficient
        // e.g., backgroundColor: Colors.blueGrey[700],
        // labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
        // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
      ),
    );
  }
}

// Main reusable widget for the "Explore communities by topic" section
class TopicChipsSection extends StatelessWidget {
  final String title;
  final List<String> topics;
  final Function(String topicName) onTopicSelected; // Callback for when a topic chip is tapped

  const TopicChipsSection({
    super.key,
    required this.title,
    required this.topics,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 20.0, bottom: 12.0, right: 16.0),
          child: Text(
            title,
            style: theme.textTheme.titleLarge, // Uses style from the app's theme
          ),
        ),
        // Horizontally scrollable list of topic chips
        SizedBox(
          // Height needs to be constrained for horizontal ListView.
          // This value should be enough to fit the chips comfortably.
          // Default Chip height is around 32-38px depending on padding/font.
          // Add some vertical padding/margin if chips are close to edges.
          height: 50, // Chip height (from theme ~38px) + vertical spacing.
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0), // Padding for first/last chip
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Padding(
                // Spacing between individual chips
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _TopicChip(
                  label: topic,
                  onTap: () {
                    print("TopicChipsSection: Chip '${topic}' tapped.");
                    onTopicSelected(topic);
                  }
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}