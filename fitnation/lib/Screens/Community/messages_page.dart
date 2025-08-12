import 'package:fitnation/Screens/Community/chat_screen.dart';
import 'package:fitnation/Screens/Community/find_friends_page.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  // Dummy data for chat participants with online avatar URLs
  final List<Map<String, String>> _chatParticipants = const [
    {
      'name': 'John Doe',
      'lastMessage': 'Hey, how was your workout?',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'time': '10:30 AM',
      'unread': '2',
    },
    {
      'name': 'Jane Smith',
      'lastMessage': 'Don\'t forget our meeting at 2 PM!',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'time': 'Yesterday',
      'unread': '',
    },
    {
      'name': 'Fitness Coach Alex',
      'lastMessage': 'Your new plan is ready!',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
      'time': 'Mon',
      'unread': '1',
    },
    {
      'name': 'Gym Buddy Sarah',
      'lastMessage': 'Leg day tomorrow?',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/4.jpg',
      'time': 'Sun',
      'unread': '',
    },
    {
      'name': 'Nutri Chef Mike',
      'lastMessage': 'Recipe for your meal plan sent!',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/5.jpg',
      'time': 'Sat',
      'unread': '3',
    },
    {
      'name': 'Support Team',
      'lastMessage': 'Your query has been resolved.',
      'avatarUrl':
          'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y', // Generic avatar
      'time': 'Fri',
      'unread': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Using MD3 background color
      appBar: AppBar(
        backgroundColor: colorScheme.surface, // AppBar matches a surface color
        title: Text(
          "Messages",
          style: textTheme.headlineSmall?.copyWith(
            // Using MD3 typography
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
          ), // Rounded icon
          onPressed: () => Navigator.pop(context),
        ),
        surfaceTintColor: Colors.transparent, // Ensures no tint on scroll
        elevation: 1, // Slight elevation for definition
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(
              16.0,
            ), // Increased padding for MD3 feel
            child: TextField(
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "Search friends...",
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor:
                    colorScheme
                        .surfaceContainerHighest, // A distinct surface color for the search field
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ), // Rounded icon
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    28,
                  ), // Pill shape for search bar
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant, // Lighter outline
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: colorScheme.primary, // Primary color on focus
                    width: 2,
                  ),
                ),
                border: OutlineInputBorder(
                  // Default border
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _chatParticipants.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    indent: 72, // Aligns with text for better visual flow
                    endIndent: 16,
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
              itemBuilder: (context, index) {
                final participant = _chatParticipants[index];
                final bool hasUnread = participant['unread']!.isNotEmpty;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 28, // Slightly larger avatar
                    backgroundColor:
                        colorScheme.primaryContainer, // Placeholder background
                    backgroundImage: NetworkImage(participant['avatarUrl']!),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback to a generic icon if image fails to load
                      debugPrint(
                        'Error loading image for ${participant['name']}: $exception',
                      );
                    },
                    child: Builder(
                      builder: (context) {
                        // Only show fallback icon if image URL is empty
                        if (participant['avatarUrl']!.isEmpty) {
                          return Icon(
                            Icons.person_rounded,
                            color: colorScheme.onPrimaryContainer,
                            size: 32,
                          );
                        }
                        // Let NetworkImage handle displaying if successful
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  title: Text(
                    participant['name']!,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    participant['lastMessage']!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        participant['time']!,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                colorScheme
                                    .error, // Error color for unread count
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            participant['unread']!,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ChatScreen(friendName: participant['name']!),
                      ),
                    );
                  },
                  splashColor: colorScheme.primary.withOpacity(0.1),
                  hoverColor: colorScheme.primary.withOpacity(0.05),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FindFriendsPage()),
          );
        },
        icon: Icon(
          Icons.person_add_alt_1_rounded,
          color: colorScheme.onPrimaryContainer,
        ), // Rounded icon
        label: Text(
          "Add Friend",
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
    );
  }
}
