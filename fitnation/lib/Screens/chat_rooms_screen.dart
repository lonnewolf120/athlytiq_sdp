import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';
import '../providers/chat_providers.dart';

class ChatRoomsScreen extends ConsumerStatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  ConsumerState<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends ConsumerState<ChatRoomsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load rooms when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomsProvider.notifier).loadRooms(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(chatRoomsProvider.notifier).loadRooms();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomsState = ref.watch(chatRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(chatRoomsProvider.notifier).loadRooms(refresh: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => _showCreateGroupDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (roomsState.error != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      roomsState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(chatRoomsProvider.notifier).clearError();
                    },
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: roomsState.isLoading && roomsState.rooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : roomsState.rooms.isEmpty
                    ? _buildEmptyState()
                    : _buildRoomsList(roomsState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStartChatDialog(context),
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation with your friends!',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList(ChatRoomsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(chatRoomsProvider.notifier).loadRooms(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.rooms.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.rooms.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final room = state.rooms[index];
          return _buildRoomTile(room);
        },
      ),
    );
  }

  Widget _buildRoomTile(ChatRoom room) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: room.imageUrl != null 
            ? NetworkImage(room.imageUrl!) 
            : null,
        child: room.imageUrl == null 
            ? Icon(room.type == ChatRoomType.group 
                ? Icons.group 
                : Icons.person)
            : null,
      ),
      title: Text(
        room.name ?? 'Direct Chat',
        style: TextStyle(
          fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: room.lastMessageContent != null
          ? Text(
              room.lastMessageContent!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: room.unreadCount > 0 ? Colors.black87 : Colors.grey,
              ),
            )
          : Text(
              'No messages yet',
              style: TextStyle(color: Colors.grey[400]),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessageAt != null)
            Text(
              _formatTime(room.lastMessageAt!),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          if (room.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${room.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (room.isMuted)
            const Icon(
              Icons.volume_off,
              size: 16,
              color: Colors.grey,
            ),
        ],
      ),
      onTap: () => _openChatRoom(room),
      onLongPress: () => _showRoomOptions(context, room),
    );
  }

  void _openChatRoom(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(room: room),
      ),
    );
  }

  void _showRoomOptions(BuildContext context, ChatRoom room) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(room.isMuted ? Icons.volume_up : Icons.volume_off),
            title: Text(room.isMuted ? 'Unmute' : 'Mute'),
            onTap: () {
              ref.read(chatRoomsProvider.notifier)
                  .updateRoomSettings(room.id, isMuted: !room.isMuted);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(room.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            title: Text(room.isPinned ? 'Unpin' : 'Pin'),
            onTap: () {
              ref.read(chatRoomsProvider.notifier)
                  .updateRoomSettings(room.id, isPinned: !room.isPinned);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Leave Chat', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLeaveConfirmation(context, room);
            },
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context, ChatRoom room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Chat'),
        content: Text('Are you sure you want to leave "${room.name ?? 'this chat'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement leave room functionality
              Navigator.pop(context);
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showStartChatDialog(BuildContext context) {
    // TODO: Navigate to friends list or user search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon: Start new chat')),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    // TODO: Navigate to group creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon: Create group chat')),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

// Placeholder ChatRoomScreen
class ChatRoomScreen extends ConsumerWidget {
  final ChatRoom room;
  
  const ChatRoomScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(room.name ?? 'Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Chat room implementation coming soon...'),
      ),
    );
  }
}
