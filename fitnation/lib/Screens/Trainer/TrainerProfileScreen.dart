import 'package:flutter/material.dart';
import 'package:fitnation/Screens/Trainer/SessionBookingScreen.dart';

class TrainerProfileScreen extends StatefulWidget {
  final String trainerId;
  
  const TrainerProfileScreen({
    super.key,
    required this.trainerId,
  });

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFollowing = false;
  
  // Get trainer data by ID
  Map<String, dynamic> get trainerData {
    final trainers = {
      'trainer_001': {
        'name': 'Sarah Johnson',
        'title': 'Certified Personal Trainer',
        'rating': 4.8,
        'reviews': 156,
        'experience': '8 years',
        'sessions': 1200,
        'specializations': ['Weight Training', 'Cardio', 'Yoga', 'Nutrition'],
        'bio': 'Passionate fitness trainer with 8+ years of experience helping clients achieve their fitness goals. Specialized in strength training, cardio workouts, and yoga practices.',
        'profileImage': 'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400',
        'certifications': [
          'NASM Certified Personal Trainer',
          'Yoga Alliance RYT-200',
          'Precision Nutrition Level 1',
        ],
        'price': '৳2,500',
        'priceUnit': 'per session',
      },
      'trainer_002': {
        'name': 'Rahman Ahmed',
        'title': 'CrossFit Specialist',
        'rating': 4.7,
        'reviews': 98,
        'experience': '6 years',
        'sessions': 850,
        'specializations': ['CrossFit', 'Weight Training', 'Cardio'],
        'bio': 'CrossFit Level 2 trainer specializing in functional fitness and high-intensity workouts. Helping clients build strength, endurance, and mental toughness.',
        'profileImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'certifications': [
          'CrossFit Level 2 Trainer',
          'NSCA Certified Strength Coach',
          'First Aid & CPR Certified',
        ],
        'price': '৳2,200',
        'priceUnit': 'per session',
      },
      'trainer_003': {
        'name': 'Fatima Khan',
        'title': 'Yoga & Pilates Instructor',
        'rating': 4.9,
        'reviews': 210,
        'experience': '10 years',
        'sessions': 1500,
        'specializations': ['Yoga', 'Pilates', 'Meditation'],
        'bio': 'Certified yoga instructor with expertise in Hatha and Vinyasa yoga. Specializes in mindfulness practices and holistic wellness approaches.',
        'profileImage': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        'certifications': [
          'Yoga Alliance RYT-500',
          'Pilates Mat Certification',
          'Meditation Teacher Training',
        ],
        'price': '৳2,800',
        'priceUnit': 'per session',
      },
      'trainer_004': {
        'name': 'Imran Ali',
        'title': 'Martial Arts Expert',
        'rating': 4.6,
        'reviews': 75,
        'experience': '12 years',
        'sessions': 600,
        'specializations': ['Martial Arts', 'Self Defense', 'Cardio'],
        'bio': 'Black belt in Karate and Taekwondo with extensive teaching experience. Specializes in traditional martial arts and modern self-defense techniques.',
        'profileImage': 'https://images.unsplash.com/photo-1566753323558-f4e0952af115?w=400',
        'certifications': [
          '3rd Dan Black Belt Karate',
          '2nd Dan Black Belt Taekwondo',
          'Self Defense Instructor',
        ],
        'price': '৳3,000',
        'priceUnit': 'per session',
      },
      'trainer_005': {
        'name': 'Nadia Rahman',
        'title': 'Dance Fitness Coach',
        'rating': 4.7,
        'reviews': 132,
        'experience': '5 years',
        'sessions': 900,
        'specializations': ['Dance', 'Cardio', 'Zumba'],
        'bio': 'Professional dancer turned fitness coach specializing in fun, high-energy workouts. Makes fitness enjoyable through dance and music.',
        'profileImage': 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
        'certifications': [
          'Zumba Fitness Instructor',
          'Dance Fitness Certification',
          'Group Fitness Instructor',
        ],
        'price': '৳2,100',
        'priceUnit': 'per session',
      },
      'trainer_006': {
        'name': 'Karim Hassan',
        'title': 'Nutrition & Fitness Expert',
        'rating': 4.8,
        'reviews': 189,
        'experience': '7 years',
        'sessions': 1100,
        'specializations': ['Nutrition', 'Weight Training', 'Bodybuilding'],
        'bio': 'Certified nutritionist and personal trainer helping clients achieve their body composition goals through proper training and nutrition.',
        'profileImage': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
        'certifications': [
          'Certified Nutritionist',
          'NASM Personal Trainer',
          'Sports Nutrition Specialist',
        ],
        'price': '৳2,600',
        'priceUnit': 'per session',
      },
    };
    
