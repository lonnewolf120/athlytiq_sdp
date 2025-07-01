// lib/widgets/community/recommended_communities_list.dart
import 'package:flutter/material.dart';
import '../../models/recommended_community.dart';
import 'recommended_community_card.dart';

class RecommendedCommunitiesListWidget extends StatelessWidget {
  final String title;
  final List<RecommendedCommunity> communities;

  // Define an approximate height for a single card to calculate total height
  // This should be close to the actual rendered height of RecommendedCommunityCardWidget
  // Icon (44) + Name/Members (20+16) + Spacing (2+8) + Description (18*2) + Padding (12+12) = ~150
  // Let's fine-tune this. A typical card height might be around 120-140px.
  static const double _approxCardHeight = 135.0; // Estimated height of one card
  static const double _spacingBetweenCards = 8.0;
  static const double _cardColumnWidth = 300.0; // Width for each column of 1 or 2 cards

  const RecommendedCommunitiesListWidget({
    super.key,
    required this.title,
    required this.communities,
  });

  @override
  Widget build(BuildContext context) {
    if (communities.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate the height needed for two cards stacked vertically plus spacing
    final double listHeight = (_approxCardHeight * 2) + _spacingBetweenCards + 16; // +16 for some vertical padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 12.0, right: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: listHeight, // Constrain the height of the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0), // Left padding for first item
            itemCount: (communities.length / 2).ceil(), // Number of columns (each has up to 2 cards)
            itemBuilder: (context, index) {
              final int firstCardIndex = index * 2;
              final int? secondCardIndex = (index * 2 + 1 < communities.length)
                  ? (index * 2 + 1)
                  : null;

              return Container(
                width: _cardColumnWidth, // Give each column a fixed width
                margin: const EdgeInsets.symmetric(horizontal: 4.0), // Spacing between columns
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // First card in the column
                    RecommendedCommunityCardWidget(
                      community: communities[firstCardIndex],
                    ),
                    // Second card in the column, if it exists
                    if (secondCardIndex != null) ...[
                      const SizedBox(height: _spacingBetweenCards),
                      RecommendedCommunityCardWidget(
                        community: communities[secondCardIndex],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}