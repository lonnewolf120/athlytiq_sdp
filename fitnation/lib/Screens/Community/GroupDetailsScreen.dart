import 'package:fitnation/Screens/Community/CreatePostScreen.dart';
// Removed unused imports after switching to backend-loaded posts
import 'package:fitnation/models/User.dart';
import 'package:fitnation/widgets/community/PostCard.dart';
import 'package:fitnation/models/CommunityContentModel.dart';
// import 'package:fitnation/models/member_model.dart';
import 'package:fitnation/models/PostModel.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:fitnation/providers/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Removed dummy posts; posts are now loaded from backend per community


class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  final Group? initialGroup; // optional for instant UI
  const GroupDetailScreen({super.key, required this.groupId, this.initialGroup});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isNotificationsEnabled = false;
  Group? groupData; // loaded from backend
  bool _loading = true;
  // String? _error; // Unused; keep for future error surface if needed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Seed with initial group, then fetch details
    groupData = widget.initialGroup;
    _fetchDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
    final g = groupData ?? widget.initialGroup ?? _dummyGroupDetail;

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
                        g.coverImage ??
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
                          imageUrl: g.image,
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
                              g.name,
                              style: textTheme.headlineMedium?.copyWith(
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6.0,
                              runSpacing: 4.0,
                              children:
                                  g.categories
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
                        '${g.memberCount} members',
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
                        '${g.postCount} posts',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  final api = ref.read(apiServiceProvider);
                                  setState(() => _loading = true);
                                  try {
                                    final currentlyJoined = (groupData ?? widget.initialGroup ?? _dummyGroupDetail).joined;
                                    if (currentlyJoined) {
                                      final ok = await api.leaveCommunity((groupData ?? widget.initialGroup ?? _dummyGroupDetail).id);
                                      if (ok) {
                                        setState(() {
                                          final g = groupData ?? widget.initialGroup;
                                          if (g != null) {
                                            groupData = Group(
                                              id: g.id,
                                              name: g.name,
                                              description: g.description,
                                              memberCount: (g.memberCount > 0) ? g.memberCount - 1 : 0,
                                              postCount: g.postCount,
                                              image: g.image,
                                              trending: g.trending,
                                              categories: g.categories,
                                              joined: false,
                                              coverImage: g.coverImage,
                                              createdAt: g.createdAt,
                                              rules: g.rules,
                                            );
                                          }
                                        });
                                      }
                                    } else {
                                      final ok = await api.joinCommunity((groupData ?? widget.initialGroup ?? _dummyGroupDetail).id);
                                      if (ok) {
                                        setState(() {
                                          final g = groupData ?? widget.initialGroup;
                                          if (g != null) {
                                            groupData = Group(
                                              id: g.id,
                                              name: g.name,
                                              description: g.description,
                                              memberCount: g.memberCount + 1,
                                              postCount: g.postCount,
                                              image: g.image,
                                              trending: g.trending,
                                              categories: g.categories,
                                              joined: true,
                                              coverImage: g.coverImage,
                                              createdAt: g.createdAt,
                                              rules: g.rules,
                                            );
                                          }
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to update membership: $e')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _loading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                g.joined ? AppColors.secondary : AppColors.primary,
                          ),
                          child: Text(
                            g.joined ? 'Joined' : 'Join Group',
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
                _buildPostsTab(context, g),
                _buildAboutTab(context, g),
                _buildMembersTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _loading = true;
      // _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final details = await api.getCommunityById(widget.groupId, fallback: groupData);
      setState(() {
        groupData = details;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        // _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildPostsTab(BuildContext context, Group group) {
    final api = ref.watch(apiServiceProvider);
    return FutureBuilder<List<Post>>(
      future: api.getCommunityPosts(group.id, skip: 0, limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Failed to load posts: ${snapshot.error}'),
            ),
          );
        }
        final posts = snapshot.data ?? const <Post>[];
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (group.joined)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Create Post in this Group'),
                  onPressed: () async {
                    final created = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreatePostScreen(communityId: group.id),
                      ),
                    );
                    if (created == true && mounted) setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.8),
                  ),
                ),
              ),
            ...posts.map((post) => PostCard(post: post)).toList(),
            if (posts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No posts yet in this group.'),
                ),
              ),
          ],
        );
      },
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
