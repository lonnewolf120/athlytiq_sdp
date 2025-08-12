import 'package:flutter/material.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/core/themes/colors.dart' as app_colors;
import 'booking.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Trainer Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        //title: const Text('Trainer Profile', style: TextStyle.),
        backgroundColor: app_colors.AppColors.lightGradientStart,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trainer Picture
                CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage(
                    'assets/trainer.jpg',
                  ), // Trainer pic here
                  backgroundColor: app_colors.AppColors.darkSurface,
                ),
                const SizedBox(width: 24),
                // trainer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Akram Emtiaz', style: AppTextStyles.darkBodyLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Certified Strength & Conditioning Specialist',
                        style: AppTextStyles.darkBodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        // rating stars to be updated later on
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Icon(Icons.star_half, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text('4.7', style: AppTextStyles.darkBodyMedium),
                        ],
                      ),
                      // call details from database
                      const SizedBox(height: 8),
                      Text(
                        'Contact: +1 555-123-4567',
                        style: AppTextStyles.darkBodyMedium,
                      ),
                      Text(
                        'Email: alex.johnson@athlytiq.com',
                        style: AppTextStyles.darkBodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // book now button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: app_colors.AppColors.primary,
                  foregroundColor: app_colors.AppColors.primaryForeground,
                  textStyle: AppTextStyles.darkHeadlineMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingScreen(),
                    ),
                  );
                },
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
