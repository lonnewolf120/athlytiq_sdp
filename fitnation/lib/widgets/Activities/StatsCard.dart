// lib/widgets/Activities/StatsCard.dart
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor; // Optional custom icon color

  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card theme is applied globally, but we can override margin/padding
      margin: EdgeInsets.zero, // No margin needed if used in a GridView/Wrap with spacing
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Card padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
            Icon(icon, size: 24, color: iconColor ?? AppColors.primary), // Use primary or custom color
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ), // Use bodyMedium for the label
              ],
            ),
            const SizedBox(height: 4),

            Text(
              value,
              style: AppTextStyles.headlineMedium?.copyWith(
                color: AppColors.foreground,
              ),
            ), // Use a headline style for the value
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}