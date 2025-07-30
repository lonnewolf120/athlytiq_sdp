import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/auth_provider.dart';
import 'package:fitnation/providers/theme_provider.dart';
import 'package:fitnation/Screens/ProfileScreen.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showMenuButton;
  final bool showLogo;
  final bool showProfileMenu;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Widget? bottom;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showMenuButton = false, // Changed default to false
    this.showLogo = true,
    this.showProfileMenu = true, // New parameter for profile menu
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    Widget titleWidget;
    if (showLogo) {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset('assets/logos/logo.png', height: 24, width: 24),
          ),
          Text(title, style: theme.textTheme.titleLarge),
        ],
      );
    } else {
      titleWidget = Text(title, style: theme.textTheme.titleLarge);
    }

    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (showMenuButton) {
      leadingWidget = Builder(
        builder:
            (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: foregroundColor ?? theme.appBarTheme.foregroundColor,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      );
    }

    List<Widget> appBarActions = [];

    // Add custom actions first
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    // Add profile menu if enabled
    if (showProfileMenu) {
      appBarActions.add(
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            child:
                authState is Authenticated &&
                        authState.user.avatarUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        authState.user.avatarUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                      ),
                    )
                    : Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
          ),
          onSelected:
              (String value) => _handleMenuSelection(context, ref, value),
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 12),
                      const Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'reminders',
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      const Text('Reminders'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'notifications',
                  child: Row(
                    children: [
                      Icon(
                        Icons.notification_important,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      const Text('Notifications'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'themes',
                  child: Row(
                    children: [
                      Icon(Icons.palette, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 12),
                      const Text('Themes'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 12),
                      const Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
        ),
      );
    }

    return AppBar(
      leading: leadingWidget,
      title: titleWidget,
      centerTitle: centerTitle,
      actions: appBarActions,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? theme.appBarTheme.elevation,
      bottom: bottom as PreferredSizeWidget?,
    );
  }

  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 'reminders':
        _showRemindersDialog(context);
        break;
      case 'notifications':
        _showNotificationsDialog(context);
        break;
      case 'themes':
        _showThemeDialog(context, ref);
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'logout':
        _showLogoutDialog(context, ref);
        break;
    }
  }

  void _showRemindersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reminders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Workout Reminders'),
                subtitle: const Text(
                  'Get notified about your workout schedule',
                ),
                trailing: Switch(
                  value: true, // You can connect this to a provider
                  onChanged: (value) {
                    // Handle workout reminder toggle
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Nutrition Reminders'),
                subtitle: const Text(
                  'Track your meal times and nutrition goals',
                ),
                trailing: Switch(
                  value: false, // You can connect this to a provider
                  onChanged: (value) {
                    // Handle nutrition reminder toggle
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('Push Notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Handle push notification toggle
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email Notifications'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // Handle email notification toggle
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light Mode'),
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(AppThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(AppThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_system_daydream),
                title: const Text('System'),
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(AppThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (this.bottom != null) {
      height += (this.bottom as PreferredSizeWidget).preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}
