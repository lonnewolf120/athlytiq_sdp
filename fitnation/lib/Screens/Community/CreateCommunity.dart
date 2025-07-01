import 'dart:io';
import 'package:fitnation/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryInputController = TextEditingController();

  List<String> _categories = [];
  File? _coverImage;
  File? _profileImage;
  bool _isPrivate = false;
  bool _isCreating = false;

  Future<void> _pickImage(Function(File) onImageSelected, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }

  void _addCategory() {
    if (_categoryInputController.text.isNotEmpty && !_categories.contains(_categoryInputController.text.trim())) {
      setState(() {
        _categories.add(_categoryInputController.text.trim());
        _categoryInputController.clear();
      });
    }
  }

  void _removeCategory(String category) {
    setState(() {
      _categories.remove(category);
    });
  }

  Future<void> _submitCreateCommunity() async {
    if (_formKey.currentState!.validate() && !_isCreating) {
      if (_profileImage == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a profile image for the community.'), backgroundColor: Colors.orangeAccent),
        );
        return;
      }
      setState(() { _isCreating = true; });

      // TODO: Implement actual community creation logic
      // Upload images, then create community record in Supabase
      print('Name: ${_nameController.text}');
      print('Description: ${_descriptionController.text}');
      print('Categories: $_categories');
      print('Is Private: $_isPrivate');
      print('Cover Image: ${_coverImage?.path}');
      print('Profile Image: ${_profileImage?.path}');

      await Future.delayed(const Duration(seconds: 2)); // Simulate network request
      
      setState(() { _isCreating = false; });
      if(mounted) Navigator.pop(context, true); // Pop and indicate success
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    bool canCreate = _nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _profileImage != null && !_isCreating;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _isCreating ? null : () => Navigator.pop(context)),
        title: Text('Create Community', style: textTheme.titleLarge),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Community Images', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Profile Image Upload
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickImage((file) => setState(() => _profileImage = file), ImageSource.gallery),
                      child: AspectRatio(
                        aspectRatio: 1, // Square
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.mutedBackground,
                            borderRadius: BorderRadius.circular(12),
                            image: _profileImage != null
                                ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                                : null,
                            border: Border.all(color: AppColors.inputBorderColor)
                          ),
                          child: _profileImage == null
                              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_a_photo_outlined, size: 30), SizedBox(height: 4), Text('Profile Image*')]))
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Cover Image Upload
                  Expanded(
                    flex: 2, // Wider for cover
                    child: GestureDetector(
                      onTap: () => _pickImage((file) => setState(() => _coverImage = file), ImageSource.gallery),
                      child: AspectRatio(
                        aspectRatio: 16/9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.mutedBackground,
                            borderRadius: BorderRadius.circular(12),
                             image: _coverImage != null
                                ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
                                : null,
                            border: Border.all(color: AppColors.inputBorderColor)
                          ),
                          child: _coverImage == null
                              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_photo_alternate_outlined, size: 30), SizedBox(height: 4),Text('Cover Image (Optional)')]))
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_profileImage == null) Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('  * Profile image is required', style: textTheme.labelSmall?.copyWith(color: AppColors.primary.withOpacity(0.8))),
              ),

              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Community Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Name cannot be empty' : null,
                onChanged: (_) => setState((){}), // for button state update
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                maxLines: 3,
                minLines: 2,
                validator: (value) => (value == null || value.isEmpty) ? 'Description cannot be empty' : null,
                onChanged: (_) => setState((){}), // for button state update
              ),
              const SizedBox(height: 24),
              Text('Categories', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryInputController,
                      decoration: const InputDecoration(hintText: 'e.g., Fitness, Running'),
                      onFieldSubmitted: (_) => _addCategory(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    onPressed: _addCategory,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _categories.map((category) => Chip(
                  label: Text(category),
                  onDeleted: () => _removeCategory(category),
                  deleteIconColor: AppColors.mutedForeground.withOpacity(0.7),
                )).toList(),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text('Private Community', style: textTheme.bodyLarge?.copyWith(color: AppColors.foreground)),
                subtitle: Text('Only members can see who\'s in the group and what they post.', style: textTheme.bodyMedium),
                value: _isPrivate,
                onChanged: (bool value) => setState(() => _isPrivate = value),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canCreate ? _submitCreateCommunity : null,
                  child: _isCreating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create Community'),
                ),
              ),
              const SizedBox(height: 16),
               SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isCreating ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}