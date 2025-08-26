import 'package:fitnation/Screens/Community/CreatePostScreen.dart';
import 'package:fitnation/models/ChallengePostModel.dart';
import 'package:fitnation/models/Exercise.dart';
import 'package:fitnation/models/User.dart';
import 'package:fitnation/models/WorkoutPostModel.dart';
import 'package:fitnation/widgets/community/PostCard.dart';
import 'package:fitnation/models/CommunityContentModel.dart';
// import 'package:fitnation/models/member_model.dart';
import 'package:fitnation/models/PostModel.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:fitnation/providers/data_providers.dart';

// Dummy data for group detail
Group _dummyGroupDetail = Group(
  id: 'g1',
  name: 'Strength Squad',
  description:
      'For all things strength training, powerlifting, and bodybuilding. Share your PBs! This is a longer description for the detail page to show how it might look. We encourage positive discussions and support for all members.',
  memberCount: 1203,
  postCount: 450,
  image:
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGd5bXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60',
  coverImage:
      'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8Z3ltJTIwY292ZXJ8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60',
  trending: true,
  categories: ['Weightlifting', 'Powerlifting', 'Fitness'],
  joined: true,
  createdAt: DateTime(2022, 3, 15),
  rules: [
    "Be respectful and supportive of all members",
    "No spam or self-promotion without approval",
    "Share evidence-based information when possible",
    "Keep discussions related to the group's focus",
  ],
); 

// If not, you can define _mockPosts here or import it properly.
List<Member> _dummyMembers = [
  Member(
    id: 'm1',
    username: 'alexfit',
    email: 'alexfit@example.com',
    userRole: UserRole.user,
    createdAt: DateTime(2022, 3, 20),
    updatedAt: DateTime(2022, 3, 20),
    displayName: 'Alex Fit',
    imageUrl: 'https://randomuser.me/api/portraits/men/10.jpg',
    communityRole: 'Admin',
    joinDate: DateTime(2022, 3, 20),
  ),
  Member(
    id: 'm2',
    username: 'sarahgains',
    email: 'sarahgains@example.com',
    userRole: UserRole.user,
    createdAt: DateTime(2022, 4, 1),
    updatedAt: DateTime(2022, 4, 1),
    displayName: 'Sarah Gains',
    imageUrl: 'https://randomuser.me/api/portraits/women/11.jpg',
    communityRole: 'Moderator',
    joinDate: DateTime(2022, 4, 1),
  ),
  Member(
    id: 'm3',
    username: 'mikemuscle',
    email: 'mikemuscle@example.com',
    userRole: UserRole.user,
    createdAt: DateTime(2022, 5, 15),
    updatedAt: DateTime(2022, 5, 15),
    displayName: 'Mike Muscle',
    imageUrl: 'https://randomuser.me/api/portraits/men/12.jpg',
    communityRole: 'Member',
    joinDate: DateTime(2022, 5, 15),
  ),
];

List<Post> _dummyGroupPosts = [
  Post(
    id: 'p_workout_1',
    userId: _dummyMembers[0].id,
    author: _dummyMembers[0], // Include author
    postType: [PostType.workout],
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    reactCount: 42,
    commentCount: 8,
workoutData: WorkoutPostData(
      workoutType: 'Strength Training',
      durationMinutes: 45,
      caloriesBurned: 320,
      exercises: <Exercise>[
        Exercise(
          exerciseId: 'bench-press',
          name: 'Bench Press',
          bodyParts: const ['chest'],
          equipments: const ['barbell'],
          targetMuscles: const ['pectorals'],
          secondaryMuscles: const [],
          instructions: const [],
          gifUrl: '',
        ),
        Exercise(
          exerciseId: 'squats',
          name: 'Squats',
          bodyParts: const ['legs'],
          equipments: const ['barbell'],
          targetMuscles: const ['quadriceps'],
          secondaryMuscles: const [],
          instructions: const [],
          gifUrl: '',
        ),
        Exercise(
          exerciseId: 'deadlifts',
          name: 'Deadlifts',
          bodyParts: const ['back'],
          equipments: const ['barbell'],
          targetMuscles: const ['glutes'],
          secondaryMuscles: const [],
          instructions: const [],
          gifUrl: '',
        ),
        Exercise(
          exerciseId: 'pull-ups',
          name: 'Pull-ups',
          bodyParts: const ['back'],
          equipments: const ['body weight'],
          targetMuscles: const ['lats'],
          secondaryMuscles: const [],
          instructions: const [],
          gifUrl: '',
        ),
      ],
      notes: null,
    ),
  ),
  // Challenge Post
  Post(
    id: 'p_challenge_1',
    userId: _dummyMembers[1].id,
    author: _dummyMembers[1], // Include author
    postType: [PostType.challenge], // Specify type
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    reactCount: 152,
    commentCount: 12,
    challengeData: ChallengePostData(
      title: '10K Steps Challenge',
      description:
          'Complete 10,000 steps every day for a week! Join us and boost your cardiovascular health.',
      startDate: DateTime(2024, 5, 25), // Example date
      durationDays: 7,
      coverImageUrl:
          'https://images.unsplash.com/photo-1543946207-39bd91e70c48?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c3RlcHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60', // Example cover image
      participantCount: 24,
    ),
  ),
 ];


