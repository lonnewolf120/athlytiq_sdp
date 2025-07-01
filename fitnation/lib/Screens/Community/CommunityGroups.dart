import 'package:fitnation/Screens/Community/CreateCommunity.dart';
import 'package:fitnation/Screens/Community/GroupDetailsScreen.dart';
import 'package:fitnation/widgets/community/GroupCard.dart';
import 'package:fitnation/models/CommunityContentModel.dart';
// import 'package:fitnation/widgets/ResponsiveCenter.dart'; // If you want to constrain the whole screen
import 'package:flutter/material.dart';

// Dummy data for groups
final List<Group> _dummyGroups = [
  Group(
    id: 'g1', name: 'Strength Squad', description: 'For all things strength training, powerlifting, and bodybuilding. Share your PBs!',
    memberCount: 1203, postCount: 450, image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGd5bXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60',
    trending: true, categories: ['Weightlifting', 'Powerlifting'], joined: false,
  ),
  Group(
    id: 'g2', name: 'Cardio Kings & Queens', description: 'Running, cycling, HIIT - if it gets your heart pumping, this is the place.',
    memberCount: 875, postCount: 302, image: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cnVubmluZ3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60',
    trending: false, categories: ['Running', 'HIIT'], joined: true,
  ),
  Group(
    id: 'g3', name: 'Yoga & Mindfulness', description: 'Find your zen. Share poses, meditation tips, and peaceful vibes.',
    memberCount: 1500, postCount: 600, image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8eW9nYXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60',
    trending: true, categories: ['Yoga', 'Meditation'], joined: false,
  ),
];


class CommunityGroupsScreen extends StatefulWidget {
  // If this screen is part of CommunityHomeScreen's TabBarView, it doesn't need its own Scaffold/AppBar
  // unless explicitly designed to. Here, I'll assume it's a standalone view for clarity or if navigated to directly.
  // If it's under the TabBar, remove the Scaffold and AppBar.
  const CommunityGroupsScreen({super.key});

  @override
  State<CommunityGroupsScreen> createState() => _CommunityGroupsScreenState();
}

class _CommunityGroupsScreenState extends State<CommunityGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _groupTabController;

  @override
  void initState() {
    super.initState();
    // Assuming this screen might be navigated to and have its own sub-tabs
    _groupTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _groupTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // If this screen is a top-level tab in CommunityHomeScreen, it won't have its own AppBar.
    // The header described (Logo, "Communities", + button) would be part of the CommunityHomeScreen's AppBar
    // and would change title/actions based on the selected main tab.
    // For this example, let's build it as if it could be a standalone view for clarity.
    // If it's part of CommunityHomeScreen's TabBarView, this Scaffold and AppBar are redundant.

    return Scaffold(
      // This AppBar would only be used if CommunityGroupsScreen is a standalone page.
      // If it's a tab under CommunityHome, that screen's AppBar handles the title and + button.
      // appBar: AppBar(
      //   title: Text("Communities", style: textTheme.titleLarge),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.add_circle_outline),
      //       onPressed: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityScreen()));
      //       },
      //     ),
      //   ],
      // ),
      body: NestedScrollView( // Good for scrollable content with a fixed search bar/tabs
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search communities...',
                    prefixIcon: const Icon(Icons.search),
                    // Using the theme's input decoration
                  ),
                  onChanged: (value) {
                    // TODO: Implement search logic
                  },
                ),
              ),
            ),
            SliverPersistentHeader( // For sticky tabs
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _groupTabController,
                  isScrollable: true, // If many tabs
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'My Groups'),
                    Tab(text: 'Popular'),
                    Tab(text: 'Trending'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _groupTabController,
          children: [
            _buildGroupList(_dummyGroups.where((g) => true).toList()), // All
            _buildGroupList(_dummyGroups.where((g) => g.joined).toList()), // My Groups
            _buildGroupList(_dummyGroups.orderByPopularity()), // Popular (needs sorting logic)
            _buildGroupList(_dummyGroups.where((g) => g.trending).toList()), // Trending
          ],
        ),
      ),
       floatingActionButton: FloatingActionButton( // This FAB is for "Create Community"
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityScreen()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGroupList(List<Group> groups) {
    if (groups.isEmpty) {
      return const Center(child: Text("No groups found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0), // Section padding
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return GroupCard(
          group: group,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id)),
            );
          },
        );
      },
    );
  }
}

// Helper for SliverPersistentHeader with TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Match background
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Dummy extension for sorting
extension GroupListSort on List<Group> {
  List<Group> orderByPopularity() {
    // Dummy: sort by member count
    List<Group> sorted = List.from(this);
    sorted.sort((a, b) => b.memberCount.compareTo(a.memberCount));
    return sorted;
  }
}