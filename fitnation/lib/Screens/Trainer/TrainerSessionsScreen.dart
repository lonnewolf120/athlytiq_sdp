import 'package:flutter/material.dart';

class TrainerSessionsScreen extends StatefulWidget {
  const TrainerSessionsScreen({super.key});

  @override
  State<TrainerSessionsScreen> createState() => _TrainerSessionsScreenState();
}

class _TrainerSessionsScreenState extends State<TrainerSessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo data representing sessions the TRAINER has with clients
  final List<Map<String, dynamic>> upcoming = [
    {
      'id': 'ts_001',
      'clientId': 'u_1001',
      'clientName': 'Akram Emtiaz',
      'clientImage':
          'https://randomuser.me/api/portraits/men/11.jpg',
      'sessionType': 'Strength Training',
      'date': 'Sep 17, 2025',
      'time': '09:00 AM',
      'duration': '60 min',
      'location': 'Gym',
      'status': 'Confirmed',
      'price': 2500,
    },
    {
      'id': 'ts_002',
      'clientId': 'u_1002',
      'clientName': 'Sadia Islam',
      'clientImage':
          'https://randomuser.me/api/portraits/women/12.jpg',
      'sessionType': 'HIIT',
      'date': 'Sep 22, 2025',
      'time': '06:30 PM',
      'duration': '45 min',
      'location': 'Online',
      'status': 'Pending',
      'price': 2200,
    },
  ];

  final List<Map<String, dynamic>> past = [
    {
      'id': 'ts_010',
      'clientId': 'u_1003',
      'clientName': 'Michael Chen',
      'clientImage':
          'https://randomuser.me/api/portraits/men/14.jpg',
      'sessionType': 'Mobility & Stretch',
      'date': 'Sep 10, 2025',
      'time': '07:00 PM',
      'duration': '45 min',
      'location': 'Gym',
      'status': 'Completed',
      'price': 2000,
      'rating': 5,
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
  final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions (Trainer)'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Upcoming (${upcoming.length})'),
            Tab(text: 'Past (${past.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(context, upcoming, isUpcoming: true),
          _buildList(context, past, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> items,
      {required bool isUpcoming}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy,
                size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(isUpcoming ? 'No upcoming sessions' : 'No past sessions',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                )),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => _sessionCard(context, items[index], isUpcoming),
    );
  }

  Widget _sessionCard(
      BuildContext context, Map<String, dynamic> session, bool isUpcoming) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color statusColor;
    switch (session['status']) {
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
        statusColor = colorScheme.onSurfaceVariant;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetails(context, session),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(session['clientImage']),
                    radius: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session['clientName'],
                            style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(session['sessionType'],
                            style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      session['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _detail(context, Icons.calendar_today, 'Date',
                        session['date']),
                  ),
                  Expanded(
                    child: _detail(
                        context, Icons.access_time, 'Time', session['time']),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _detail(context, Icons.timer, 'Duration',
                        session['duration']),
                  ),
                  Expanded(
                    child: _detail(context, Icons.location_on, 'Location',
                        session['location']),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('৳${session['price']}',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                  const Spacer(),
                  if (isUpcoming) ...[
                    OutlinedButton(
                      onPressed: () => _messageClient(session),
                      child: const Text('Message'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _startSession(session),
                      child: const Text('Start'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _cancelSession(session),
                      child: const Text('Cancel'),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () => _viewNotes(session),
                      child: const Text('View Notes'),
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

  Widget _detail(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label,
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(value,
              style:
                  textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(session['clientImage']),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session['clientName'],
                            style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600)),
                        Text(session['sessionType'],
                            style: textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detail(ctx, Icons.calendar_today, 'Date', session['date']),
              const SizedBox(height: 6),
              _detail(ctx, Icons.access_time, 'Time', session['time']),
              const SizedBox(height: 6),
              _detail(ctx, Icons.timer, 'Duration', session['duration']),
              const SizedBox(height: 6),
              _detail(ctx, Icons.location_on, 'Location', session['location']),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _messageClient(session);
                    },
                    child: const Text('Message'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _startSession(session);
                    },
                    child: const Text('Start Session'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _messageClient(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Messaging ${session['clientName']}…')),
    );
  }

  void _startSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting session ${session['id']}')),
    );
  }

  void _cancelSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelled session ${session['id']}')),
    );
  }

  void _viewNotes(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing notes for ${session['id']}')),
    );
  }
}
