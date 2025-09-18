import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
// models are accessed through ChatProvider; no direct model import required here
import '../../core/themes/colors.dart';
import '../../core/themes/text_styles.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final String roomId;

  const TypingIndicatorWidget({Key? key, required this.roomId})
    : super(key: key);

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final typingIndicators = chatProvider.getTypingIndicatorsForRoom(
          widget.roomId,
        );

        if (typingIndicators.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.darkSecondaryText.withOpacity(0.3),
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.darkSecondaryText,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      typingIndicators.length == 1
                          ? '${typingIndicators.first.username} is typing'
                          : '${typingIndicators.length} people are typing',
                      style: AppTextStyles.darkBodySmall.copyWith(
                        color: AppColors.darkSecondaryText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.darkSecondaryText
                                      .withOpacity(
                                        0.3 + (_animation.value * 0.7),
                                      ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
