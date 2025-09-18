import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/colors.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_models.dart';

class IndividualChatScreen extends ConsumerStatefulWidget {
  final ChatRoom chatRoom;

  const IndividualChatScreen({super.key, required this.chatRoom});

  @override
  ConsumerState<IndividualChatScreen> createState() =>
      _IndividualChatScreenState();
}

class _IndividualChatScreenState extends ConsumerState<IndividualChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatMessagesProvider(widget.chatRoom.id).notifier).refresh();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _scrollToBottom();

    // Send message
    final success = await ref
        .read(chatMessagesProvider(widget.chatRoom.id).notifier)
        .sendMessage(text);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
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

  String get _chatTitle {
    return widget.chatRoom.name ?? 'Chat';
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.chatRoom.id));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _chatTitle,
              style: const TextStyle(
                color: AppColors.darkPrimaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.chatRoom.type == ChatRoomType.direct)
              Text(
                'Online', // TODO: Implement real online status
                style: TextStyle(
                  color: AppColors.darkSecondaryText,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.darkPrimaryText),
            onPressed: () {
              // TODO: Show chat options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList(messages)),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet\nSay hello! 👋',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.darkSecondaryText, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe =
        message.senderId == 'current_user'; // TODO: Get real current user ID
    final isOptimistic = message.id.startsWith('temp_');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              backgroundImage:
                  message.senderAvatar != null
                      ? NetworkImage(message.senderAvatar!)
                      : null,
              child:
                  message.senderAvatar == null
                      ? Text(
                        message.senderDisplayName?.isNotEmpty == true
                            ? message.senderDisplayName![0].toUpperCase()
                            : message.senderName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.secondary : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft:
                      isMe
                          ? const Radius.circular(20)
                          : const Radius.circular(5),
                  bottomRight:
                      isMe
                          ? const Radius.circular(5)
                          : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && widget.chatRoom.type == ChatRoomType.group)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderDisplayName ?? message.senderName,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    message.content ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.darkPrimaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.createdAt),
                        style: TextStyle(
                          color:
                              isMe
                                  ? Colors.white.withOpacity(0.7)
                                  : AppColors.darkSecondaryText,
                          fontSize: 12,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isOptimistic ? Icons.access_time : Icons.done_all,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isSending = ref.watch(sendingMessageProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.darkPrimaryText.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !isSending,
              style: const TextStyle(color: AppColors.darkPrimaryText),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: AppColors.darkSecondaryText),
                filled: true,
                fillColor: AppColors.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: isSending ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  isSending ? Icons.hourglass_empty : Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }
}
