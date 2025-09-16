import 'package:flutter/material.dart';
import 'package:fitnation/Screens/Trainer/TrainerProfileScreen.dart';

class MySessionsScreen extends StatefulWidget {
  const MySessionsScreen({super.key});

  @override
  State<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends State<MySessionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample booked sessions data
  final List<Map<String, dynamic>> upcomingSessions = [
    {
      'id': 'session_001',
      'trainerId': 'trainer_001',
      'trainerName': 'Sarah Johnson',
      'trainerImage': 'https://static.vecteezy.com/system/resources/thumbnails/046/837/177/small_2x/confident-indonesian-female-fitness-trainer-in-gym-emphasizing-strength-and-wellness-perfect-for-health-and-fitness-promotions-photo.jpg',
      'sessionType': 'Personal Training',
      'date': 'Aug 15, 2025',
      'time': '10:00 AM',
      'duration': '60 min',
      'location': 'Gym',
      'price': 2500,
      'status': 'Confirmed',
      'canCancel': true,
    },
    {
      'id': 'session_002',
      'trainerId': 'trainer_003',
      'trainerName': 'Fatima Khan',
      'trainerImage': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      'sessionType': 'Yoga Session',
      'date': 'Aug 17, 2025',
      'time': '06:00 PM',
      'duration': '75 min',
      'location': 'Online',
      'price': 2800,
      'status': 'Confirmed',
      'canCancel': true,
    },
    {
      'id': 'session_003',
      'trainerId': 'trainer_002',
      'trainerName': 'Rahman Ahmed',
      'trainerImage': 'https://static.vecteezy.com/system/resources/thumbnails/046/837/133/small/confident-middle-aged-bangladeshi-male-fitness-trainer-in-black-shirt-standing-in-modern-gym-with-treadmills-photo.jpg',
      'sessionType': 'CrossFit Training',
      'date': 'Aug 20, 2025',
      'time': '09:00 AM',
      'duration': '45 min',
      'location': 'Gym',
      'price': 2200,
      'status': 'Pending',
      'canCancel': true,
    },
  ];

  final List<Map<String, dynamic>> pastSessions = [
    {
      'id': 'session_004',
      'trainerId': 'trainer_006',
      'trainerName': 'Karim Hassan',
      'trainerImage': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      'sessionType': 'Nutrition Consultation',
      'date': 'Aug 10, 2025',
      'time': '02:00 PM',
      'duration': '60 min',
      'location': 'Online',
      'price': 2600,
      'status': 'Completed',
      'canReview': true,
      'rating': 0,
    },
    {
      'id': 'session_005',
      'trainerId': 'trainer_001',
      'trainerName': 'Sarah Johnson',
      'trainerImage': 'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400',
      'sessionType': 'Personal Training',
      'date': 'Aug 08, 2025',
      'time': '04:00 PM',
      'duration': '60 min',
      'location': 'Gym',
      'price': 2500,
      'status': 'Completed',
      'canReview': false,
      'rating': 5,
    },
    {
      'id': 'session_006',
      'trainerId': 'trainer_005',
      'trainerName': 'Nadia Rahman',
      'trainerImage': 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      'sessionType': 'Dance Fitness',
      'date': 'Aug 05, 2025',
      'time': '07:00 PM',
      'duration': '50 min',
      'location': 'Gym',
      'price': 2100,
      'status': 'Completed',
      'canReview': false,
      'rating': 4,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Sessions',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          indicatorWeight: 3,
          tabs: [
            Tab(
              text: 'Upcoming (${upcomingSessions.length})',
            ),
            Tab(
              text: 'Past (${pastSessions.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingSessionsTab(),
          _buildPastSessionsTab(),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionsTab() {
    if (upcomingSessions.isEmpty) {
      return _buildEmptyState(
        'No Upcoming Sessions',
        'You don\'t have any upcoming sessions. Book a session with a trainer to get started!',
        Icons.calendar_today,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingSessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(upcomingSessions[index], true);
      },
    );
  }

  Widget _buildPastSessionsTab() {
    if (pastSessions.isEmpty) {
      return _buildEmptyState(
        'No Past Sessions',
        'Your completed sessions will appear here.',
        Icons.history,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pastSessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(pastSessions[index], false);
      },
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, bool isUpcoming) {
    final status = session['status'] as String;
    Color statusColor;
    switch (status) {
      case 'Confirmed':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: InkWell(
        onTap: () {
          _showSessionDetails(session);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      session['trainerImage'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session['trainerName'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session['sessionType'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Session Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(Icons.calendar_today, 'Date', session['date']),
                  ),
                  Expanded(
                    child: _buildDetailItem(Icons.access_time, 'Time', session['time']),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(Icons.timer, 'Duration', session['duration']),
                  ),
                  Expanded(
                    child: _buildDetailItem(Icons.location_on, 'Location', session['location']),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Price and Actions
              Row(
                children: [
                  Text(
                    '৳${session['price']}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isUpcoming) ...[
                    if (session['canCancel'])
                      TextButton(
                        onPressed: () => _cancelSession(session),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _rescheduleSession(session),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ] else ...[
                    if (session['canReview'])
                      ElevatedButton(
                        onPressed: () => _rateSession(session),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Rate Session',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    if (session['rating'] != null && session['rating'] > 0 && !session['canReview'])
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              size: 16,
                              color: index < session['rating'] ? Colors.orange : Colors.grey[600],
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            'Rated',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.grey,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      session['trainerImage'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session['trainerName'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          session['sessionType'],
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainerProfileScreen(trainerId: session['trainerId']),
                        ),
                      );
                    },
                    child: const Text('View Profile', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Session Details',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Session ID', session['id']),
              _buildDetailRow('Date & Time', '${session['date']} at ${session['time']}'),
              _buildDetailRow('Duration', session['duration']),
              _buildDetailRow('Location', session['location']),
              _buildDetailRow('Price', '৳${session['price']}'),
              _buildDetailRow('Status', session['status']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelSession(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cancel Session', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this session with ${session['trainerName']}?',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cancellation Policy:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Free cancellation up to 24 hours before\n'
              '• 50% refund for cancellations within 24 hours\n'
              '• No refund for same-day cancellations',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Session', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle cancellation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session cancelled successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Cancel Session', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _rescheduleSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reschedule feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _rateSession(Map<String, dynamic> session) {
    int selectedRating = 0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Rate Session', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How was your session with ${session['trainerName']}?',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                      child: Icon(
                        Icons.star,
                        size: 32,
                        color: index < selectedRating ? Colors.orange : Colors.grey[600],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write a review (optional)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: selectedRating > 0 ? () {
                  Navigator.pop(context);
                  // Handle rating submission
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your rating!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}
