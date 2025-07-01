import 'package:flutter/material.dart';
import 'package:fitnation/models/Community.dart';
import 'package:fitnation/widgets/ParticipantAvatar.dart';

class CommunityCard extends StatelessWidget {
  final Community community;

  const CommunityCard({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              community.imageUrl!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${community.memberCount} Member',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 8),
                StackedParticipantAvatars(
                  users: community.members ?? [],
                  avatarRadius: 10,
                  maxAvatars: 3,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle Join Community
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle: const TextStyle(fontSize: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
