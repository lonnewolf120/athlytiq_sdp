import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final dynamic profile;
  const HomeHeader({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center, size: 40),
              ),
              const SizedBox(width: 12),
              Text(
                'FitNation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (profile != null)
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                profile.displayName != null && profile.displayName.isNotEmpty
                    ? profile.displayName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
