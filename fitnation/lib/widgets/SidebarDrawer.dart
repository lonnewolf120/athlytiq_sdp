import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnation/core/themes/colors.dart' as app_colors;
import 'package:fitnation/providers/auth_provider.dart' as auth_provider;
import 'package:fitnation/providers/theme_provider.dart';
import 'package:fitnation/Screens/ProfileScreen.dart';
import 'package:fitnation/Screens/SettingsScreen.dart';
import 'package:fitnation/Screens/Community/CommunityHome.dart';
import 'package:fitnation/Screens/Activities/WorkoutScreen.dart';
import 'package:fitnation/Screens/nutrition/NutritionScreen.dart';
import 'package:fitnation/Screens/shop_page.dart';

class SidebarDrawer extends ConsumerWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(auth_provider.authProvider);
    final currentAppThemeMode =
        ref.watch(themeNotifierProvider.notifier).currentAppThemeMode;

    // If user is not authenticated, show minimal drawer
    if (authState is! auth_provider.Authenticated) {
      return _buildUnauthenticatedDrawer(context, ref);
    }

    final user = authState.user;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // User Profile Section
          _buildUserProfileSection(context, user, ref),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Main Navigation
                _buildSectionHeader(context, 'Navigation'),
                _buildNavItem(
                  context: context,
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to home or stay on current screen
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.people_alt_outlined,
                  title: 'Community',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CommunityHomeScreen(),
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.sports_mma,
                  title: 'Workouts',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkoutScreen(),
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.fastfood,
                  title: 'Nutrition',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NutritionScreen(),
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.shop_2,
                  title: 'Shop',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopPage()),
                    );
                  },
                ),

                const Divider(),

                // Additional Features
                _buildSectionHeader(context, 'Features'),
                _buildNavItem(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Reminders',
                  onTap: () {
                    Navigator.pop(context);
                    _showRemindersDialog(context);
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.navigation_outlined,
                  title: 'Navigation Settings',
                  onTap: () {
                    Navigator.pop(context);
                    _showNavigationSettingsDialog(context);
                  },
                ),

                const Divider(),

                // App Settings
                _buildSectionHeader(context, 'Settings'),
                _buildThemeSelector(context, ref, currentAppThemeMode),
                _buildNavItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'App Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),

                const Divider(),

                // Sign Out
                _buildNavItem(
                  context: context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showSignOutDialog(context, ref);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, user, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            app_colors.AppColors.primary.withOpacity(0.8),
            app_colors.AppColors.primary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Picture
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              backgroundImage:
                  user.profile?.profilePictureUrl != null
                      ? CachedNetworkImageProvider(
                        user.profile!.profilePictureUrl!,
                      )
                      : CachedNetworkImageProvider(user.avatarUrl),
              child:
                  user.profile?.profilePictureUrl == null &&
                          user.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 35, color: Colors.grey)
                      : null,
            ),
          ),
          const SizedBox(height: 12),

          // User Name
          Text(
            user.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Username
          Text(
            '@${user.username}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Profile Navigation Button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'View Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedDrawer(BuildContext context, WidgetRef ref) {
    final currentAppThemeMode =
        ref.watch(themeNotifierProvider.notifier).currentAppThemeMode;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  app_colors.AppColors.primary.withOpacity(0.8),
                  app_colors.AppColors.primary,
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.grey),
                ),
                SizedBox(height: 12),
                Text(
                  'Welcome to Athlytiq',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please sign in to continue',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionHeader(context, 'Settings'),
                _buildThemeSelector(context, ref, currentAppThemeMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final defaultColor = Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: iconColor ?? defaultColor, size: 24),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: textColor ?? defaultColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    return ListTile(
      leading: Icon(
        Icons.palette_outlined,
        color: Theme.of(context).colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'App Theme',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: DropdownButton<AppThemeMode>(
        value: currentMode,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        items:
            AppThemeMode.values.map((AppThemeMode mode) {
              return DropdownMenuItem<AppThemeMode>(
                value: mode,
                child: Text(
                  _getThemeDisplayName(mode),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }).toList(),
        onChanged: (AppThemeMode? newMode) {
          if (newMode != null) {
            ref.read(themeNotifierProvider.notifier).setThemeMode(newMode);
          }
        },
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  String _getThemeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  void _showRemindersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reminders'),
          content: const Text(
            'Reminder functionality will be implemented here. You can set workout reminders, meal reminders, and more.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showNavigationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Navigation Settings'),
          content: const Text(
            'Navigation settings will be implemented here. You can customize navigation preferences, shortcuts, and more.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(auth_provider.authProvider.notifier).logout();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
