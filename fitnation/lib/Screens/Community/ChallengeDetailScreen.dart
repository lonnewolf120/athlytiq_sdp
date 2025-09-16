import 'package:fitnation/models/challenge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../services/challenge_service.dart';
import '../../widgets/compact_product_card.dart';
import '../product_detail_page.dart';
import '../shop_page.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  ConsumerState<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  bool _isJoined = false;
  int _participantCount = 0;
  List<ChallengeParticipant> _participants = [];
  bool _isLoading = false;
  Challenge? _currentChallenge;
  double _userProgress = 0.0;
  final TextEditingController _progressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentChallenge = widget.challenge;
    _isJoined = widget.challenge.isJoined;
    _participantCount = widget.challenge.friendsJoined;
    _loadChallengeDetails();
    _loadParticipants();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadChallengeDetails() async {
    try {
      final challengeService = ref.read(challengeServiceProvider);
      final updatedChallenge = await challengeService.getChallenge(widget.challenge.id);
      if (mounted) {
        setState(() {
          _currentChallenge = updatedChallenge;
          _isJoined = updatedChallenge.isJoined;
          _participantCount = updatedChallenge.friendsJoined;
          
          if (_isJoined && updatedChallenge.participants != null) {
            final currentUserId = _getCurrentUserId();
            if (currentUserId != null) {
              final userParticipants = updatedChallenge.participants!
                  .where((p) => p.userId == currentUserId);
              if (userParticipants.isNotEmpty) {
                _userProgress = userParticipants.first.progress;
              }
            }
          }
        });
      }
    } catch (e) {
      print('Error loading challenge details: $e');
    }
  }

  Future<void> _loadParticipants() async {
    setState(() => _isLoading = true);
    try {
      final challengeService = ref.read(challengeServiceProvider);
      final participants = await challengeService.getChallengeParticipants(widget.challenge.id);
      if (mounted) {
        // Update participants and sync current user's progress if available
        final currentUserId = _getCurrentUserId();
        double? currentUserProgress;
        if (currentUserId != null) {
          final matches = participants.where((p) => p.userId == currentUserId).toList();
          if (matches.isNotEmpty) {
            currentUserProgress = matches.first.progress;
          }
        }

        setState(() {
          _participants = participants;
          if (currentUserProgress != null) {
            _userProgress = currentUserProgress;
          }
        });
      }
    } catch (e) {
      print('Error loading participants: $e');
      if (_currentChallenge?.participants != null) {
        final fallback = _currentChallenge!.participants!;
        // Try to sync user progress from fallback data too
        final currentUserId = _getCurrentUserId();
        double? currentUserProgress;
        if (currentUserId != null) {
          final matches = fallback.where((p) => p.userId == currentUserId).toList();
          if (matches.isNotEmpty) {
            currentUserProgress = matches.first.progress;
          }
        }

        setState(() {
          _participants = fallback;
          if (currentUserProgress != null) {
            _userProgress = currentUserProgress;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadChallengeDetails(),
      _loadParticipants(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _currentChallenge ?? widget.challenge;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    challenge.backgroundImage ?? 'https://via.placeholder.com/400x300?text=Challenge',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: widget.challenge.brandColor!.withOpacity(0.3),
                        child: Icon(
                          _getActivityIcon(widget.challenge.activityType),
                          size: 80,
                          color: challenge.brandColor,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            challenge.brand?.toUpperCase() ?? 'CHALLENGE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: challenge.brandColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: challenge.brandColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getActivityIcon(challenge.activityType),
                          color: challenge.brandColor ?? Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.activityType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: challenge.brandColor ?? Colors.grey,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              challenge.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Duration',
                            "${challenge.duration ?? 0} days",
                            Icons.calendar_month,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Distance',
                            "${challenge.distance ?? 0} km",
                            Icons.straighten,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Participants',
                            '$_participantCount',
                            Icons.people,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'About This Challenge',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join thousands of athletes in this exciting challenge. Track your progress, compete with friends, and achieve your fitness goals together.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  if (_isJoined) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showProgressUpdateDialog(),
                          icon: Icon(
                            Icons.edit,
                            color: challenge.brandColor ?? Colors.blue,
                            size: 20,
                          ),
                          tooltip: 'Update Progress',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: challenge.brandColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: challenge.brandColor?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                (() {
                                  final unit = _getActivityInfo(challenge.activityType)['unit'];
                                  final distance = challenge.distance ?? 0;
                                  return '${_userProgress.toStringAsFixed(1)} $unit / $distance $unit';
                                })(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: challenge.brandColor ?? Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _getProgressPercentage(challenge),
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(challenge.brandColor ?? Colors.grey),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_getProgressPercentage(challenge) * 100).toStringAsFixed(0)}% Complete',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              if (_userProgress < (challenge.distance ?? 0))
                                Text(
                                  (() {
                                    final unit = _getActivityInfo(challenge.activityType)['unit'];
                                    final remaining = ((challenge.distance ?? 0) - _userProgress).clamp(0, double.infinity);
                                    return '${remaining.toStringAsFixed(1)} $unit to go';
                                  })(),
                                   style: TextStyle(
                                     fontSize: 14,
                                     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                   ),
                                 ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showProgressUpdateDialog(),
                              icon: Icon(Icons.update, size: 18),
                              label: Text('Update Progress'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: challenge.brandColor ?? Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ..._buildLeaderboardItems(),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Challenge Rules',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ..._buildRuleItems(),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed: _toggleJoinChallenge,
          backgroundColor: _isJoined 
              ? Colors.grey.withOpacity(0.2)
              : (challenge.brandColor ?? Colors.blue),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _isJoined 
                ? BorderSide(color: Colors.grey.withOpacity(0.5), width: 1)
                : BorderSide.none,
          ),
          label: Text(
            _isJoined ? 'Leave Challenge' : 'Join Challenge',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isJoined 
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.white,
            ),
          ),
          icon: Icon(
            _isJoined ? Icons.check : Icons.add,
            color: _isJoined 
                ? Theme.of(context).colorScheme.onSurface
                : Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: widget.challenge.brandColor,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String? _getCurrentUserId() {
    // Resolve currently authenticated user via Riverpod auth provider
    return ref.read(currentUserProvider)?.id;
  }

  double _getProgressPercentage(Challenge challenge) {
    if (challenge.distance == null || challenge.distance == 0) return 0.0;
    return (_userProgress / challenge.distance!).clamp(0.0, 1.0);
  }

  Future<void> _showProgressUpdateDialog() async {
    final challenge = _currentChallenge ?? widget.challenge;
    _progressController.text = _userProgress.toString();
    
    final activityInfo = _getActivityInfo(challenge.activityType);
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getActivityIcon(challenge.activityType),
                color: challenge.brandColor ?? Colors.blue,
              ),
              SizedBox(width: 8),
              Text('Update Progress'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your progress for ${challenge.title}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _progressController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '${activityInfo['label']} (${activityInfo['unit']})',
                    hintText: 'Enter ${activityInfo['label']?.toLowerCase() ?? 'progress'} completed',
                    suffixText: activityInfo['unit'],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: challenge.brandColor ?? Colors.blue,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      _getActivityIcon(challenge.activityType),
                      color: challenge.brandColor ?? Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: challenge.brandColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flag,
                            color: challenge.brandColor ?? Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Target: ${challenge.distance ?? 0} ${activityInfo['unit']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: challenge.brandColor ?? Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_userProgress > 0) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: challenge.brandColor ?? Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Current: $_userProgress ${activityInfo['unit']} (${(_getProgressPercentage(challenge) * 100).toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: challenge.brandColor ?? Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _updateProgress();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: challenge.brandColor ?? Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Update Progress'),
            ),
          ],
        );
      },
    );
  }

  Map<String, String> _getActivityInfo(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'run':
      case 'walk':
      case 'hike':
        return {'label': 'Distance', 'unit': 'km'};
      case 'ride':
        return {'label': 'Distance', 'unit': 'km'};
      case 'swim':
        return {'label': 'Distance', 'unit': 'km'};
      case 'workout':
        return {'label': 'Sessions', 'unit': 'count'};
      default:
        return {'label': 'Progress', 'unit': 'units'};
    }
  }

  Future<void> _updateProgress() async {
    final challenge = _currentChallenge ?? widget.challenge;
    final progressText = _progressController.text.trim();
    
    if (progressText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid progress value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final progress = double.tryParse(progressText);
    if (progress == null || progress < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (progress > (challenge.distance ?? 0) * 1.5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Progress cannot exceed target by more than 50%'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final challengeService = ref.read(challengeServiceProvider);
      final progressPercentage = challenge.distance != null && challenge.distance! > 0
          ? (progress / challenge.distance!) * 100
          : 0.0;

      await challengeService.updateProgress(
        challenge.id,
        {
          'progress': progress,
          'progress_percentage': progressPercentage.clamp(0.0, 100.0),
          'notes': 'Progress updated via app',
        },
      );

      setState(() {
        _userProgress = progress;
      });

      await _loadParticipants();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Progress updated successfully!'),
          backgroundColor: challenge.brandColor ?? Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      print('Error updating progress: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update progress: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  List<Widget> _buildLeaderboardItems() {
    final challenge = _currentChallenge ?? widget.challenge;
    
    if (_participants.isNotEmpty) {
      return _participants.asMap().entries.map((entry) {
        final int index = entry.key;
        final ChallengeParticipant participant = entry.value;
        final int rank = index + 1;
        final bool isCurrentUser = _getCurrentUserId() != null && participant.userId == _getCurrentUserId();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser 
                ? challenge.brandColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentUser 
                  ? challenge.brandColor?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankColor(rank).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getRankColor(rank),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  participant.username ?? 'Anonymous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                (() {
                  final unit = _getActivityInfo(challenge.activityType)['unit'];
                  return '${participant.progress.toStringAsFixed(1)} $unit';
                })(),
                 style: TextStyle(
                   fontSize: 14,
                   fontWeight: FontWeight.bold,
                   color: challenge.brandColor ?? Colors.grey,
                 ),
               ),
            ],
          ),
        );
      }).toList();
    }
    
    final leaders = [
      {'name': 'Rafid Rahman', 'progress': '5.0 km', 'rank': 1},
      {'name': 'Kamrul Hasan', 'progress': '4.8 km', 'rank': 2},
      {'name': 'Fatima Sultana', 'progress': '4.5 km', 'rank': 3},
      {'name': 'You', 'progress': '3.2 km', 'rank': 4},
    ];

    return leaders.map((leader) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: leader['name'] == 'You' 
            ? challenge.brandColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: leader['name'] == 'You' 
              ? challenge.brandColor?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(leader['rank'] as int).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${leader['rank']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(leader['rank'] as int),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              leader['name'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            leader['progress'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: challenge.brandColor ?? Colors.grey,
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildRuleItems() {
    final rules = [
      'Complete the challenge within the specified time frame',
      'Track your activities using any fitness app',
      'Submit proof of completion through the app',
      'Be respectful to other participants',
      'Have fun and stay motivated!',
    ];

    return rules.asMap().entries.map((entry) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.challenge.brandColor!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${entry.key + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.challenge.brandColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.value,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Color _getRankColor(int rank) {
    final challenge = _currentChallenge ?? widget.challenge;
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return challenge.brandColor ?? Colors.grey;
    }
  }

  IconData _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'run':
        return Icons.directions_run;
      case 'ride':
        return Icons.directions_bike;
      case 'swim':
        return Icons.pool;
      case 'walk':
        return Icons.directions_walk;
      case 'hike':
        return Icons.hiking;
      case 'workout':
        return Icons.fitness_center;
      default:
        return Icons.sports;
    }
  }

  void _toggleJoinChallenge() async {
    final challenge = _currentChallenge ?? widget.challenge;
    final challengeService = ref.read(challengeServiceProvider);
    
    try {
      if (_isJoined) {
        await challengeService.leaveChallenge(challenge.id);
        setState(() {
          _isJoined = false;
          _participantCount -= 1;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Left ${challenge.title}'),
            backgroundColor: Colors.grey,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        await challengeService.joinChallenge(challenge.id);
        setState(() {
          _isJoined = true;
          _participantCount += 1;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined ${challenge.title}!'),
            backgroundColor: challenge.brandColor ?? Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        _showSuggestedProductsDialog();
      }
      
      await _loadChallengeDetails();
      await _loadParticipants();
      
    } catch (e) {
      print('Error toggling challenge participation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showSuggestedProductsDialog() {
    final suggestedProducts = ProductService.getSuggestedProductsForActivity(widget.challenge.activityType);
    
    if (suggestedProducts.isEmpty) return;

    String getActivityMessage(String activityType) {
      switch (activityType.toLowerCase()) {
        case 'run':
          return 'Get the perfect running gear to boost your performance!';
        case 'ride':
          return 'Enhance your cycling experience with premium gear!';
        case 'swim':
          return 'Dive in with the best swimming equipment!';
        case 'hike':
          return 'Conquer trails with professional hiking gear!';
        default:
          return 'Here are some recommended products to help you succeed:';
      }
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            minHeight: 400,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    _getActivityIcon(widget.challenge.activityType),
                    color: widget.challenge.brandColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gear up for your ${widget.challenge.activityType.toLowerCase()}ning challenge!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                getActivityMessage(widget.challenge.activityType),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[300],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight - 60; 
                    final itemHeight = availableHeight / 2 - 6; 
                    final itemWidth = (constraints.maxWidth - 12) / 2; 
                    final aspectRatio = (itemWidth / itemHeight).clamp(0.7, 1.2);
                    
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: suggestedProducts.length,
                      itemBuilder: (context, index) {
                        final product = suggestedProducts[index];
                        return CompactProductCard(
                          product: product,
                          onTap: () {
                            Navigator.of(context).pop(); 
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(product: product),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Maybe Later',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        String getCategoryForActivity(String activityType) {
                          switch (activityType.toLowerCase()) {
                            case 'run':
                            case 'hike':
                              return 'footwear';
                            case 'ride':
                              return 'accessories';
                            case 'swim':
                              return 'accessories';
                            default:
                              return 'equipment';
                          }
                        }
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopPage(
                              initialCategory: getCategoryForActivity(widget.challenge.activityType),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.challenge.brandColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Shop Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
