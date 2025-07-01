import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnation/models/CommunityContentModel.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:intl/intl.dart'; // For formatting time

class StoryScreen extends StatefulWidget {
  final List<StoryContentItem> storyContent;
  final int initialIndex;
  final String userName;
  final String? userImage;

  const StoryScreen({
    super.key,
    required this.storyContent,
    this.initialIndex = 0,
    required this.userName,
    this.userImage,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isPaused = false;
  bool _isMuted = false; // Assuming stories might have audio

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPage = widget.initialIndex;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Default duration for each story segment
    );

    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        _nextStoryContent();
      }
    });

    _startStoryTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _animationController.stop();
    _animationController.reset();
    _animationController.duration = _getDurationForCurrentStory(widget.storyContent[_currentPage]);
    if (!_isPaused) {
      _animationController.forward();
    }
  }

  Duration _getDurationForCurrentStory(StoryContentItem contentItem) {
    // Customize duration based on content type if needed
    // For now, all stories have a default duration of 5 seconds.
    return const Duration(seconds: 5);
  }

  void _togglePausePlay() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _animationController.stop();
      } else {
        _animationController.forward();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      // Implement actual mute/unmute logic for audio if present
    });
  }

  void _nextStoryContent() {
    if (_currentPage < widget.storyContent.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200), // Changed from 300 to 200
        curve: Curves.easeIn,
      );
      _startStoryTimer(); // Added this line
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStoryContent() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200), // Changed from 300 to 200
        curve: Curves.easeIn,
      );
      _startStoryTimer(); // Added this line
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildStoryContent(StoryContentItem contentItem) {
    switch (contentItem.type) {
      case 'image':
        return CachedNetworkImage(
          imageUrl: contentItem.content,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      case 'text':
        return Container(
          color: const Color(0xFF4DD0E1), // Light blue from image
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                contentItem.content,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              // You might parse emojis and display them larger here if needed
            ],
          ),
        );
      case 'location':
        final locationName = contentItem.content;
        final address = contentItem.locationDetails?['address'] as String?;
        // final latitude = contentItem.locationDetails?['latitude'] as double?;
        // final longitude = contentItem.locationDetails?['longitude'] as double?;
        return Container(
          color: const Color(0xFF4DD0E1), // Light blue from image
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                locationName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (address != null)
                Text(
                  address,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () {
                    // Implement map view launch
                    // For example, using url_launcher:
                    // if (latitude != null && longitude != null) {
                    //   launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'));
                    // }
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Map View', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'workout':
        final workoutName = contentItem.content;
        final duration = contentItem.workoutDetails?['duration'] as int?;
        final intensity = contentItem.workoutDetails?['intensity'] as int?;
        final exercises = contentItem.workoutDetails?['exercises'] as List<dynamic>?;

        return Container(
          color: const Color(0xFFEF5350), // Red from image
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                workoutName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWorkoutStatCard(context, Icons.timer, '${duration ?? '?'}', 'minutes'),
                  _buildWorkoutStatCard(context, Icons.local_fire_department, '${intensity ?? '?'}', 'intensity'),
                ],
              ),
              const SizedBox(height: 24),
              if (exercises != null && exercises.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'Exercises',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...exercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exercise['name'] as String,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                            ),
                            Text(
                              '${exercise['sets']}x${exercise['reps']} ${exercise['weight'] ?? ''}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        );
      default:
        return Container(
          color: Colors.grey,
          alignment: Alignment.center,
          child: Text('Unsupported story type: ${contentItem.type}'),
        );
    }
  }

  Widget _buildWorkoutStatCard(BuildContext context, IconData icon, String value, String label) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => _animationController.stop(),
        onLongPressEnd: (_) {
          if (!_isPaused) {
            _animationController.forward();
          }
        },
        onTapDown: (details) {
          if (details.globalPosition.dx < MediaQuery.of(context).size.width / 2) {
            _previousStoryContent();
          } else {
            _nextStoryContent();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.storyContent.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
            _startStoryTimer(); // Restart timer for new page after state update
          },
          itemBuilder: (context, index) {
            final contentItem = widget.storyContent[index];
            return Stack(
              children: [
                // Background content (image, text, location, workout)
                Positioned.fill(
                  child: _buildStoryContent(contentItem),
                ),
                // Top bar with user info, progress indicators, and controls
                SafeArea(
                  child: Column(
                    children: [
                      // Progress indicators
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: List.generate(widget.storyContent.length, (i) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: LinearProgressIndicator(
                                  value: i == _currentPage
                                      ? _animationController.value
                                      : (i < _currentPage ? 1.0 : 0.0),
                                  backgroundColor: Colors.white.withOpacity(0.5),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: widget.userImage != null
                                  ? CachedNetworkImageProvider(widget.userImage!)
                                  : null,
                              child: widget.userImage == null
                                  ? Text(widget.userName[0].toUpperCase(), style: Theme.of(context).textTheme.labelLarge)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.userName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                                ),
                                if (contentItem.time != null)
                                  Text(
                                    DateFormat('hh:mm a').format(contentItem.time!),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                _isPaused ? Icons.play_arrow : Icons.pause,
                                color: Colors.white,
                              ),
                              onPressed: _togglePausePlay,
                            ),
                            IconButton(
                              icon: Icon(
                                _isMuted ? Icons.volume_off : Icons.volume_up,
                                color: Colors.white,
                              ),
                              onPressed: _toggleMute,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
