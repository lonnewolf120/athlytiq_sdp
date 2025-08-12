import 'package:fitnation/Screens/Community/CreateCommunity.dart';
import 'package:fitnation/Screens/Community/GroupDetailsScreen.dart';
import 'package:fitnation/Screens/Community/ChallengesScreen.dart';
import 'package:fitnation/Screens/Community/find_friends_page.dart';
import 'package:fitnation/widgets/community/GroupCard.dart';
import 'package:fitnation/models/CommunityContentModel.dart';
import 'package:flutter/material.dart';
import 'package:fitnation/widgets/common/CustomSliverAppBar.dart';

final List<Group> _dummyGroups = [
  Group(
    id: 'g1',
    name: 'Strength Squad',
    description:
        'For all things strength training, powerlifting, and bodybuilding. Share your PBs!',
    memberCount: 1203,
    postCount: 450,
    image:
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGd5bXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60',
    trending: true,
    categories: ['Weightlifting', 'Powerlifting'],
    joined: false,
  ),
  Group(
    id: 'g2',
    name: 'Cardio Kings & Queens',
    description:
        'Running, cycling, HIIT - if it gets your heart pumping, this is the place.',
    memberCount: 875,
    postCount: 302,
    image:
        'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cnVubmluZ3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60',
    trending: false,
    categories: ['Running', 'HIIT'],
    joined: true,
  ),
  Group(
    id: 'g3',
    name: 'Yoga & Mindfulness',
    description:
        'Find your zen. Share poses, meditation tips, and peaceful vibes.',
    memberCount: 1500,
    postCount: 600,
    image:
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8eW9nYXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60',
    trending: true,
    categories: ['Yoga', 'Meditation'],
    joined: false,
  ),
];

class CommunityGroupsScreen extends StatefulWidget {
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
    _groupTabController = TabController(length: 3, vsync: this);
    _groupTabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _groupTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomSliverAppBar(
              title: 'Community & Challenges',
              showMenuButton: false, // Disable menu button
              showProfileMenu: true, // Enable profile menu
              bottom: TabBar(
                controller: _groupTabController,
                tabs: const [
                  Tab(
                    child: Text(
                      'Groups',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Buddies',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Challenges',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                indicator: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.circular(4),
                ),
                indicatorColor: Colors.white,
                indicatorWeight: 2,
                unselectedLabelColor: const Color.fromARGB(226, 70, 59, 59),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.3),
                    // borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onChanged: (value) {},
                  ),
                ),
              ),
            ),
            // SliverPersistentHeader(
            //   delegate: _SliverAppBarDelegate(
            //     TabBar(
            //       controller: _groupTabController,
            //       isScrollable: false,
            //       tabs: const [
            //         Tab(text: 'All'),
            //         Tab(text: 'My Groups'),
            //         Tab(text: 'Challenges'),
            //       ],
            //     ),
            //   ),
            //   pinned: true,
            // ),
          ];
        },
        body: TabBarView(
          controller: _groupTabController,
          children: [
            _buildGroupList(_dummyGroups.where((g) => true).toList()),
            FindFriendsPage(),
            // _buildGroupList(_dummyGroups.where((g) => g.joined).toList()),
            ChallengesScreen(),
          ],
        ),
      ),
      floatingActionButton:
          _groupTabController.index != 2
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateCommunityScreen(),
                    ),
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildGroupList(List<Group> groups) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No groups found.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return GroupCard(
          group: group,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupDetailScreen(groupId: group.id),
              ),
            );
          },
        );
      },
    );
  }
}

extension GroupListSort on List<Group> {
  List<Group> orderByPopularity() {
    List<Group> sorted = List.from(this);
    sorted.sort((a, b) => b.memberCount.compareTo(a.memberCount));
    return sorted;
  }
}
