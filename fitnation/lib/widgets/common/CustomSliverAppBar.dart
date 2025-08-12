import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/auth_provider.dart';
import 'package:fitnation/providers/theme_provider.dart';
import 'package:fitnation/Screens/ProfileScreen.dart';

class CustomSliverAppBar extends ConsumerWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showMenuButton;
  final bool showLogo;
  final bool showProfileMenu;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool pinned;
  final bool floating;
  final PreferredSizeWidget? bottom;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showMenuButton = false,
    this.showLogo = false,
    this.showProfileMenu = true,
    this.backgroundColor,
    this.foregroundColor,
    this.pinned = true,
    this.floating = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    Widget titleWidget = Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: foregroundColor ?? Colors.white,
      ),
    );

    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (showMenuButton) {
      leadingWidget = Builder(
        builder:
            (context) => IconButton(
              icon: Icon(Icons.menu, color: foregroundColor ?? Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      );
    }

    List<Widget> appBarActions = [];

    // Add custom actions first
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    // Add profile menu if enabled (using same logic as CustomAppBar)
    if (showProfileMenu) {
      appBarActions.add(PopupProfile(context, ref, authState, theme));
    }

    return SliverAppBar(
      leading: leadingWidget,
      title: titleWidget,
      actions: appBarActions,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      pinned: pinned,
      floating: floating,
      bottom: bottom,
    );
  }

  Widget PopupProfile(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    ThemeData theme,
  ) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white.withOpacity(0.2),
        child:
            authState is Authenticated && authState.user.avatarUrl.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    authState.user.avatarUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                )
                : Icon(Icons.person, color: Colors.white, size: 20),
      ),
      onSelected: (String value) => _handleMenuSelection(context, ref, value),
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
}
