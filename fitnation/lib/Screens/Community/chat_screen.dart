import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_models.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/text_styles.dart';
import 'chat_room_screen.dart';
// import 'create_chat_room_screen.dart'; // TODO: Fix CreateChatRoomScreen implementation

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize chat provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('Messages', style: AppTextStyles.darkHeadlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement CreateChatRoomScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Create chat feature coming soon!'),
                ),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const CreateChatRoomScreen(),
              //   ),
              // );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryForeground,
          labelColor: AppColors.primaryForeground,
          unselectedLabelColor: AppColors.primaryForeground.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChatsTab(), _buildFriendsTab(), _buildRequestsTab()],
      ),
    );
  }

  Widget _buildChatsTab() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final rooms = chatProvider.rooms;

        if (rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.darkSecondaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: AppTextStyles.darkBodyLarge.copyWith(
                    color: AppColors.darkSecondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation with your friends',
                  style: AppTextStyles.darkBodyMedium.copyWith(
                    color: AppColors.darkSecondaryText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _buildChatRoomItem(room);
          },
        );
      },
    );
  }

  Widget _buildChatRoomItem(ChatRoom room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          backgroundImage:
              room.imageUrl != null ? NetworkImage(room.imageUrl!) : null,
          child:
              room.imageUrl == null
                  ? Text(
                    room.name?.isNotEmpty == true
                        ? room.name![0].toUpperCase()
                        : '?',
                    style: AppTextStyles.darkBodyLarge.copyWith(
                      color: AppColors.primaryForeground,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
        ),
        title: Text(
          room.name ?? 'Direct Message',
          style: AppTextStyles.darkBodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          room.lastMessageContent ?? 'No messages yet',
          style: AppTextStyles.darkBodyMedium.copyWith(
            color: AppColors.darkSecondaryText,
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
                _formatTime(room.lastMessageAt!),
                style: AppTextStyles.darkBodySmall.copyWith(
                  color: AppColors.darkSecondaryText,
                ),
              ),
            if (room.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  room.unreadCount.toString(),
                  style: AppTextStyles.darkBodySmall.copyWith(
                    color: AppColors.primaryForeground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatRoomScreen(room: room)),
          );
        },
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final friends = chatProvider.friends;

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.darkSecondaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  'No friends yet',
                  style: AppTextStyles.darkBodyLarge.copyWith(
                    color: AppColors.darkSecondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add friends to start chatting',
                  style: AppTextStyles.darkBodyMedium.copyWith(
                    color: AppColors.darkSecondaryText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return _buildFriendItem(friend);
          },
        );
      },
    );
  }

  Widget _buildFriendItem(Friend friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              backgroundImage:
                  friend.avatarUrl != null
                      ? NetworkImage(friend.avatarUrl!)
                      : null,
              child:
                  friend.avatarUrl == null
                      ? Text(
                        friend.username[0].toUpperCase(),
                        style: AppTextStyles.darkBodyLarge.copyWith(
                          color: AppColors.primaryForeground,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            if (friend.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryForeground,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          friend.displayName ?? friend.username,
          style: AppTextStyles.darkBodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          friend.isOnline
              ? 'Online'
              : friend.lastSeen != null
              ? 'Last seen ${_formatTime(friend.lastSeen!)}'
              : 'Offline',
          style: AppTextStyles.darkBodyMedium.copyWith(
            color: friend.isOnline ? Colors.green : AppColors.darkSecondaryText,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () async {
            try {
              final room = await context
                  .read<ChatProvider>()
                  .createDirectChatRoom(friend.id);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(room: room),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error creating chat: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final requests = chatProvider.friendRequests;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 64,
                  color: AppColors.darkSecondaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  'No friend requests',
                  style: AppTextStyles.darkBodyLarge.copyWith(
                    color: AppColors.darkSecondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Friend requests will appear here',
                  style: AppTextStyles.darkBodyMedium.copyWith(
                    color: AppColors.darkSecondaryText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildFriendRequestItem(request);
          },
        );
      },
    );
  }

  Widget _buildFriendRequestItem(FriendRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  backgroundImage:
                      request.requesterAvatar != null
                          ? NetworkImage(request.requesterAvatar!)
                          : null,
                  child:
                      request.requesterAvatar == null
                          ? Text(
                            request.requesterUsername[0].toUpperCase(),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primaryForeground,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterDisplayName ??
                            request.requesterUsername,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Wants to be your friend',
                        style: AppTextStyles.darkBodyMedium.copyWith(
                          color: AppColors.darkSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.message != null) ...[
              const SizedBox(height: 8),
              Text(request.message!, style: AppTextStyles.bodyMedium),
              Text(request.message!, style: AppTextStyles.darkBodyMedium),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<ChatProvider>().respondToFriendRequest(
                        request.id,
                        true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<ChatProvider>().respondToFriendRequest(
                        request.id,
                        false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkSecondaryText,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
