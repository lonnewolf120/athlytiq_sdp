import 'package:fitnation/main.dart';
import 'package:fitnation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppThemeMode =
        ref.watch(themeNotifierProvider.notifier).currentAppThemeMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<AppThemeMode>(
              value: currentAppThemeMode,
              items:
                  AppThemeMode.values.map((AppThemeMode mode) {
                    return DropdownMenuItem<AppThemeMode>(
                      value: mode,
                      child: Text(mode.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
              onChanged: (AppThemeMode? newMode) {
                if (newMode != null) {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(newMode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
