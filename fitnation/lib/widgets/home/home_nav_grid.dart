import 'package:flutter/material.dart';

class HomeNavGrid extends StatelessWidget {
  const HomeNavGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        children: [
          _NavCard(
            icon: Icons.fitness_center,
            title: 'Workouts',
            subtitle: 'Log your fitness activities',
            onTap: () {},
          ),
          _NavCard(
            icon: Icons.trending_up,
            title: 'Progress',
            subtitle: 'Track your fitness journey',
            onTap: () {},
          ),
          _NavCard(
            icon: Icons.groups,
            title: 'Community',
            subtitle: 'Connect with fitness enthusiasts',
            onTap: () {},
            isWide: true,
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isWide;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