class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isNotificationsEnabled = false;
  // In a real app, fetch groupData based on widget.groupId
  final Group groupData = _dummyGroupDetail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // TODO: Fetch actual group details using widget.groupId
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomScrollView(
        // Allows for AppBar collapsing effects
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0, // Height of the cover image
            floating: false,
            pinned: true, // AppBar stays visible
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  /* TODO: More options */
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        groupData.coverImage ??
                        'https://via.placeholder.com/800x200.png/1A1A1A/FFFFFF?text=No+Cover',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    // Gradient overlay
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
              // Title can be put here if you want it to collapse into the AppBar
              // title: Text(groupData.name, style: textTheme.titleLarge),
              // centerTitle: true, // Or false for left align
            ),
          ),

          // Community Info Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: groupData.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              groupData.name,
                              style: textTheme.headlineMedium?.copyWith(
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6.0,
                              runSpacing: 4.0,
                              children:
                                  groupData.categories
                                      .map(
                                        (category) =>
                                            Chip(label: Text(category)),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${groupData.memberCount} members',
                        style: textTheme.bodyMedium,
                      ),
                      
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.post_add_outlined,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${groupData.postCount} posts',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            /* TODO: Join/Leave logic */
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                groupData.joined
                                    ? AppColors.secondary
                                    : AppColors.primary,
                          ),
                          child: Text(
                            groupData.joined ? 'Joined' : 'Join Group',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          _isNotificationsEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_none_outlined,
                          color: AppColors.primary,
                        ),
                        tooltip: "Toggle Notifications",
                        onPressed: () {
                          setState(() {
                            _isNotificationsEnabled = !_isNotificationsEnabled;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Navigation
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              // Re-use the helper from CommunityGroupsScreen
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'About'),
                  Tab(text: 'Members'),
                ],
              ),
            ),
            pinned: true,
          ),

          // Tab Content (using SliverFillRemaining for full height or ListView for dynamic height)
          SliverFillRemaining(
            // This makes the TabBarView take remaining space
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsTab(context, groupData),
                _buildAboutTab(context, groupData),
                _buildMembersTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context, Group group) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (group.joined) // Show Create Post button only if joined
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Post in this Group'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePostScreen(communityId: group.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.8),
              ),
            ),
          ),
        ..._dummyGroupPosts.map((post) => PostCard(
          post: post,
          onAvatarTap: () {
            // Add avatar tap functionality if needed
          },
          onPostTap: () {
            // Add post tap functionality if needed
          },
        )).toList(),
        if (_dummyGroupPosts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text("No posts yet in this group."),
            ),
          ),
      ],
    );
  }

  Widget _buildAboutTab(BuildContext context, Group group) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(group.description, style: textTheme.bodyMedium),
          const SizedBox(height: 24),
          if (group.createdAt != null) ...[
            Text('Created On', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMMd().format(group.createdAt!),
              style: textTheme.bodyMedium,
            ), // e.g. March 15, 2022
            const SizedBox(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share Group'),
                onPressed: () {},
              ),
              TextButton.icon(
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Settings'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (group.rules != null && group.rules!.isNotEmpty) ...[
            Text('Community Rules', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            ...group.rules!.asMap().entries.map((entry) {
              int idx = entry.key;
              String rule = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${idx + 1}. ',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: Text(rule, style: textTheme.bodyMedium)),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersTab(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              /* TODO: Filter members */
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _dummyMembers.length,
            itemBuilder: (context, index) {
              final member = _dummyMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(member.imageUrl),
                ),
                title: Text(
                  member.displayName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.cardForeground,
                  ),
                ),
                subtitle: Text(member.communityRole, style: textTheme.bodyMedium),
                // trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: (){}),
              );
            },
          ),
        ),
      ],
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
    // Return the TabBar wrapped in a Container to give it a background color
    // so content doesn't show through as it scrolls under the sticky header.
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Match background
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    // Returning false means the delegate doesn't need to be rebuilt
    // unless the TabBar instance itself changes (which it shouldn't in this case).
    return false;
  }
}
