import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package

class FindFriendsPage extends StatelessWidget {
  const FindFriendsPage({super.key});

  // Method to handle sharing the app
  Future<void> _shareApp(BuildContext context) async {
    final String appLink =
        "Check out Athlytiq, the ultimate fitness companion! Download it here: https://play.google.com/store/apps/details?id=com.semaphore.athlytiq";
    await Share.share(
      appLink,
      subject: "Join me on Athlytiq!",
    ); // Optional subject for email/messages

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing Athlytiq with your friends!',
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.background, // MD3 background color
        appBar: AppBar(
          backgroundColor: colorScheme.surface, // MD3 surface color
          foregroundColor: colorScheme.onSurface, // Icon/text color on AppBar
          elevation: 1, // Slight elevation for distinction
          surfaceTintColor: Colors.transparent, // Prevents default tint
          title: Text(
            "Find Friends",
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor:
                colorScheme.primary, // MD3 primary color for selected tab
            unselectedLabelColor:
                colorScheme.onSurfaceVariant, // MD3 for unselected
            indicatorColor: colorScheme.primary, // Indicator matches primary
            indicatorSize:
                TabBarIndicatorSize.tab, // Indicator spans the full tab
            dividerColor: colorScheme.outlineVariant, // Subtle divider
            labelStyle: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ), // MD3 typography
            unselectedLabelStyle: textTheme.titleMedium, // MD3 typography
            tabs: const [Tab(text: "Suggested"), Tab(text: "Contacts")],
          ),
        ),
        body: const Column(
          children: [
            Expanded(
              child: TabBarView(children: [SuggestedTab(), ContactsTab()]),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _shareApp(context), // Call the share method
          icon: Icon(
            Icons.share_rounded,
            color: colorScheme.onPrimaryContainer,
          ), // Share icon
          label: Text(
            "Invite Friends",
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ), // MD3 labelLarge
          ),
          backgroundColor:
              colorScheme
                  .primaryContainer, // Use primaryContainer for a more subtle FAB
          foregroundColor: colorScheme.onPrimaryContainer,
          elevation: 4, // MD3 elevation
        ),
      ),
    );
  }
}

class SuggestedTab extends StatelessWidget {
  const SuggestedTab({super.key});

  // Dummy data for suggested users with online avatar URLs
  final List<Map<String, String>> _suggestedUsers = const [
    {
      'name': 'Olivia Chen',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/5.jpg',
      'mutualFriends': '3 mutual friends',
    },
    {
      'name': 'Michael Lee',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/6.jpg',
      'mutualFriends': '1 mutual friend',
    },
    {
      'name': 'Sophia Rodriguez',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/7.jpg',
      'mutualFriends': 'No mutual friends',
    },
    {
      'name': 'David Kim',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/8.jpg',
      'mutualFriends': '5 mutual friends',
    },
    {
      'name': 'Emily White',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/9.jpg',
      'mutualFriends': '2 mutual friends',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Search bar for SuggestedTab
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Search suggested users...",
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero, // Remove default list padding
            itemCount: _suggestedUsers.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  indent: 72, // Aligns with text for better visual flow
                  endIndent: 16,
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
            itemBuilder: (context, index) {
              final user = _suggestedUsers[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 28, // Consistent avatar size
                  backgroundColor:
                      colorScheme.primaryContainer, // Placeholder background
                  backgroundImage: NetworkImage(user['avatarUrl']!),
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint(
                      'Error loading image for ${user['name']}: $exception',
                    );
                  },
                  child: Builder(
                    builder: (context) {
                      // Only check if avatarUrl is empty to show fallback icon
                      if (user['avatarUrl']!.isEmpty) {
                        return Icon(
                          Icons.person_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 32,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                title: Text(
                  user['name']!,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  user['mutualFriends']!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Friend request sent to ${user['name']}!',
                          style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        backgroundColor: colorScheme.secondaryContainer,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    // Implement friend request logic
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    "Add Friend",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                splashColor: colorScheme.primary.withOpacity(0.1),
                hoverColor: colorScheme.primary.withOpacity(0.05),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  // Dummy data for contacts
  final List<Map<String, String>> _contacts = const [
    {'name': 'Robert Brown', 'phoneNumber': '+1 555-123-4567'},
    {'name': 'Linda Davis', 'phoneNumber': '+1 555-987-6543'},
    {'name': 'Chris Wilson', 'phoneNumber': '+1 555-234-5678'},
    {'name': 'Maria Garcia', 'phoneNumber': '+1 555-876-5432'},
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Search bar for ContactsTab
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Search contacts...",
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _contacts.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      colorScheme
                          .tertiaryContainer, // Different color for contacts
                  child: Icon(
                    Icons.person_rounded,
                    color: colorScheme.onTertiaryContainer,
                    size: 32,
                  ),
                ),
                title: Text(
                  contact['name']!,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  contact['phoneNumber']!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Invitation sent to ${contact['name']}!',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    // Implement invite logic (e.g., via SMS or other share options)
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    side: BorderSide(
                      color: colorScheme.primary,
                    ), // Border color
                    foregroundColor: colorScheme.primary, // Text color
                  ),
                  child: Text("Invite", style: textTheme.labelLarge),
                ),
                splashColor: colorScheme.primary.withOpacity(0.1),
                hoverColor: colorScheme.primary.withOpacity(0.05),
              );
            },
          ),
        ),
      ],
    );
  }
}
