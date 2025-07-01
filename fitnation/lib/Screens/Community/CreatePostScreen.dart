import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:fitnation/models/Exercise.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // For date formatting

// Import new models for creating data
import 'package:fitnation/models/PostModel.dart';
import 'package:fitnation/models/WorkoutPostModel.dart';
import 'package:fitnation/models/ChallengePostModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:fitnation/providers/data_providers.dart'; // Import data_providers
import 'package:fitnation/providers/auth_provider.dart'
    as auth; // Import auth_provider with prefix
import 'package:fitnation/Screens/Auth/Login.dart'; // Import LoginScreen
import 'package:fitnation/models/User.dart'; // Import User model
import 'package:fitnation/api/API_Services.dart'; // Import ApiService

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? communityId; // Optional: if posting to a specific community
  const CreatePostScreen({super.key, this.communityId});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen>
    with TickerProviderStateMixin<CreatePostScreen> {
  late TabController _tabController;
  bool _isSubmittingAnyTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initial authentication check
    final authState = ref.read(auth.authProvider); // Use auth.authProvider
    if (authState is! auth.Authenticated) {
      // Use auth.Authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateSubmittingState(bool isSubmitting) {
    setState(() {
      _isSubmittingAnyTab = isSubmitting;
    });
  }

  Future<void> _handleSubmit({
    String? content,
    File? mediaFile,
    WorkoutPostData? workoutData,
    ChallengePostData? challengeData,
    PostType? postType,
  }) async {
    if (_isSubmittingAnyTab) return;

    if (postType == null) {
      if (workoutData != null) {
        postType = PostType.workout;
      } else if (challengeData != null) {
        postType = PostType.challenge;
      } else {
        postType = PostType.text;
      }
    }

    String? mediaUrl;
    if (mediaFile != null) {
      mediaUrl = mediaFile.path;
    }

    final newPost = Post(
      id: '',
      userId: '',
      content: content,
      mediaUrl: mediaUrl,
      postType: [postType],
      workoutData: workoutData,
      challengeData: challengeData,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('Attempting to create post of type: ${postType.name}');
    print('Community ID: ${widget.communityId}');

    // Get ApiService instance
    final apiService = ref.read(apiServiceProvider);

    try {
      // Upload media file if it exists
      if (mediaFile != null) {
        mediaUrl = await apiService.uploadFile(mediaFile);
      }

      // Create the post using the ApiService
      await apiService.createPost(newPost);

      print("Post submitted successfully!");
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error creating post: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Watch the currentUserProvider to get the current user and profile image
    final currentUser = ref.watch(
      auth.currentUserProvider,
    ); // Use auth.currentUserProvider
    final profileImageUrl =
        currentUser?.avatarUrl ??
        'https://randomuser.me/api/portraits/men/5.jpg';

    // If currentUser is null, it means they are not authenticated.
    // The initial check in initState should handle redirection,
    // but this provides a fallback for the build method.
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmittingAnyTab ? null : () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Text('Create New Post', style: textTheme.titleLarge),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Post'),
            Tab(text: 'Workout'),
            Tab(text: 'Challenge'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CreatePostTab(
            onSubmit: _handleSubmit,
            isSubmitting: _isSubmittingAnyTab,
            onSubmittingStateChange: _updateSubmittingState,
            userProfileImageUrl: profileImageUrl,
          ),
          CreateWorkoutTab(
            onSubmit: _handleSubmit,
            isSubmitting: _isSubmittingAnyTab,
            onSubmittingStateChange: _updateSubmittingState,
            userProfileImageUrl: profileImageUrl,
          ),
          CreateChallengeTab(
            onSubmit: _handleSubmit,
            isSubmitting: _isSubmittingAnyTab,
            onSubmittingStateChange: _updateSubmittingState,
            userProfileImageUrl: profileImageUrl,
          ),
        ],
      ),
    );
  }
}

// --- Individual Tab Widgets ---

class CreatePostTab extends StatefulWidget {
  final Function({String? content, File? mediaFile, PostType? postType})
  onSubmit;
  final bool isSubmitting;
  final ValueChanged<bool> onSubmittingStateChange;
  final String userProfileImageUrl; // New parameter

