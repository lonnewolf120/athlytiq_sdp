import 'package:flutter/material.dart';
// import 'package:fitnation/core/themes/colors.dart'; // No longer strictly needed if using ColorScheme

class ChatScreen extends StatefulWidget {
  final String friendName;

  const ChatScreen({super.key, required this.friendName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Dummy messages for each user
  final Map<String, List<Map<String, dynamic>>> _allChatMessages = {
    "John Doe": [
      {"text": "Hey John! How was your workout today?", "isMe": true},
      {"text": "Hey! It was great, smashed my leg day!", "isMe": false},
      {"text": "Nice! What exercises did you do?", "isMe": true},
      {
        "text": "Squats, deadlifts, lunges, and calf raises. Feeling it now!",
        "isMe": false,
      },
      {
        "text": "Sounds intense! I'm planning to hit the gym later.",
        "isMe": true,
      },
      {"text": "Awesome! Let me know if you need a spot.", "isMe": false},
      {
        "text": "Will do! Thinking about trying a new protein shake recipe.",
        "isMe": true,
      },
      {
        "text": "Oh, tell me about it! Always looking for new ideas.",
        "isMe": false,
      },
      {
        "text": "It's a chocolate-banana-peanut butter blend. Super tasty!",
        "isMe": true,
      },
      {"text": "Sounds delicious! Might try that myself. 💪", "isMe": false},
    ],
    "Jane Smith": [
      {"text": "Hi Jane, just confirming our meeting for 2 PM?", "isMe": true},
      {"text": "Yes, that's correct! Looking forward to it.", "isMe": false},
      {"text": "Great! I'll prepare the latest progress report.", "isMe": true},
      {"text": "Perfect. See you then!", "isMe": false},
      {"text": "See you!", "isMe": true},
    ],
    "Fitness Coach Alex": [
      {"text": "Hi Alex, just checking in about my new plan.", "isMe": true},
      {
        "text":
            "Hey! Your new personalized workout plan has just been uploaded to your profile.",
        "isMe": false,
      },
      {"text": "Awesome, thanks! I'll check it out.", "isMe": true},
      {
        "text":
            "Let me know if you have any questions or need adjustments after trying it.",
        "isMe": false,
      },
      {"text": "Will do! Thanks for the quick turnaround.", "isMe": true},
    ],
    "Gym Buddy Sarah": [
      {"text": "Hey Sarah! Leg day tomorrow at 6 AM?", "isMe": true},
      {"text": "Definitely! I'm in. Let's push hard!", "isMe": false},
      {"text": "Perfect! See you at the usual spot.", "isMe": true},
      {"text": "Alright! Get some rest. Zzzz", "isMe": false},
    ],
    "Nutri Chef Mike": [
      {
        "text": "Hi Mike, I was wondering if you had any new low-carb recipes?",
        "isMe": true,
      },
      {
        "text":
            "Hello! Yes, I just sent over a new batch of delicious low-carb meal ideas to your email.",
        "isMe": false,
      },
      {
        "text": "Oh, fantastic! Thanks so much, I'm always looking for those.",
        "isMe": true,
      },
      {
        "text": "You're welcome! Let me know which one you try first.",
        "isMe": false,
      },
      {"text": "Will do!", "isMe": true},
    ],
    "Support Team": [
      {"text": "Hi, I have a question about my subscription.", "isMe": true},
      {
        "text":
            "Hello! Thanks for reaching out. Please describe your issue, and we'll be happy to assist.",
        "isMe": false,
      },
      {
        "text": "My premium subscription isn't showing up as active.",
        "isMe": true,
      },
      {
        "text":
            "Thank you for the information. We've checked your account, and it seems the issue has been resolved. Please restart your app.",
        "isMe": false,
      },
      {"text": "It worked! Thanks a lot for the quick support!", "isMe": true},
      {
        "text":
            "You're most welcome! Is there anything else we can help you with?",
        "isMe": false,
      },
    ],
  };

  late List<Map<String, dynamic>> _messages; // Messages for the current chat
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages specific to the friendName, or an empty list if not found
    _messages = List.from(_allChatMessages[widget.friendName] ?? []);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: false); // Scroll to bottom immediately on load
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": text.trim(), "isMe": true});
      // Optionally add a dummy response from the friend after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add({
              "text": "Got it! Thanks for your message.",
              "isMe": false,
            });
          });
          _scrollToBottom();
        }
      });
    });
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // MD3 background
      appBar: AppBar(
        backgroundColor: colorScheme.surface, // MD3 surface color for AppBar
        title: Text(
          widget.friendName,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
          ), // Rounded icon
          onPressed: () => Navigator.pop(context),
        ),
        surfaceTintColor: Colors.transparent, // Prevents unwanted tint
        elevation: 1, // Slight shadow for depth
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["isMe"] as bool;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ), // Adjust padding
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ), // Add horizontal margin
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width *
                          0.75, // Max width for bubbles
                    ),
                    decoration: BoxDecoration(
                      color:
                          isMe
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHigh, // MD3 colors
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(
                          isMe ? 16 : 4,
                        ), // Tapered corner
                        bottomRight: Radius.circular(
                          isMe ? 4 : 16,
                        ), // Tapered corner
                      ),
                    ),
                    child: Text(
                      msg["text"] as String,
                      style: textTheme.bodyLarge?.copyWith(
                        // MD3 bodyLarge
                        color:
                            isMe
                                ? colorScheme.onPrimary
                                : colorScheme
                                    .onSurface, // Text color for contrast
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ), // Increased vertical padding
              color: colorScheme.surface, // MD3 surface color for input area
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons
                          .add_circle_outline_rounded, // Plus icon for attachments
                      color: colorScheme.onSurfaceVariant, // MD3 icon color
                    ),
                    onPressed: () {
                      // Implement attachment options (gallery, camera, etc.)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Attachment features coming soon!',
                            style: TextStyle(color: colorScheme.onSecondary),
                          ),
                          backgroundColor: colorScheme.secondary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor:
                            colorScheme
                                .surfaceContainerHighest, // A distinct fill color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            24,
                          ), // Rounded input field
                          borderSide: BorderSide.none, // No border line
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8), // Spacing before send button
                  FloatingActionButton.small(
                    // Use small FAB for send button
                    onPressed: () => _sendMessage(_controller.text),
                    backgroundColor: colorScheme.primary, // MD3 primary color
                    foregroundColor:
                        colorScheme.onPrimary, // Text/icon color on primary
                    elevation: 2, // Small elevation
                    child: const Icon(Icons.send_rounded), // Rounded send icon
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
