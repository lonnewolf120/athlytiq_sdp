import 'package:flutter/material.dart';
import 'package:fitnation/models/User.dart';

class ParticipantAvatar extends StatelessWidget {
  final User user;
  final double radius;
  final bool hasBorder;

  const ParticipantAvatar({
    super.key,
    required this.user,
    this.radius = 20,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: hasBorder ? Colors.black : Colors.transparent,
      child: CircleAvatar(
        radius: hasBorder ? radius - 2 : radius,
        backgroundImage: AssetImage(user.avatarUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle image load error, e.g., show initials
        },
      ),
    );
  }
}

class StackedParticipantAvatars extends StatelessWidget {
  final List<User> users;
  final int maxAvatars;
  final double avatarRadius;

  const StackedParticipantAvatars({
    super.key,
    required this.users,
    this.maxAvatars = 3,
    this.avatarRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    final displayedUsers = users.take(maxAvatars).toList();
    final remainingCount = users.length - maxAvatars;

    return SizedBox(
      height: avatarRadius * 2,
      child: Stack(
        children: [
          ...List.generate(displayedUsers.length, (index) {
            return Positioned(
              left: index * (avatarRadius * 1.2), // Overlap
              child: ParticipantAvatar(
                user: displayedUsers[index],
                radius: avatarRadius,
                hasBorder: true,
              ),
            );
          }),
          if (remainingCount > 0)
            Positioned(
              left: maxAvatars * (avatarRadius * 1.2),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.orange,
                child: Text(
                  '+$remainingCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
