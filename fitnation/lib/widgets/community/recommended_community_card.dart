// lib/widgets/community/recommended_community_card.dart
import 'package:flutter/material.dart';
import '../../models/recommended_community.dart';
// Import your community detail page if you have one
// import '../../screens/community_detail_page.dart';

class RecommendedCommunityCardWidget extends StatefulWidget {
  final RecommendedCommunity community;
  final VoidCallback? onCommunityTapped; // Callback when the card is tapped

  const RecommendedCommunityCardWidget({
    super.key,
    required this.community,
    this.onCommunityTapped,
  });

  @override
  State<RecommendedCommunityCardWidget> createState() =>
      _RecommendedCommunityCardWidgetState();
}

class _RecommendedCommunityCardWidgetState
    extends State<RecommendedCommunityCardWidget> {
  late bool _isJoined;

  @override
  void initState() {
    super.initState();
    _isJoined = widget.community.isJoined;
  }

  void _toggleJoinStatus() {
    setState(() {
      _isJoined = !_isJoined;
      widget.community.isJoined = _isJoined; // Update the model instance directly
                                          // In a real app, this would likely trigger an API call
                                          // and update state via a state management solution.
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isJoined ? 'Joined ${widget.community.name}!' : 'Left ${widget.community.name}.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    return InkWell(
      onTap: widget.onCommunityTapped ?? () {
        print("Tapped on community: ${widget.community.name}");
        // Example Navigation:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(communityId: widget.community.id)));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigate to ${widget.community.name} (Placeholder)')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        // Cards usually have a slightly different background than the scaffold in dark mode
        // Or they might blend in if using Material 3 style elevation overlays
        decoration: BoxDecoration(
          // color: theme.cardColor, // This will use the theme's cardColor
          // For a subtle border to distinguish cards if cardColor is same as scaffoldBg
          border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5), width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                  backgroundImage: widget.community.iconUrl != null && widget.community.iconUrl!.isNotEmpty
                      ? NetworkImage(widget.community.iconUrl!)
                      : null,
                  child: (widget.community.iconUrl == null || widget.community.iconUrl!.isEmpty)
                      ? Text(
                          widget.community.initials,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.community.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.community.memberCount,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onSurfaceColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _toggleJoinStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isJoined
                        ? theme.colorScheme.surfaceVariant // Less prominent when joined
                        : theme.colorScheme.secondary, // Primary action color to join
                    foregroundColor: _isJoined
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: _isJoined ? 0 : 2, // Less elevation if joined
                  ),
                  child: Text(_isJoined ? 'Joined' : 'Join'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.community.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurfaceColor.withOpacity(0.85),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}