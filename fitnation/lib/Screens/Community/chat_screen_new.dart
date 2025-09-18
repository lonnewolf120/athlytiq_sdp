// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fitnation/core/themes/colors.dart';
// import 'package:fitnation/providers/chat_provider.dart';
// import 'package:fitnation/providers/auth_provider.dart';
// import 'package:fitnation/models/chat_models.dart';

// class ChatScreen extends ConsumerStatefulWidget {
//   final ChatRoom chatRoom;
//   final String? friendName; // For backward compatibility

//   const ChatScreen({
//     super.key, 
//     required this.chatRoom,
//     this.friendName,
//   });

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     // Load messages when screen opens
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(chatMessagesProvider(widget.chatRoom.id).notifier).loadMessages();
//       // Mark messages as read
//       ref.read(chatMessagesProvider(widget.chatRoom.id).notifier).markAsRead();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     // Get current user info for optimistic update
//     final authState = ref.read(authProvider);
//     String? currentUserId;
//     String? currentUsername;
    
//     if (authState is Authenticated) {
//       currentUserId = authState.user.id;
//       currentUsername = authState.user.username;
//     }

//     if (currentUserId != null && currentUsername != null) {
//       // Add optimistic message
//       ref.read(chatMessagesProvider(widget.chatRoom.id).notifier)
//           .addOptimisticMessage(text, currentUserId, currentUsername);
//     }

//     _controller.clear();
//     _scrollToBottom();

//     // Send message to server
//     final success = await ref
//         .read(chatMessagesProvider(widget.chatRoom.id).notifier)
//         .sendMessage(text);

//     if (!success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Failed to send message"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       // Refresh to remove optimistic message
//       ref.read(chatMessagesProvider(widget.chatRoom.id).notifier).refresh();
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent + 60,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   String get _chatTitle {
//     if (widget.chatRoom.type == 'direct') {
//       // For direct chats, show the other participant's name
//       final authState = ref.read(authProvider);
//       String? currentUserId;
      
//       if (authState is Authenticated) {
//         currentUserId = authState.user.id;
//       }

//       if (currentUserId != null) {
//         final otherParticipant = widget.chatRoom.participants
//             .firstWhere((p) => p.userId != currentUserId, orElse: () => widget.chatRoom.participants.first);
//         return otherParticipant.displayName;
//       }
//     }
//     return widget.chatRoom.name;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final messagesAsync = ref.watch(chatMessagesProvider(widget.chatRoom.id));
    
//     return Scaffold(
//       backgroundColor: AppColors.darkBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.darkBackground,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _chatTitle,
//               style: const TextStyle(
//                 color: AppColors.darkPrimaryText,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (widget.chatRoom.type == 'group')
//               Text(
//                 "${widget.chatRoom.participants.length} members",
//                 style: const TextStyle(
//                   color: AppColors.darkHintText,
//                   fontSize: 12,
//                 ),
//               ),
//           ],
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.darkPrimaryText),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           if (widget.chatRoom.type == 'group')
//             IconButton(
//               icon: const Icon(Icons.info, color: AppColors.darkPrimaryText),
//               onPressed: () {
//                 // TODO: Show group info
//               },
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Messages list
//           Expanded(
//             child: _buildMessagesList(messagesAsync),
//           ),
//           // Message input
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessagesList(AsyncValue<List<ChatMessage>> messagesAsync) {
//     return messagesAsync.when(
//       data: (messages) {
//         if (messages.isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.chat_bubble_outline,
//                   size: 64,
//                   color: AppColors.darkHintText,
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   "No messages yet",
//                   style: TextStyle(
//                     color: AppColors.darkHintText,
//                     fontSize: 16,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "Start the conversation!",
//                   style: TextStyle(
//                     color: AppColors.darkHintText,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Auto-scroll to bottom when new messages arrive
//         WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

//         return RefreshIndicator(
//           onRefresh: () async {
//             ref.read(chatMessagesProvider(widget.chatRoom.id).notifier).refresh();
//           },
//           child: ListView.builder(
//             controller: _scrollController,
//             padding: const EdgeInsets.all(16),
//             itemCount: messages.length,
//             itemBuilder: (context, index) {
//               final message = messages[index];
//               return _buildMessageBubble(message);
//             },
//           ),
//         );
//       },
//       loading: () => const Center(
//         child: CircularProgressIndicator(color: AppColors.secondary),
//       ),
//       error: (error, stack) => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "Error loading messages: $error",
//               style: const TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 ref.read(chatMessagesProvider(widget.chatRoom.id).notifier).refresh();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.secondary,
//               ),
//               child: const Text("Retry"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message) {
//     final authState = ref.read(authProvider);
//     String? currentUserId;
    
//     if (authState is Authenticated) {
//       currentUserId = authState.user.id;
//     }
    
//     final isMe = message.senderId == currentUserId;
//     final isOptimistic = message.id.startsWith('temp_');

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isMe) ...[
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: AppColors.secondary,
//               backgroundImage: message.senderProfileImageUrl != null 
//                   ? NetworkImage(message.senderProfileImageUrl!)
//                   : null,
//               child: message.senderProfileImageUrl == null
//                   ? Text(
//                       message.senderDisplayName.isNotEmpty 
//                           ? message.senderDisplayName[0].toUpperCase()
//                           : 'U',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Column(
//               crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 if (!isMe && widget.chatRoom.type == 'group')
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 4),
//                     child: Text(
//                       message.senderDisplayName,
//                       style: const TextStyle(
//                         color: AppColors.secondary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: isMe ? AppColors.secondary : AppColors.darkSurface,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         message.content,
//                         style: TextStyle(
//                           color: isMe ? Colors.white : AppColors.darkPrimaryText,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             _formatMessageTime(message.createdAt),
//                             style: TextStyle(
//                               color: isMe 
//                                   ? Colors.white70 
//                                   : AppColors.darkHintText,
//                               fontSize: 10,
//                             ),
//                           ),
//                           if (isMe) ...[
//                             const SizedBox(width: 4),
//                             Icon(
//                               isOptimistic 
//                                   ? Icons.schedule 
//                                   : (message.isRead ? Icons.done_all : Icons.done),
//                               size: 12,
//                               color: isOptimistic 
//                                   ? Colors.white54
//                                   : (message.isRead ? Colors.blue : Colors.white70),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isMe) ...[
//             const SizedBox(width: 8),
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: AppColors.secondary,
//               child: const Icon(
//                 Icons.person,
//                 size: 16,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     final isSending = ref.watch(sendingMessageProvider);

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: AppColors.darkSurface,
//         border: Border(
//           top: BorderSide(color: AppColors.darkInputBorder),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               style: const TextStyle(color: AppColors.darkPrimaryText),
//               decoration: InputDecoration(
//                 hintText: "Type a message...",
//                 hintStyle: const TextStyle(color: AppColors.darkHintText),
//                 filled: true,
//                 fillColor: AppColors.darkBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//               ),
//               maxLines: null,
//               textCapitalization: TextCapitalization.sentences,
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             decoration: const BoxDecoration(
//               color: AppColors.secondary,
//               shape: BoxShape.circle,
//             ),
//             child: IconButton(
//               onPressed: isSending ? null : _sendMessage,
//               icon: isSending 
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Icon(
//                       Icons.send,
//                       color: Colors.white,
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatMessageTime(DateTime time) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final messageDate = DateTime(time.year, time.month, time.day);

//     if (messageDate == today) {
//       return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
//     } else {
//       return "${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
//     }
//   }
// }
