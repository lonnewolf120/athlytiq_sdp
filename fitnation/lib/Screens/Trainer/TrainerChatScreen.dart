import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fitnation/providers/trainer_provider.dart';
import 'package:fitnation/models/trainer/trainer_chat.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

class TrainerChatScreen extends ConsumerStatefulWidget {
  final String chatRoomId;
  final String trainerId;
  final String userId;

  const TrainerChatScreen({
    super.key,
    required this.chatRoomId,
    required this.trainerId,
    required this.userId,
  });

  @override
  ConsumerState<TrainerChatScreen> createState() => _TrainerChatScreenState();
}

class _TrainerChatScreenState extends ConsumerState<TrainerChatScreen> {
  final List<types.Message> _messages = [];
  final _uuid = const Uuid();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final messages = await ref
          .read(trainerProvider.notifier)
          .getChatMessages(widget.chatRoomId);

      setState(() {
        _messages.clear();
        _messages.addAll(messages.map((TrainerChat msg) => types.TextMessage(
              author: types.User(
                id: msg.senderId,
                firstName: msg.senderId == widget.userId ? 'You' : 'Trainer',
              ),
              id: msg.id,
              text: msg.message,
              createdAt: msg.createdAt.millisecondsSinceEpoch,
            )));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: types.User(id: widget.userId),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    try {
      await ref.read(trainerProvider.notifier).sendMessage(
            TrainerChat(
              id: textMessage.id,
              senderId: widget.userId,
              receiverId: widget.trainerId,
              message: message.text,
              createdAt: DateTime.now(),
            ),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.white),
                title: const Text('Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.white),
                title: const Text('File', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      // Handle file upload
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      // Handle image upload
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      // Handle file message tap
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Chat with Trainer',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show trainer profile or chat info
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Chat(
              theme: DefaultChatTheme(
                backgroundColor: Colors.black,
                primaryColor: Colors.red,
                secondaryColor: Colors.grey[900]!,
                inputBackgroundColor: Colors.grey[900]!,
                inputTextColor: Colors.white,
                messageBorderRadius: 12,
                inputBorderRadius: BorderRadius.circular(24),
                sentMessageBodyTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                receivedMessageBodyTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              messages: _messages,
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: types.User(id: widget.userId),
              showUserAvatars: true,
              showUserNames: true,
            ),
    );
  }
}