  const CreatePostTab({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
    required this.onSubmittingStateChange,
    required this.userProfileImageUrl, // Initialize new parameter
  });

  @override
  State<CreatePostTab> createState() => _CreatePostTabState();
}

class _CreatePostTabState extends State<CreatePostTab> {
  final _contentController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _submit() async {
    if (widget.isSubmitting) return;
    if (_contentController.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add content or an image.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    widget.onSubmittingStateChange(true);
    try {
      await widget.onSubmit(
        content: _contentController.text.trim(),
        mediaFile: _selectedImage,
        postType: PostType.text,
      );
    } finally {
      widget.onSubmittingStateChange(false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool canSubmit =
        (_contentController.text.isNotEmpty || _selectedImage != null) &&
        !widget.isSubmitting;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                  widget.userProfileImageUrl, // Use dynamic URL
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Posting as You',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.mutedBackground),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.mutedBackground),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: null,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: _removeImage,
                          tooltip: 'Remove image',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: widget.isSubmitting ? null : _pickImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mutedForeground,
                  side: BorderSide(color: AppColors.mutedBackground),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    widget.isSubmitting
                        ? null
                        : () {
                          /* TODO: Add location */
                        },
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Add Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mutedForeground,
                  side: BorderSide(color: AppColors.mutedBackground),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              child:
                  widget.isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateWorkoutTab extends StatefulWidget {
  final Function({WorkoutPostData? workoutData, PostType? postType}) onSubmit;
  final bool isSubmitting;
  final ValueChanged<bool> onSubmittingStateChange;
  final String userProfileImageUrl; // New parameter

  const CreateWorkoutTab({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
    required this.onSubmittingStateChange,
    required this.userProfileImageUrl, // Initialize new parameter
  });

  @override
  State<CreateWorkoutTab> createState() => _CreateWorkoutTabState();
}

class _CreateWorkoutTabState extends State<CreateWorkoutTab> {
  final _workoutTypeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();

  List<Exercise> _exercises = [];

  void _addExercise() {
    setState(() {
      _exercises.add(Exercise(
        exerciseId: '',
        name: '',
        bodyParts: [],
        equipments: [],
        targetMuscles: [],
        secondaryMuscles: [],
        instructions: [],
        gifUrl: '',
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _updateExercise(
    int index, {
    String? name,
    String? sets,
    String? reps,
    String? weight,
  }) {
    setState(() {
      final current = _exercises[index];
      _exercises[index] = Exercise(
        exerciseId: current.exerciseId,
        name: name ?? current.name,
        bodyParts: current.bodyParts,
        equipments: current.equipments,
        targetMuscles: current.targetMuscles,
        secondaryMuscles: current.secondaryMuscles,
        instructions: current.instructions,
        gifUrl: current.gifUrl,
      );
      _exercises[index].sets = sets ?? current.sets;
      _exercises[index].reps = reps ?? current.reps;
      _exercises[index].weight = weight ?? current.weight;
    });
  }

  bool _canSubmit() {
    if (_workoutTypeController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty ||
        _caloriesController.text.trim().isEmpty) {
      return false;
    }
    if (_exercises.isEmpty) return false;
    for (var exercise in _exercises) {
      if (exercise.name.trim().isEmpty) return false;
    }
    return true;
  }

  void _submit() async {
    if (widget.isSubmitting || !_canSubmit()) return;

    final workoutData = WorkoutPostData(
      workoutType: _workoutTypeController.text.trim(),
      durationMinutes: int.tryParse(_durationController.text.trim()) ?? 0,
      caloriesBurned: int.tryParse(_caloriesController.text.trim()) ?? 0,
      exercises: _exercises,
      notes:
          _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
    );

    widget.onSubmittingStateChange(true);
    try {
      await widget.onSubmit(
        workoutData: workoutData,
        postType: PostType.workout,
      );
    } finally {
      widget.onSubmittingStateChange(false);
    }
  }

  @override
  void dispose() {
    _workoutTypeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                  widget.userProfileImageUrl, // Use dynamic URL
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Posting as You',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _workoutTypeController,
            decoration: const InputDecoration(
              labelText: 'Workout Type',
              hintText: 'e.g., Strength Training, HIIT, Yoga',
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    suffixText: 'min',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    suffixText: 'cal',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercises',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: widget.isSubmitting ? null : _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ..._exercises.asMap().entries.map((entry) {
            int index = entry.key;
            Exercise exercise = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (index > 0) const Divider(),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: exercise.name,
                          decoration: const InputDecoration(
                            labelText: 'Exercise name',
                            hintText: 'e.g., Bench Press',
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged:
                              (value) => _updateExercise(index, name: value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed:
                            widget.isSubmitting
                                ? null
                                : () => _removeExercise(index),
                        tooltip: 'Remove exercise',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: exercise.sets,
                          decoration: const InputDecoration(
                            labelText: 'Sets',
                            hintText: '3',
                          ),
                          keyboardType:
                              TextInputType.text,
                          onChanged:
                              (value) => _updateExercise(index, sets: value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: exercise.reps,
                          decoration: const InputDecoration(
                            labelText: 'Reps',
                            hintText: '10',
                          ),
                          keyboardType:
                              TextInputType.text,
                          onChanged:
                              (value) => _updateExercise(index, reps: value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: exercise.weight,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            hintText: '135 lbs',
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onChanged:
                              (value) => _updateExercise(index, weight: value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 24),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Share your thoughts',
              hintText: 'How did your workout feel? Share your thoughts...',
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            minLines: 2,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submit : null,
              child:
                  widget.isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Share Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateChallengeTab extends StatefulWidget {
  final Function({
    ChallengePostData? challengeData,
    PostType? postType,
    File? mediaFile,
  })
  onSubmit;
  final bool isSubmitting;
  final ValueChanged<bool> onSubmittingStateChange;
  final String userProfileImageUrl; // New parameter

  const CreateChallengeTab({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
    required this.onSubmittingStateChange,
    required this.userProfileImageUrl, // Initialize new parameter
  });

  @override
  State<CreateChallengeTab> createState() => _CreateChallengeTabState();
}

class _CreateChallengeTabState extends State<CreateChallengeTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime? _startDate;
  File? _coverImage;

  bool _canSubmit() {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _durationController.text.trim().isNotEmpty &&
        _startDate != null;
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.primaryForeground,
              onSurface: AppColors.foreground,
              surface: AppColors.cardBackground,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submit() async {
    if (widget.isSubmitting || !_canSubmit()) return;

    final challengeData = ChallengePostData(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _startDate!,
      durationDays: int.tryParse(_durationController.text.trim()) ?? 0,
      coverImageUrl: null,
    );

    widget.onSubmittingStateChange(true);
    try {
      await widget.onSubmit(
        challengeData: challengeData,
        mediaFile: _coverImage,
        postType: PostType.challenge,
      );
    } finally {
      widget.onSubmittingStateChange(false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                  widget.userProfileImageUrl, // Use dynamic URL
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Posting as You',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Challenge Title',
              hintText: 'e.g., 30-Day Push-up Challenge',
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText:
                  'Describe your challenge and how others can participate...',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            minLines: 3,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap:
                      widget.isSubmitting
                          ? null
                          : () => _selectStartDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                        text:
                            _startDate == null
                                ? ''
                                : DateFormat.yMMMd().format(_startDate!),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      validator:
                          (value) =>
                              (_startDate == null)
                                  ? 'Please select a date'
                                  : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    suffixText: 'days',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: widget.isSubmitting ? null : _pickCoverImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Cover Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mutedForeground,
                  side: BorderSide(color: AppColors.mutedBackground),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    widget.isSubmitting
                        ? null
                        : () {
                          /* TODO: Invite Friends */
                        },
                icon: const Icon(Icons.person_add_alt_outlined),
                label: const Text('Invite Friends'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mutedForeground,
                  side: BorderSide(color: AppColors.mutedBackground),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          if (_coverImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      _coverImage!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                    onPressed: () => setState(() => _coverImage = null),
                    tooltip: 'Remove image',
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submit : null,
              child:
                  widget.isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Create Challenge'),
            ),
          ),
        ],
      ),
    );
  }
}
