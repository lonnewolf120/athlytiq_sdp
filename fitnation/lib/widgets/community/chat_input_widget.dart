import 'package:flutter/material.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/text_styles.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(String) onTextChanged;
  final VoidCallback onStopTyping;

  const ChatInputWidget({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onTextChanged,
    required this.onStopTyping,
  }) : super(key: key);

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onTextChanged(widget.controller.text);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      widget.onStopTyping();
    }
  }

  void _sendMessage() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onSend();
      widget.onStopTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.darkSecondaryText.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      onPressed: () {
                        // TODO: Implement emoji picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Emoji picker coming soon!'),
                          ),
                        );
                      },
                      color: AppColors.darkSecondaryText,
                    ),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: AppTextStyles.darkBodyMedium,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        _showAttachmentOptions();
                      },
                      color: AppColors.darkSecondaryText,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed:
                    widget.controller.text.trim().isNotEmpty
                        ? _sendMessage
                        : null,
                color: AppColors.primaryForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkSecondaryText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _openCamera();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _openGallery();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.videocam,
                      label: 'Video',
                      onTap: () {
                        Navigator.pop(context);
                        _openVideoCamera();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.audiotrack,
                      label: 'Audio',
                      onTap: () {
                        Navigator.pop(context);
                        _recordAudio();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.location_on,
                      label: 'Location',
                      onTap: () {
                        Navigator.pop(context);
                        _shareLocation();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.contact_page,
                      label: 'Contact',
                      onTap: () {
                        Navigator.pop(context);
                        _shareContact();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.darkBodySmall),
        ],
      ),
    );
  }

  void _openCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera functionality coming soon!')),
    );
  }

  void _openGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery functionality coming soon!')),
    );
  }

  void _openVideoCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video camera functionality coming soon!')),
    );
  }

  void _recordAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio recording functionality coming soon!'),
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location sharing functionality coming soon!'),
      ),
    );
  }

  void _shareContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact sharing functionality coming soon!'),
      ),
    );
  }
}
