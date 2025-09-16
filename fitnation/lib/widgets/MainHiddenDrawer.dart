import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:fitnation/core/themes/colors.dart' as app_colors;
import 'package:fitnation/providers/auth_provider.dart' as auth_provider;
import 'package:fitnation/Screens/ProfileScreen.dart';
import 'package:fitnation/Screens/SettingsScreen.dart';
import 'package:fitnation/Screens/Community/CommunityHome.dart';
import 'package:fitnation/Screens/Activities/WorkoutScreen.dart';
import 'package:fitnation/Screens/nutrition/NutritionScreen.dart';
import 'package:fitnation/Screens/shop_page.dart';
import 'package:fitnation/Screens/Community/CommunityGroups.dart';
import 'package:fitnation/pages/exercise_search_page.dart';
import 'package:fitnation/widgets/SidebarMenuView.dart';

class MainHiddenDrawer extends ConsumerStatefulWidget {
  const MainHiddenDrawer({super.key});

  @override
  ConsumerState<MainHiddenDrawer> createState() => _MainHiddenDrawerState();
}

class _MainHiddenDrawerState extends ConsumerState<MainHiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];

  void _buildPages(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final baseStyle = TextStyle(
      color: brightness == Brightness.dark ? Colors.white : Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
    final selectedStyle = TextStyle(
      color: app_colors.AppColors.primary,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    _pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Home',
          baseStyle: baseStyle,
          selectedStyle: selectedStyle,
          colorLineSelected: app_colors.AppColors.primary,
        ),
        const CommunityHomeScreen(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Community Groups',
          baseStyle: baseStyle,
          selectedStyle: selectedStyle,
          colorLineSelected: app_colors.AppColors.primary,
        ),
        const CommunityGroupsScreen(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Workouts',
          baseStyle: baseStyle,
          selectedStyle: selectedStyle,
          colorLineSelected: app_colors.AppColors.primary,
        ),
        const WorkoutScreen(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Exercise Search',
          baseStyle: baseStyle,
          selectedStyle: selectedStyle,
          colorLineSelected: app_colors.AppColors.primary,
        ),
        const ExerciseSearchPage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Nutrition',
          baseStyle: baseStyle,
          selectedStyle: selectedStyle,
          colorLineSelected: app_colors.AppColors.primary,
        ),
        const NutritionScreen(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Shop',
          baseStyle: baseStyle,
          selectedStyle: selectedStyle,
          colorLineSelected: app_colors.AppColors.primary,
        ),
        const ShopPage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Profile',
          baseStyle: baseStyle,
          selectedStyle: selectedStyle,
          colorLineSelected: app_colors.AppColors.primary,
        ),
        const ProfileScreen(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Settings',
          baseStyle: baseStyle,
          selectedStyle: selectedStyle,
          colorLineSelected: app_colors.AppColors.primary,
        ),
        const SettingsScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(auth_provider.authProvider);

    // If user is not authenticated, show simple screen
    if (authState is! auth_provider.Authenticated) {
      return _buildUnauthenticatedView();
    }

    // Build pages with context available
    _buildPages(context);

    final brightness = Theme.of(context).brightness;

    return HiddenDrawerMenu(
      backgroundColorMenu:
          brightness == Brightness.dark
              ? app_colors.AppColors.darkBackground
              : Colors.white,
      backgroundColorAppBar: Colors.transparent,
      backgroundColorContent:
          brightness == Brightness.dark
              ? app_colors.AppColors.darkBackground
              : Colors.white,
      screens: _pages,
      initPositionSelected: 0,
      slidePercent: 60,
      contentCornerRadius: 25,
      elevationAppBar: 0,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
      actionsAppBar: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => _showCustomSidebar(context),
          tooltip: 'Profile & Settings',
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: app_colors.AppColors.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Athlytiq',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please sign in to continue',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomSidebar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Sidebar content
                const Expanded(child: SidebarMenuView()),
              ],
            ),
          ),
    );
  }
}
