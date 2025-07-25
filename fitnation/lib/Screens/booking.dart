import 'package:flutter/material.dart';
import 'themes/text_styles.dart';
import 'themes/colors.dart' as app_colors;

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _selectedGoal;
  String? _selectedDuration;
  String? _selectedPayment;

  final List<String> _goals = [
    'Weight Loss',
    'Muscle Gain',
    'Endurance',
    'Flexibility',
    'General Fitness',
  ];
  final List<String> _durations = [
    '30 Minutes',
    '1 Hour',
    '2 Hours',
    'Custom',
  ];
  final List<String> _payments = [
    'Credit Card',
    'Apple Pay',
    'Google Pay',
    'Bkash',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: app_colors.AppColors.lightGradientStart,
        actions: [
          TextButton(
            onPressed: () {
              // Show consult dialog or navigate
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Consultation'),
                  content: const Text('Contact the trainer for a free consultation before booking?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Choose Options'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Consult before booking?'),
            style: TextButton.styleFrom(
              foregroundColor: app_colors.AppColors.lightPrimaryText,
              textStyle: AppTextStyles.lightBodyLarge,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select your goal', style: AppTextStyles.darkHeadlineMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGoal,
              items: _goals.map((goal) => DropdownMenuItem(
                value: goal,
                child: Text(goal, style: AppTextStyles.darkBodyMedium),
              )).toList(),
              onChanged: (val) => setState(() => _selectedGoal = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: app_colors.AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: app_colors.AppColors.darkInputBorder),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select duration', style: AppTextStyles.darkHeadlineMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDuration,
              items: _durations.map((duration) => DropdownMenuItem(
                value: duration,
                child: Text(duration, style: AppTextStyles.darkBodyMedium),
              )).toList(),
              onChanged: (val) => setState(() => _selectedDuration = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: app_colors.AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: app_colors.AppColors.darkInputBorder),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select payment method', style: AppTextStyles.darkHeadlineMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPayment,
              items: _payments.map((pay) => DropdownMenuItem(
                value: pay,
                child: Text(pay, style: AppTextStyles.darkBodyMedium),
              )).toList(),
              onChanged: (val) => setState(() => _selectedPayment = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: app_colors.AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: app_colors.AppColors.darkInputBorder),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: app_colors.AppColors.darkGradientStart,
                  foregroundColor: app_colors.AppColors.primaryForeground,
                  textStyle: AppTextStyles.darkHeadlineMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: (_selectedGoal != null && _selectedDuration != null && _selectedPayment != null)
                    ? () {
                        // Handle booking logic here
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Booking Confirmed'),
                            content: Text('You have booked a session for \\$_selectedGoal (\\${_selectedDuration!}) using \\$_selectedPayment.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                child: const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
