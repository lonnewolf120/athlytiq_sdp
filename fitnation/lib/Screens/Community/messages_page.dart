import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/colors.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_models.dart';
import 'individual_chat_screen.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
          'Messages',
          style: TextStyle(color: AppColors.darkPrimaryText),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.darkPrimaryText),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [_buildSearchBar(), Expanded(child: _buildChatRoomsList())],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChatDialog(context),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: AppColors.darkPrimaryText),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(
            color: AppColors.darkPrimaryText.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.darkPrimaryText.withOpacity(0.6),
          ),
          filled: true,
          fillColor: AppColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildChatRoomsList() {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    return chatRoomsAsync.when(
      data: (chatRooms) {
        // Filter chat rooms based on search query
        final filteredRooms =
            chatRooms.where((room) {
              final name = room.name?.toLowerCase() ?? '';
              final lastMessage = room.lastMessageContent?.toLowerCase() ?? '';
              return name.contains(_searchQuery) ||
                  lastMessage.contains(_searchQuery);
            }).toList();

        if (filteredRooms.isEmpty) {
          return _searchQuery.isNotEmpty
              ? _buildNoSearchResults()
              : _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredRooms.length,
          itemBuilder: (context, index) {
            final room = filteredRooms[index];
            return _buildChatRoomTile(room);
          },
        );
      },
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.darkPrimaryText.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading messages',
                  style: TextStyle(
                    color: AppColors.darkPrimaryText.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh',
                  style: TextStyle(
                    color: AppColors.darkPrimaryText.withOpacity(0.6),
                    fontSize: 14,
                  ),
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
          backgroundImage:
              room.imageUrl != null ? NetworkImage(room.imageUrl!) : null,
          child:
              room.imageUrl == null
                  ? Text(
                    room.name?.isNotEmpty == true
                        ? room.name![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
        ),
        title: Text(
          room.name ?? 'Unknown',
          style: TextStyle(
            color: AppColors.darkPrimaryText,
            fontWeight:
                room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          room.lastMessageContent ?? 'No messages yet',
          style: TextStyle(
            color: AppColors.darkPrimaryText.withOpacity(0.7),
            fontWeight:
                room.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (room.lastMessageAt != null)
              Text(
                _formatDate(room.lastMessageAt!),
                style: TextStyle(
                  color: AppColors.darkPrimaryText.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            if (room.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  room.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          ref.read(currentChatRoomProvider.notifier).state = room;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IndividualChatScreen(chatRoom: room),
            ),
          );
        },
        isThreeLine: room.lastMessageContent != null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.darkPrimaryText.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: TextStyle(
              color: AppColors.darkPrimaryText.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your friends',
            style: TextStyle(
              color: AppColors.darkPrimaryText.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateChatDialog(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Start Chat',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
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
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.darkPrimaryText.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              color: AppColors.darkPrimaryText.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: AppColors.darkPrimaryText.withOpacity(0.6),
              fontSize: 14,
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
        showDialog(
          context: context,
          builder: (context) => _CreateChatDialog(friends: friends),
        );
      },
      loading: () {
        showDialog(
          context: context,
          builder:
              (context) => const AlertDialog(
                backgroundColor: AppColors.darkSurface,
                content: SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading friends'),
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
  final List<Friend> friends;

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
        'Start New Chat',
        style: TextStyle(color: AppColors.darkPrimaryText),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child:
            widget.friends.isEmpty
                ? const Center(
                  child: Text(
                    'No friends available.\nAdd friends to start chatting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkSecondaryText),
                  ),
                )
                : ListView.builder(
                  itemCount: widget.friends.length,
                  itemBuilder: (context, index) {
                    final friend = widget.friends[index];
                    final isSelected = selectedFriendId == friend.id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        backgroundImage:
                            friend.avatarUrl != null
                                ? NetworkImage(friend.avatarUrl!)
                                : null,
                        child:
                            friend.avatarUrl == null
                                ? Text(
                                  friend.displayName?.isNotEmpty == true
                                      ? friend.displayName![0].toUpperCase()
                                      : friend.username[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                )
                                : null,
                      ),
                      title: Text(
                        friend.displayName ?? friend.username,
                        style: const TextStyle(
                          color: AppColors.darkPrimaryText,
                        ),
                      ),
                      subtitle: Text(
                        friend.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color:
                              friend.isOnline
                                  ? Colors.green
                                  : AppColors.darkSecondaryText,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check_circle,
                                color: AppColors.secondary,
                              )
                              : null,
                      onTap: () {
                        setState(() {
                          selectedFriendId = friend.id;
                          selectedFriendUsername =
                              friend.displayName ?? friend.username;
                        });
                      },
                    );
                  },
                ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.darkSecondaryText),
          ),
        ),
        ElevatedButton(
          onPressed: selectedFriendId != null ? _createDirectChat : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          child: const Text(
            'Start Chat',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _createDirectChat() async {
    if (selectedFriendId == null || selectedFriendUsername == null) return;

    Navigator.pop(context); // Close dialog

    // Create a new chat room
    final createChat = ref.read(createDirectChatProvider);
    final chatRoom = await createChat(
      selectedFriendId!,
      selectedFriendUsername!,
    );

    if (mounted) {
      // Navigate to the new chat
      ref.read(currentChatRoomProvider.notifier).state = chatRoom;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IndividualChatScreen(chatRoom: chatRoom),
        ),
      );
    }
  }
}
