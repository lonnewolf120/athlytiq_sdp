import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/providers/chat_provider.dart';
import 'package:fitnation/providers/friends_provider.dart';
import 'package:fitnation/models/chat_models.dart';
import 'package:fitnation/Screens/Community/chat_screen_new.dart' as new_chat;
import 'package:fitnation/Screens/Community/find_friends_page.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load chat rooms and friends when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomsProvider.notifier).loadChatRooms();
      ref.read(friendsProvider.notifier).loadFriends();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          "Messages",
          style: TextStyle(color: AppColors.darkPrimaryText),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.darkPrimaryText),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindFriendsPage(),
                ),
              );
            },
            tooltip: "Find Friends",
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: AppColors.darkPrimaryText),
              decoration: InputDecoration(
                hintText: "Search conversations...",
                hintStyle: const TextStyle(color: AppColors.darkHintText),
                filled: true,
                fillColor: AppColors.darkSurface,
                prefixIcon: const Icon(Icons.search, color: AppColors.darkIcon),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.darkIcon),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.darkInputBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          // Chat rooms list
          Expanded(
            child: _buildChatRoomsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChatDialog(context),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatRoomsList() {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    final friendsAsync = ref.watch(friendsProvider);

    return chatRoomsAsync.when(
      data: (chatRooms) {
        // Filter chat rooms based on search query
        final filteredRooms = chatRooms.where((room) {
          if (_searchQuery.isEmpty) return true;
          return room.name.toLowerCase().contains(_searchQuery) ||
                 room.participants.any((p) => 
                   p.displayName.toLowerCase().contains(_searchQuery) ||
                   p.username.toLowerCase().contains(_searchQuery)
                 );
        }).toList();

        if (filteredRooms.isEmpty && _searchQuery.isEmpty) {
          return _buildEmptyState();
        }

        if (filteredRooms.isEmpty && _searchQuery.isNotEmpty) {
          return _buildNoSearchResults();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.read(chatRoomsProvider.notifier).loadChatRooms();
          },
          child: ListView.builder(
            itemCount: filteredRooms.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final room = filteredRooms[index];
              return _buildChatRoomTile(room);
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              "Error loading chats: $error",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(chatRoomsProvider.notifier).loadChatRooms();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom room) {
    return Card(
      color: AppColors.darkSurface,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: room.type == 'direct'
              ? const Icon(Icons.person, color: Colors.white)
              : const Icon(Icons.group, color: Colors.white),
        ),
        title: Text(
          room.name,
          style: const TextStyle(
            color: AppColors.darkPrimaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.lastMessage != null)
              Text(
                room.lastMessage!,
                style: const TextStyle(color: AppColors.darkHintText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 2),
            Text(
              room.lastMessageAt != null
                  ? _formatDate(room.lastMessageAt!)
                  : _formatDate(room.createdAt),
              style: const TextStyle(
                color: AppColors.darkHintText,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: room.participants.length > 2 
            ? Chip(
                label: Text('${room.participants.length}'),
                backgroundColor: AppColors.darkHintText,
                labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              )
            : const Icon(Icons.chevron_right, color: AppColors.darkIcon),
        onTap: () {
          // Set current chat room
          ref.read(currentChatRoomProvider.notifier).state = room;
          
          // Navigate to chat screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => new_chat.ChatScreen(chatRoom: room),
            ),
          );
        },
        isThreeLine: room.lastMessage != null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.darkHintText,
          ),
          const SizedBox(height: 16),
          const Text(
            "No conversations yet",
            style: TextStyle(
              color: AppColors.darkHintText,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start chatting with your friends!",
            style: TextStyle(
              color: AppColors.darkHintText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindFriendsPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text(
              "Find Friends",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.darkHintText,
          ),
          const SizedBox(height: 16),
          Text(
            "No chats found for '$_searchQuery'",
            style: const TextStyle(
              color: AppColors.darkHintText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateChatDialog(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider);
    
    friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You need friends to start a chat. Add some friends first!"),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) => _CreateChatDialog(friends: friends),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Loading friends..."),
            backgroundColor: AppColors.secondary,
          ),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading friends: $error"),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (messageDate == yesterday) {
      return "Yesterday";
    } else if (now.difference(date).inDays < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}

class _CreateChatDialog extends ConsumerStatefulWidget {
  final List friends;
  
  const _CreateChatDialog({required this.friends});

  @override
  ConsumerState<_CreateChatDialog> createState() => _CreateChatDialogState();
}

class _CreateChatDialogState extends ConsumerState<_CreateChatDialog> {
  String? selectedFriendId;
  String? selectedFriendUsername;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: const Text(
        "Start New Chat",
        style: TextStyle(color: AppColors.darkPrimaryText),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: [
            const Text(
              "Select a friend to start chatting:",
              style: TextStyle(color: AppColors.darkHintText),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.friends.length,
                itemBuilder: (context, index) {
                  final friend = widget.friends[index];
                  final isSelected = selectedFriendId == friend.id;
                  
                  return Card(
                    color: isSelected ? AppColors.secondary.withOpacity(0.3) : AppColors.darkBackground,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        backgroundImage: friend.profileImageUrl != null 
                            ? NetworkImage(friend.profileImageUrl!)
                            : null,
                        child: friend.profileImageUrl == null
                            ? Text(
                                friend.displayName.isNotEmpty 
                                    ? friend.displayName[0].toUpperCase()
                                    : 'F',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        friend.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.darkPrimaryText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '@${friend.username}',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppColors.darkHintText,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedFriendId = friend.id;
                          selectedFriendUsername = friend.username;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: AppColors.darkHintText),
          ),
        ),
        ElevatedButton(
          onPressed: selectedFriendId != null ? () => _createDirectChat() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
          ),
          child: const Text(
            "Start Chat",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _createDirectChat() async {
    if (selectedFriendId == null || selectedFriendUsername == null) return;

    Navigator.pop(context); // Close dialog

    final chatRoom = await ref.read(chatRoomsProvider.notifier).createDirectChat(
      selectedFriendId!,
      selectedFriendUsername!,
    );

    if (chatRoom != null && mounted) {
      // Navigate to the new chat
      ref.read(currentChatRoomProvider.notifier).state = chatRoom;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => new_chat.ChatScreen(chatRoom: chatRoom),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to create chat"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
