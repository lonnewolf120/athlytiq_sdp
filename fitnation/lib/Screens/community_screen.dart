import 'package:flutter/material.dart';
import '../widgets/community/topic_chips_section.dart';
import 'topic_communities_page.dart';
import '../models/recommended_community.dart';
import '../widgets/community/recommended_communities_list.dart';
import '../models/top_chart_category.dart';
import '../widgets/community/top_charts_section.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // --- Bottom Navigation Bar State ---
  // Assuming "Communities" is the second tab (index 1)
  int _currentBottomNavIndex = 1;
  int _notificationCount = 1; // For the badge on Inbox

  // --- Data for Topic Chips ---
  final List<String> _communityTopics = [
    "Running", "Weightlifting", "Yoga & Pilates", "Nutrition", "HIIT",
    "CrossFit", "Cycling", "Swimming", "Meditation", "Healthy Recipes",
    "Motivation", "Strength Training", "Cardio Workouts", "Mental Wellness",
  ];

  // --- Data for Recommended Communities ---
  List<RecommendedCommunity> _sampleFitnessCommunities1 = [];
  List<RecommendedCommunity> _sampleFitnessCommunities2 = [];
  List<RecommendedCommunity> _sampleFitnessCommunities3 = [];

  // --- Data for Top Chart Categories ---
  List<TopChartCategory> _topChartFitnessCategories = [];


  @override
  void initState() {
    super.initState();
    _loadAllSampleData();
    print("CommunityScreen: initState called. Data loaded.");
  }

  void _loadAllSampleData() {
    _sampleFitnessCommunities1 = [
      RecommendedCommunity(id: 'rc101', name: 'Strength Gains Club', initials: 'SG', iconUrl: 'https://cdn-icons-png.flaticon.com/128/2964/2964514.png', memberCount: '1.8M members', description: 'Share your progress, routines, and PBs in strength training.'),
      RecommendedCommunity(id: 'rc102', name: 'Cardio Champions', initials: 'CC', iconUrl: 'https://cdn-icons-png.flaticon.com/128/857/857468.png', memberCount: '2.5M members', description: 'For all things running, cycling, swimming, and endurance.'),
      RecommendedCommunity(id: 'rc103', name: 'Yoga Flow Zone', initials: 'YF', iconUrl: 'https://cdn-icons-png.flaticon.com/128/2163/2163352.png', memberCount: '750k members', description: 'Find your flow with daily yoga practices and discussions.', isJoined: true),
      RecommendedCommunity(id: 'rc104', name: 'HIIT Blasters', initials: 'HB', iconUrl: 'https://cdn-icons-png.flaticon.com/128/9431/9431040.png', memberCount: '600k members', description: 'High-Intensity Interval Training routines and challenges.'),
    ];
    _sampleFitnessCommunities2 = [
      RecommendedCommunity(id: 'rc201', name: 'Nutrition Nerds', initials: 'NN', iconUrl: 'https://cdn-icons-png.flaticon.com/128/3480/3480823.png', memberCount: '1.1M members', description: 'Discussing macros, recipes, and the science of healthy eating.', isJoined: true),
      RecommendedCommunity(id: 'rc202', name: 'Outdoor Adventures', initials: 'OA', iconUrl: 'https://cdn-icons-png.flaticon.com/128/684/684223.png', memberCount: '890k members', description: 'Hiking, trail running, and exploring the great outdoors for fitness.'),
      RecommendedCommunity(id: 'rc203', name: 'Gym Buddies Connect', initials: 'GB', iconUrl: 'https://cdn-icons-png.flaticon.com/128/748/748992.png', memberCount: '500k members', description: 'Find workout partners and share gym experiences.'),
    ];
    _sampleFitnessCommunities3 = [
      RecommendedCommunity(id: 'rc301', name: 'Mental Wellness Warriors', initials: 'MW', iconUrl: 'https://cdn-icons-png.flaticon.com/128/1835/1835809.png', memberCount: '1.3M members', description: 'Meditation, mindfulness, and strategies for a healthy mind.'),
      RecommendedCommunity(id: 'rc302', name: 'Home Workout Heroes', initials: 'HW', iconUrl: 'https://cdn-icons-png.flaticon.com/128/3043/3043888.png', memberCount: '2.2M members', description: 'Effective fitness routines you can do from the comfort of your home.', isJoined: true),
      RecommendedCommunity(id: 'rc303', name: 'Active Seniors', initials: 'AS', iconUrl: 'https://cdn-icons-png.flaticon.com/128/3176/3176303.png', memberCount: '300k members', description: 'Staying fit and active for seniors. Share tips and encouragement.'),
      RecommendedCommunity(id: 'rc304', name: 'Competitive Edge', initials: 'CE', iconUrl: 'https://cdn-icons-png.flaticon.com/128/1040/1040201.png', memberCount: '450k members', description: 'For those training for marathons, triathlons, or other competitions.'),
    ];
    _topChartFitnessCategories = [
      TopChartCategory(id: 'tc001', title: 'Popular Workout Routines'),
      TopChartCategory(id: 'tc002', title: 'Nutrition Q&A Hot Topics'),
      TopChartCategory(id: 'tc003', title: 'Top Transformation Stories'),
      TopChartCategory(id: 'tc004', title: 'Most Active Local Fitness Groups'),
      TopChartCategory(id: 'tc005', title: 'Trending Healthy Recipes'),
      TopChartCategory(id: 'tc006', title: 'Equipment Reviews & Discussions'),
    ];
  }

  void _handleTopicSelection(String topicName) {
    print("CommunityScreen: Topic '$topicName' selected. Navigating...");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicCommunitiesPage(topicName: topicName),
      ),
    );
  }

  Future<void> _refreshData() async {
    print("CommunityScreen: Refreshing data...");
    await Future.delayed(const Duration(seconds: 2));
    _loadAllSampleData();
    if (mounted) {
      setState(() {});
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Community data refreshed (simulated)")),
    );
    print("CommunityScreen: Data refresh complete.");
  }

  // --- Bottom Navigation Bar tap handler ---
  void _onBottomNavItemTapped(int index) {
    if (_currentBottomNavIndex == index) return; // Do nothing if already on this tab

    setState(() {
      _currentBottomNavIndex = index;
    });

    // Placeholder navigation logic
    // In a real app, this would navigate to different screens or update the body content.
    switch (index) {
      case 0: // Home
        print("Navigate to Home Screen (Placeholder)");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Navigating to Home (Placeholder)")));
        // Example: Navigator.pushReplacementNamed(context, '/home');
        // If you have a main wrapper screen with PageView, you'd update its controller.
        break;
      case 1: // Communities (Current Screen)
        // We are already here, no action needed unless you want to scroll to top or refresh
        print("Already on Communities Screen");
        break;
      case 2: // Create
        print("Open Create Post/Workout Log Screen (Placeholder)");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening Create Screen (Placeholder)")));
        // Example: Navigator.pushNamed(context, '/create');
        break;
      case 3: // Chat
        print("Navigate to Chat Screen (Placeholder)");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Navigating to Chat (Placeholder)")));
        break;
      case 4: // Inbox
        print("Navigate to Inbox/Notifications Screen (Placeholder)");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Navigating to Inbox (Placeholder)")));
        // You might want to clear the notification count here if the user views them
        // setState(() { _notificationCount = 0; });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get theme for styling

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Community'),
        actions: [
          IconButton(icon: const Icon(Icons.search), tooltip: 'Search', onPressed: () { /* ... */ }),
          IconButton(icon: const Icon(Icons.filter_list), tooltip: 'Filter', onPressed: () { /* ... */ }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20), // Adjusted padding for BNB
          children: <Widget>[
            TopicChipsSection(
              title: "Explore by Topic",
              topics: _communityTopics,
              onTopicSelected: _handleTopicSelection,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Share your progress or ask a question"),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), textStyle: Theme.of(context).textTheme.labelLarge, foregroundColor: Theme.of(context).colorScheme.secondary, side: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5))),
                onPressed: () { /* ... */ },
              ),
            ),
            const SizedBox(height: 24),
            _buildPostListPlaceholder(),
            const SizedBox(height: 16),
            if (_sampleFitnessCommunities1.isNotEmpty)
              RecommendedCommunitiesListWidget(title: "Trending Fitness Groups", communities: _sampleFitnessCommunities1),
            const SizedBox(height: 16),
            if (_sampleFitnessCommunities2.isNotEmpty)
              RecommendedCommunitiesListWidget(title: "Niche Fitness Topics", communities: _sampleFitnessCommunities2),
            const SizedBox(height: 16),
            if (_sampleFitnessCommunities3.isNotEmpty)
              RecommendedCommunitiesListWidget(title: "For Your Goals", communities: _sampleFitnessCommunities3),
            const SizedBox(height: 16),
            if (_topChartFitnessCategories.isNotEmpty)
              TopChartsSectionWidget(
                title: "Community Top Charts",
                titleIcon: Icons.emoji_events_outlined,
                categories: _topChartFitnessCategories,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _onBottomNavItemTapped(2); /* Corresponds to Create tab */ },
        tooltip: 'Create New Post',
        // child: const Icon(Icons.add_comment_outlined), // Original
        child: const Icon(Icons.add), // More like the image
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // If you want it docked
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible and have labels
        // Use theme colors for consistency
        selectedItemColor: theme.colorScheme.secondary, // Active tab color
        unselectedItemColor: theme.unselectedWidgetColor, // Inactive tab color
        backgroundColor: theme.bottomAppBarTheme.color ?? theme.colorScheme.surface, // BNB background
        selectedFontSize: 12.0, // Adjust as needed
        unselectedFontSize: 12.0, // Adjust as needed
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            // icon: Icon(Icons.groups_outlined), // Alternative for communities
            // activeIcon: Icon(Icons.groups),
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: 'Communities',
          ),
          // "Create" item (often a placeholder if FAB is used, or a larger distinct item)
          // If using FABLocation.centerDocked, this item is often just a placeholder/spacer
          // or a custom designed middle tab. For simplicity, a regular item for now.
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, color: Colors.transparent), // Invisible if FAB is docked
            label: 'Create', // Label can still be there
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none, // Allow badge to overflow
              children: <Widget>[
                const Icon(Icons.notifications_outlined),
                if (_notificationCount > 0)
                  Positioned(
                    top: -4, // Adjust for precise positioning
                    right: -6, // Adjust for precise positioning
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8), // Make it circular
                        border: Border.all(color: theme.bottomAppBarTheme.color ?? theme.colorScheme.surface, width: 1.5) // Border to separate from icon
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16, // Minimum width for the badge
                        minHeight: 16, // Minimum height for the badge
                      ),
                      child: Center(
                        child: Text(
                          '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10, // Smaller font for badge
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack( // Same logic for active icon
              clipBehavior: Clip.none,
              children: <Widget>[
                const Icon(Icons.notifications), // Filled icon when active
                if (_notificationCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                     child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.bottomAppBarTheme.color ?? theme.colorScheme.surface, width: 1.5)
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          '$_notificationCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Inbox',
          ),
        ],
      ),
    );
  }

  Widget _buildPostListPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Activity", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (int i = 1; i <= 2; i++)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2), foregroundColor: Theme.of(context).colorScheme.secondary, child: Text(i.toString())),
                title: Text("My Workout Log - Day $i", style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text("Hit a new PR today! Feeling great. Here are the details...", style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () { /* ... */ },
              ),
            ),
          const SizedBox(height: 12),
          Center(child: Text('More posts will appear here.', style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}