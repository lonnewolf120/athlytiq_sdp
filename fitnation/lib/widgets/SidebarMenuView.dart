import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnation/core/themes/colors.dart' as app_colors;
import 'package:fitnation/providers/auth_provider.dart' as auth_provider;
import 'package:fitnation/providers/theme_provider.dart';
import 'package:fitnation/Screens/ProfileScreen.dart';

class SidebarMenuView extends ConsumerWidget {
  final VoidCallback? onMenuItemTap;

  const SidebarMenuView({super.key, this.onMenuItemTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(auth_provider.authProvider);
    final currentAppThemeMode =
        ref.watch(themeNotifierProvider.notifier).currentAppThemeMode;
    final brightness = Theme.of(context).brightness;

    if (authState is! auth_provider.Authenticated) {
      return _buildUnauthenticatedMenu(
        context,
        ref,
        currentAppThemeMode,
        brightness,
      );
    }

    final user = authState.user;

    return Container(
      color:
          brightness == Brightness.dark
              ? app_colors.AppColors.darkBackground
              : Colors.white,
      child: Column(
        children: [
          // User Profile Header
          _buildUserProfileHeader(context, user),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),

                // Features Section
                _buildMenuSection(context, 'FEATURES'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Reminders',
                  onTap: () => _showRemindersDialog(context),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.navigation_outlined,
                  title: 'Menu Settings',
                  onTap: () => _showNavigationSettingsDialog(context),
                ),

                const SizedBox(height: 10),
                _buildDivider(brightness),

                // Settings Section
                _buildMenuSection(context, 'SETTINGS'),
                _buildThemeSelector(
                  context,
                  ref,
                  currentAppThemeMode,
                  brightness,
                ),

                const SizedBox(height: 10),
                _buildDivider(brightness),

                // Account Section
                _buildMenuSection(context, 'ACCOUNT'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () => _showSignOutDialog(context, ref),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader(BuildContext context, user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 30),
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
          // Profile Picture
          GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: CircleAvatar(
              radius: 40,
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
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
            ),
          ),
          const SizedBox(height: 15),

          // User Name
          Text(
            user.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),

          // Username
          Text(
            '@${user.username}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 15),

          // Profile Button
          GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'View Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

  Widget _buildUnauthenticatedMenu(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentAppThemeMode,
    Brightness brightness,
  ) {
    return Container(
      color:
          brightness == Brightness.dark
              ? app_colors.AppColors.darkBackground
              : Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 30,
              right: 30,
              bottom: 30,
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
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                SizedBox(height: 15),
                Text(
                  'Welcome to Pulse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
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
                const SizedBox(height: 20),
                _buildMenuSection(context, 'SETTINGS'),
                _buildThemeSelector(
                  context,
                  ref,
                  currentAppThemeMode,
                  brightness,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color:
                brightness == Brightness.dark ? Colors.white60 : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final brightness = Theme.of(context).brightness;
    final defaultColor =
        brightness == Brightness.dark ? Colors.white : Colors.black87;

    return ListTile(
      leading: Icon(icon, color: iconColor ?? defaultColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? defaultColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        onTap();
        onMenuItemTap?.call();
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
    Brightness brightness,
  ) {
    final defaultColor =
        brightness == Brightness.dark ? Colors.white : Colors.black87;

    return ListTile(
      leading: Icon(Icons.palette_outlined, color: defaultColor, size: 24),
      title: Text(
        'App Theme',
        style: TextStyle(
          color: defaultColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<AppThemeMode>(
        value: currentMode,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: defaultColor),
        dropdownColor:
            brightness == Brightness.dark
                ? app_colors.AppColors.darkSurface
                : Colors.white,
        items:
            AppThemeMode.values.map((AppThemeMode mode) {
              return DropdownMenuItem<AppThemeMode>(
                value: mode,
                child: Text(
                  _getThemeDisplayName(mode),
                  style: TextStyle(color: defaultColor, fontSize: 14),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
    );
  }

  Widget _buildDivider(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Divider(
        color: brightness == Brightness.dark ? Colors.white24 : Colors.black12,
        thickness: 1,
      ),
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

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _showRemindersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reminders'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set up your workout and nutrition reminders:'),
              SizedBox(height: 10),
              Text('• Workout reminders'),
              Text('• Meal reminders'),
              Text('• Water intake reminders'),
              Text('• Progress check-ins'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to reminders settings
              },
              child: const Text('Set Reminders'),
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
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customize your navigation preferences:'),
              SizedBox(height: 10),
              Text('• Default home screen'),
              Text('• Quick access shortcuts'),
              Text('• Navigation gestures'),
              Text('• Screen transitions'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to navigation settings
              },
              child: const Text('Configure'),
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
          content: const Text('Are you sure you want to sign out of Pulse?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(auth_provider.authProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
