import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitnation/models/CommunityContentModel.dart';
import 'package:fitnation/core/themes/themes.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  XFile? _pickedImage;
  String _contentType = 'text'; // 'text', 'image', 'workout'

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = image;
      _contentType = 'image';
    });
  }

  void _postStory() {
    if (_pickedImage == null && _textController.text.isEmpty) {
      // Show a snackbar or alert if no content
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content or an image.')),
      );
      return;
    }

    StoryContentItem newContent;
    if (_pickedImage != null) {
      // For demonstration, we'll use a dummy URL or base64.
      // In a real app, you'd upload the image and get a URL.
      newContent = StoryContentItem(
        type: 'image',
        content: _pickedImage!.path, // Using local path for now, will simulate upload later
      );
    } else {
      newContent = StoryContentItem(
        type: 'text',
        content: _textController.text,
      );
    }

    // In a real application, you would send this to a backend.
    // For this task, we'll pass it back to the previous screen or a provider.
    Navigator.of(context).pop(newContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Story',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.foreground),
        ),
        actions: [
          TextButton(
            onPressed: _postStory,
            child: Text(
              'Post',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _pickedImage != null
                    ? Image.file(File(_pickedImage!.path), fit: BoxFit.contain)
                    : TextField(
                        controller: _textController,
                        maxLines: null, // Allows for multiline input
                        expands: true,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.foreground),
                        decoration: const InputDecoration(
                          hintText: 'Type your story...',
                          hintStyle: TextStyle(color: AppColors.mutedForeground),
                          border: InputBorder.none,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: AppColors.primary, size: 30),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields, color: AppColors.primary, size: 30),
                  onPressed: () {
                    setState(() {
                      _pickedImage = null;
                      _contentType = 'text';
                    });
                  },
                ),
                // Add more options here for workout, location etc.
                // IconButton(
                //   icon: const Icon(Icons.fitness_center, color: AppColors.primary, size: 30),
                //   onPressed: () {
                //     setState(() {
                //       _contentType = 'workout';
                //     });
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
