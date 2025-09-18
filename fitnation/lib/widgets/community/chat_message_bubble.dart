import 'package:flutter/material.dart';
import '../../models/chat_models.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/text_styles.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final Function(ChatMessage)? onReply;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.onReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              backgroundImage:
                  message.senderAvatar != null
                      ? NetworkImage(message.senderAvatar!)
                      : null,
              child:
                  message.senderAvatar == null
                      ? Text(
                        message.senderName.isNotEmpty
                            ? message.senderName[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.darkBodySmall.copyWith(
                          color: AppColors.primaryForeground,
                          fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isCurrentUser ? AppColors.primary : AppColors.darkSurface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message.senderDisplayName ?? message.senderName,
                      style: AppTextStyles.darkBodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  if (message.replyToMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color:
                            isCurrentUser
                                ? AppColors.primaryForeground.withOpacity(0.12)
                                : AppColors.darkSecondaryText.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color:
                                isCurrentUser
                                    ? AppColors.primaryForeground
                                    : AppColors.primary,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.replyToMessage!.senderDisplayName ??
                                message.replyToMessage!.senderName,
                            style: AppTextStyles.darkBodySmall.copyWith(
                              color:
                                  isCurrentUser
                                      ? AppColors.primaryForeground
                                      : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message.replyToMessage!.content ?? '',
                            style: AppTextStyles.darkBodySmall.copyWith(
                              color:
                                  isCurrentUser
                                      ? AppColors.primaryForeground.withOpacity(
                                        0.8,
                                      )
                                      : AppColors.darkSecondaryText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (message.content != null)
                    Text(
                      message.content!,
                      style: AppTextStyles.darkBodyMedium.copyWith(
                        color:
                            isCurrentUser
                                ? AppColors.primaryForeground
                                : AppColors.darkPrimaryText,
                      ),
                    ),

                  if (message.mediaUrls.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...message.mediaUrls.map((url) => _buildMediaWidget(url)),
                  ],

                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: AppTextStyles.darkBodySmall.copyWith(
                          color:
                              isCurrentUser
                                  ? AppColors.primaryForeground.withOpacity(0.7)
                                  : AppColors.darkSecondaryText,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isReadByCurrentUser
                              ? Icons.done_all
                              : Icons.done,
                          size: 16,
                          color:
                              message.isReadByCurrentUser
                                  ? AppColors.primaryForeground
                                  : AppColors.primaryForeground.withOpacity(
                                    0.7,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.darkSecondaryText,
              backgroundImage:
                  message.senderAvatar != null
                      ? NetworkImage(message.senderAvatar!)
                      : null,
              child:
                  message.senderAvatar == null
                      ? Text(
                        message.senderName.isNotEmpty
                            ? message.senderName[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.darkBodySmall.copyWith(
                          color: AppColors.primaryForeground,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaWidget(String url) {
    if (url.toLowerCase().contains(RegExp(r'\.(jpg|jpeg|png|gif|webp)$'))) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                color: AppColors.darkSecondaryText.withOpacity(0.3),
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkSecondaryText.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.attach_file),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                url.split('/').last,
                style: AppTextStyles.darkBodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