    return trainers[widget.trainerId] ?? trainers['trainer_001']!;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Share trainer profile
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Show more options
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Image
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(trainerData['profileImage']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.4),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trainerData['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trainerData['title'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${trainerData['rating']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${trainerData['reviews']} reviews',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                trainerData['price'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' ${trainerData['priceUnit']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Experience', trainerData['experience']),
                  _buildStatDivider(),
                  _buildStatItem('Sessions', '${trainerData['sessions']}'),
                  _buildStatDivider(),
                  _buildStatItem('Rating', '${trainerData['rating']}/5'),
                ],
              ),
            ),
          ),

          // Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionBookingScreen(
                              trainerId: widget.trainerId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Session',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isFollowing = !isFollowing;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isFollowing ? Colors.red : Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: isFollowing ? Colors.red : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.red,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.red,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Schedule'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildReviewsTab(),
                _buildScheduleTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[700],
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio Section
          const Text(
            'About',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            trainerData['bio'],
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Specializations
          const Text(
            'Specializations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (trainerData['specializations'] as List<String>).map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Text(
                  spec,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Certifications
          const Text(
            'Certifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...(trainerData['certifications'] as List<String>).map((cert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cert,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Overview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      '${trainerData['rating']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < trainerData['rating'].floor()
                              ? Colors.orange
                              : Colors.grey[600],
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trainerData['reviews']} reviews',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(5, 0.7),
                      _buildRatingBar(4, 0.2),
                      _buildRatingBar(3, 0.05),
                      _buildRatingBar(2, 0.03),
                      _buildRatingBar(1, 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Individual Reviews
          const Text(
            'Reviews',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(5, (index) => _buildReviewCard(index)),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Time Slots',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a date to view available time slots',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Calendar would go here - simplified for now
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!, width: 1),
            ),
            child: const Center(
              child: Text(
                'Calendar Widget\n(Would show available dates)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sample time slots for today
          const Text(
            'Today\'s Available Slots',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          ..._buildTimeSlots(),
        ],
      ),
    );
  }

  List<Widget> _buildTimeSlots() {
    final timeSlots = [
      {'time': '09:00 AM', 'available': true},
      {'time': '10:30 AM', 'available': false},
      {'time': '12:00 PM', 'available': true},
      {'time': '02:00 PM', 'available': true},
      {'time': '04:00 PM', 'available': false},
      {'time': '06:00 PM', 'available': true},
    ];

    return timeSlots.map((slot) {
      final isAvailable = slot['available'] as bool;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tileColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[700]!, width: 1),
          ),
          leading: Icon(
            Icons.access_time,
            color: isAvailable ? Colors.green : Colors.grey,
          ),
          title: Text(
            slot['time'] as String,
            style: TextStyle(
              color: isAvailable ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            isAvailable ? 'Available' : 'Booked',
            style: TextStyle(
              color: isAvailable ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
          trailing: isAvailable
              ? ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionBookingScreen(
                          trainerId: widget.trainerId,
                          preSelectedTimeSlot: slot['time'] as String,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
        ),
      );
    }).toList();
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(int index) {
    final reviews = [
      {
        'name': 'Ahmed Hassan',
        'rating': 5,
        'date': '2 days ago',
        'comment': 'Excellent trainer! Sarah really helped me improve my form and technique. Highly recommended!',
        'avatar': 'https://i.pravatar.cc/100?img=${index + 1}',
      },
      {
        'name': 'Fatima Khan',
        'rating': 5,
        'date': '1 week ago', 
        'comment': 'Amazing experience! Sarah is very knowledgeable and motivating. I\'ve seen great results.',
        'avatar': 'https://i.pravatar.cc/100?img=${index + 10}',
      },
      {
        'name': 'Rafiq Ahmed',
        'rating': 4,
        'date': '2 weeks ago',
        'comment': 'Great trainer with good knowledge. Sessions are well structured and effective.',
        'avatar': 'https://i.pravatar.cc/100?img=${index + 20}',
      },
      {
        'name': 'Nadia Rahman',
        'rating': 5,
        'date': '3 weeks ago',
        'comment': 'Sarah is fantastic! Very patient and explains everything clearly. Love her yoga sessions.',
        'avatar': 'https://i.pravatar.cc/100?img=${index + 30}',
      },
      {
        'name': 'Imran Ali',
        'rating': 5,
        'date': '1 month ago',
        'comment': 'Professional and dedicated trainer. My fitness level has improved significantly!',
        'avatar': 'https://i.pravatar.cc/100?img=${index + 40}',
      },
    ];

    final review = reviews[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review['avatar'] as String),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review['date'] as String,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (starIndex) {
                  return Icon(
                    Icons.star,
                    color: starIndex < (review['rating'] as int)
                        ? Colors.orange
                        : Colors.grey[600],
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] as String,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
