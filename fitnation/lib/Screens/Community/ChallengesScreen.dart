import 'package:flutter/material.dart';
import 'ChallengeDetailScreen.dart';
import 'AddChallengeScreen.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String brand;
  final String brandLogo;
  final String backgroundImage;
  final String distance;
  final String duration;
  final int friendsJoined;
  final bool isJoined;
  final Color brandColor;
  final String activityType;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.brand,
    required this.brandLogo,
    required this.backgroundImage,
    required this.distance,
    required this.duration,
    required this.friendsJoined,
    required this.isJoined,
    required this.brandColor,
    required this.activityType,
  });
}

final List<Challenge> _stravaStyleChallenges = [
  Challenge(
    id: 'ch1',
    title: 'July 5K x FitNation Challenge',
    description: 'Complete a 5 km (3.1 mi) run.',
    brand: 'FitNation',
    brandLogo: '🏃',
    backgroundImage: 'https://images.unsplash.com/photo-1590333748338-d629e4564ad9?q=80&w=1249&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    distance: '5.0 km',
    duration: '1 Jul 2025 to 31 Jul 2025',
    friendsJoined: 0,
    isJoined: false,
    brandColor: Colors.orange,
    activityType: 'Run',
  ),
  Challenge(
    id: 'ch2',
    title: 'August 5K x FitNation Challenge',
    description: 'Complete a 5 km (3.1 mi) run.',
    brand: 'FitNation',
    brandLogo: '🏃',
    backgroundImage: 'https://images.unsplash.com/photo-1452626038306-9aae5e071dd3?q=80&w=1174&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    distance: '5.0 km',
    duration: '1 Aug 2025 to 31 Aug 2025',
    friendsJoined: 0,
    isJoined: false,
    brandColor: Colors.orange,
    activityType: 'Run',
  ),
  Challenge(
    id: 'ch3',
    title: 'Cycling Century Challenge',
    description: 'Complete a 100 km ride in one session.',
    brand: 'CycleMax',
    brandLogo: '🚴',
    backgroundImage: 'https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    distance: '100 km',
    duration: '1 Jul 2025 to 31 Jul 2025',
    friendsJoined: 3,
    isJoined: true,
    brandColor: Colors.blue,
    activityType: 'Ride',
  ),
  Challenge(
    id: 'ch4',
    title: 'Swimming Marathon',
    description: 'Complete a 5 km swim distance.',
    brand: 'AquaFit',
    brandLogo: '🏊',
    backgroundImage: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=60',
    distance: '5.0 km',
    duration: '15 Jul 2025 to 15 Aug 2025',
    friendsJoined: 1,
    isJoined: false,
    brandColor: Colors.cyan,
    activityType: 'Swim',
  ),
  Challenge(
    id: 'ch5',
    title: 'Mountain Hiking Challenge',
    description: 'Complete a 15 km hike with elevation gain.',
    brand: 'TrailBlazers',
    brandLogo: '⛰️',
    backgroundImage: 'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=60',
    distance: '15 km',
    duration: '1 Jul 2025 to 30 Sep 2025',
    friendsJoined: 2,
    isJoined: true,
    brandColor: Colors.green,
    activityType: 'Hike',
  ),
  Challenge(
    id: 'ch6',
    title: 'Daily Walk Challenge',
    description: 'Walk 10,000 steps daily for 30 days.',
    brand: 'StepFit',
    brandLogo: '🚶',
    backgroundImage: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=60',
    distance: '10k steps',
    duration: '1 Jul 2025 to 31 Jul 2025',
    friendsJoined: 5,
    isJoined: false,
    brandColor: Colors.purple,
    activityType: 'Walk',
  ),
];

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  String selectedActivity = 'All';
  final List<String> activityTypes = ['All', 'Run', 'Ride', 'Swim', 'Walk', 'Hike', 'Workout'];
  List<Challenge> userChallenges = [];

  List<Challenge> get allChallenges {
    return [..._stravaStyleChallenges, ...userChallenges];
  }

  List<Challenge> get filteredChallenges {
    if (selectedActivity == 'All') return allChallenges;
    return allChallenges.where((c) => c.activityType == selectedActivity).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Challenges',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final Challenge? newChallenge = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddChallengeScreen(),
                ),
              );
              
              if (newChallenge != null) {
                setState(() {
                  userChallenges.add(newChallenge);
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: activityTypes.length,
              itemBuilder: (context, index) {
                final activity = activityTypes[index];
                final isSelected = selectedActivity == activity;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedActivity = activity;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getActivityIcon(activity),
                            size: 16,
                            color: isSelected 
                              ? Colors.white 
                              : Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activity,
                            style: TextStyle(
                              color: isSelected 
                                ? Colors.white 
                                : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended For You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Based on your activities',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: filteredChallenges.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = filteredChallenges[index];
                    return _buildStravaStyleChallengeCard(challenge);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${selectedActivity == 'All' ? '' : selectedActivity.toLowerCase()} challenges yet',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your own challenge to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final Challenge? newChallenge = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddChallengeScreen(),
                ),
              );
              
              if (newChallenge != null) {
                setState(() {
                  userChallenges.add(newChallenge);
                });
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Challenge'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStravaStyleChallengeCard(Challenge challenge) {
    final isUserCreated = userChallenges.contains(challenge);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              child: Image.network(
                challenge.backgroundImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: challenge.brandColor.withOpacity(0.3),
                    child: Icon(
                      _getActivityIcon(challenge.activityType),
                      size: 60,
                      color: challenge.brandColor,
                    ),
                  );
                },
              ),
            ),
            
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.brandLogo,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            if (isUserCreated)
              Positioned(
                top: 16,
                left: 60,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Created by You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      challenge.brand.toUpperCase(),
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

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getActivityIcon(challenge.activityType),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            challenge.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge.duration,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${challenge.friendsJoined} friends have joined',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChallengeDetailScreen(challenge: challenge),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: challenge.isJoined 
                            ? Colors.white.withOpacity(0.2)
                            : challenge.brandColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: challenge.isJoined 
                              ? const BorderSide(color: Colors.white, width: 1)
                              : BorderSide.none,
                          ),
                        ),
                        child: Text(
                          challenge.isJoined ? 'View Challenge' : 'Join Challenge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

}
