import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:fitnation/Screens/Activities/WorkoutScreen.dart';
import 'package:fitnation/Screens/Community/CommunityGroups.dart';
import 'package:fitnation/Screens/Community/CommunityHome.dart';
import 'package:fitnation/Screens/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:fitnation/Screens/nutrition/NutritionScreen.dart'; // Import NutritionScreen

enum NavItem {
  home,
  account,
  favorite,
  nutrition, // Added nutrition
  settings;

  IconData get iconData {
    switch (this) {
      case home:
        return Icons.home_filled;
      case account:
        return Icons.people_alt_outlined;
      case favorite:
        return Icons.sports_mma;
      case nutrition:
        return Icons.fastfood; // Icon for nutrition
      case settings:
        return Icons.person;
    }
  }

  String get logos {
    switch (this) {
      case home:
        return 'assets/logos/Gym.png';
      case account:
        return 'assets/logos/gymbros.png';
      case favorite:
        return 'assets/logos/gym_report.png';
      case nutrition:
        return 'assets/logos/food.png'; // Logo for nutrition
      case settings:
        return 'assets/logos/profile.png';
    }
  }

  Color get color {
    switch (this) {
      case home:
        return Colors.red;
      case account:
        return const Color.fromARGB(255, 223, 65, 13);
      case favorite:
        return Colors.pink;
      case nutrition:
        return Colors.green; // Color for nutrition
      case settings:
        return const Color.fromARGB(255, 255, 121, 11);
    }
  }

  String get title {
    switch (this) {
      case home:
        return 'Home';
      case account:
        return 'Account';
      case favorite:
        return 'Favorite';
      case nutrition:
        return 'Nutrition';
      case settings:
        return 'Settings';
    }
  }

  BottomBarItem get option {
    return BottomBarItem(
      inActiveItem: Icon(
        iconData,
        color: const Color.fromARGB(255, 32, 32, 31),
      ),
      activeItem: Icon(iconData, color: color),
      itemLabel: title,
    );
  }
}

/// widget list for the bottom bar pages indexed
final List<Widget> navPages = [
  const CommunityHomeScreen(),
  const CommunityGroupsScreen(),
  const WorkoutScreen(),
  const NutritionScreen(), // Added Nutrition Screen
  const ProfileScreen(),
];
