import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_models.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/text_styles.dart';
import '../../widgets/community/chat_message_bubble.dart';
import '../../widgets/community/chat_input_widget.dart';
import '../../widgets/community/typing_indicator_widget.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom room;

  const ChatRoomScreen({
    Key? key,
    required this.room,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    
    // Load messages for this room
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages(widget.room.id);
      context.read<ChatProvider>().joinRoom(widget.room.id);
    });

    // Scroll to bottom when messages change
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // User is at bottom, mark messages as read
        _markMessagesAsRead();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _typingTimer?.cancel();
    
    // Leave room when screen is disposed
    context.read<ChatProvider>().leaveRoom(widget.room.id);
    
    super.dispose();
  }

  void _markMessagesAsRead() {
    final chatProvider = context.read<ChatProvider>();
    final unreadMessages = chatProvider.messages
        .where((m) => m.roomId == widget.room.id && !m.isReadByCurrentUser)
        .map((m) => m.id)
        .toList();
    
    if (unreadMessages.isNotEmpty) {
      chatProvider.markMessagesAsRead(widget.room.id, unreadMessages);
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<ChatProvider>().sendMessage(widget.room.id, content);
    _messageController.clear();
    
    // Stop typing indicator
    _stopTyping();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _startTyping();
    } else if (text.isEmpty && _isTyping) {
      _stopTyping();
    }
  }

  void _startTyping() {
    if (!_isTyping) {
      _isTyping = true;
      context.read<ChatProvider>().sendTypingIndicator(widget.room.id, true);
    }
    
    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _stopTyping();
    });
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      context.read<ChatProvider>().sendTypingIndicator(widget.room.id, false);
    }
    _typingTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white,
              backgroundImage: widget.room.imageUrl != null
                  ? NetworkImage(widget.room.imageUrl!)
                  : null,
              child: widget.room.imageUrl == null
                  ? Text(
                      widget.room.name?.isNotEmpty == true
                          ? widget.room.name![0].toUpperCase()
                          : '?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
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
                    widget.room.name ?? 'Direct Message',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      final typingIndicators = chatProvider.getTypingIndicatorsForRoom(widget.room.id);
                      if (typingIndicators.isNotEmpty) {
                        return Text(
                          '${typingIndicators.first.username} is typing...',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showRoomOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = chatProvider.messages
                    .where((m) => m.roomId == widget.room.id)
                    .toList();

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + 1, // +1 for typing indicator
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      // Show typing indicator
                      return TypingIndicatorWidget(roomId: widget.room.id);
                    }
                    
                    final message = messages[index];
                    final isCurrentUser = message.senderId == chatProvider.currentUserId;
                    
                    return ChatMessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      onReply: (replyToMessage) {
                        // Handle reply functionality
                        _messageController.text = '@${replyToMessage.senderName} ';
                        _messageController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _messageController.text.length),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          ChatInputWidget(
            controller: _messageController,
            onSend: _sendMessage,
            onTextChanged: _onTextChanged,
            onStopTyping: _stopTyping,
          ),
        ],
      ),
    );
  }

  void _showRoomOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Room Info'),
              onTap: () {
                Navigator.pop(context);
                _showRoomInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Participants'),
              onTap: () {
                Navigator.pop(context);
                _showParticipants();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement mute functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive Chat'),
              onTap: () {
                Navigator.pop(context);
                _archiveChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Chat', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.room.name ?? 'Direct Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.room.description != null) ...[
              const Text('Description:'),
              Text(widget.room.description!),
              const SizedBox(height: 16),
            ],
            Text('Created: ${_formatDate(widget.room.createdAt)}'),
            if (widget.room.lastMessageAt != null)
              Text('Last message: ${_formatDate(widget.room.lastMessageAt!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showParticipants() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Participants'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.room.participants.length,
            itemBuilder: (context, index) {
              final participant = widget.room.participants[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: participant.avatarUrl != null
                      ? NetworkImage(participant.avatarUrl!)
                      : null,
                  child: participant.avatarUrl == null
                      ? Text(participant.username[0].toUpperCase())
                      : null,
                ),
                title: Text(participant.displayName ?? participant.username),
                subtitle: Text(participant.role.name),
                trailing: participant.isOnline
                    ? const Icon(Icons.circle, color: Colors.green, size: 12)
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _archiveChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Chat'),
        content: const Text('Are you sure you want to archive this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement archive functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat archived')),
              );
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _deleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
              Navigator.pop(context); // Go back to chat list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}