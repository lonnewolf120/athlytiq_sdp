import 'package:flutter/material.dart';
import '../../themes/text_styles.dart';

class FacebookTab extends StatelessWidget {
  const FacebookTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search on Athlytiq",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Connect to Facebook"),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: () {},
            child: Text("Invite Friends", style: AppTextStyles.darkButtonText),
          ),
        ),
      ],
    );
  }
}
