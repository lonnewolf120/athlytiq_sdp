import 'package:fitnation/Screens/Community/CreateCommunity.dart';
import 'package:fitnation/Screens/Community/GroupDetailsScreen.dart';
import 'package:fitnation/Screens/Community/ChallengesScreen.dart';
import 'package:fitnation/widgets/community/GroupCard.dart';
import 'package:fitnation/models/CommunityContentModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/data_providers.dart';
import 'package:flutter/material.dart';
import 'package:fitnation/widgets/common/CustomSliverAppBar.dart';

// Removed local dummy groups; now loaded from backend

class CommunityGroupsScreen extends ConsumerStatefulWidget {
  const CommunityGroupsScreen({super.key});

  @override
  ConsumerState<CommunityGroupsScreen> createState() => _CommunityGroupsScreenState();
}

class _CommunityGroupsScreenState extends ConsumerState<CommunityGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _groupTabController;
  late Future<List<Group>> _allGroupsFuture;
  late Future<List<Group>> _myGroupsFuture;

  @override
  void initState() {
    super.initState();
    _groupTabController = TabController(length: 3, vsync: this);
    _groupTabController.addListener(() {
      setState(() {});
    });
    final api = ref.read(apiServiceProvider);
    _allGroupsFuture = api.getCommunities(skip: 0, limit: 50);
    _myGroupsFuture = api.getCommunities(skip: 0, limit: 50, my: true);
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
                      'All',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'My Groups',
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
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: Theme.of(
            //           context,
            //         ).colorScheme.surface.withOpacity(0.3),
            //         borderRadius: BorderRadius.circular(25),
            //         border: Border.all(
            //           color: Colors.grey.withOpacity(0.3),
            //           width: 1,
            //         ),
            //       ),
            //       child: TextField(
            //         decoration: InputDecoration(
            //           hintText: 'Search',
            //           prefixIcon: Icon(
            //             Icons.search,
            //             color: Theme.of(
            //               context,
            //             ).colorScheme.onSurface.withOpacity(0.6),
            //           ),
            //           border: InputBorder.none,
            //           contentPadding: const EdgeInsets.symmetric(
            //             horizontal: 16,
            //             vertical: 12,
            //           ),
            //           hintStyle: TextStyle(
            //             color: Theme.of(
            //               context,
            //             ).colorScheme.onSurface.withOpacity(0.6),
            //           ),
            //         ),
            //         style: TextStyle(
            //           color: Theme.of(context).colorScheme.onSurface,
            //         ),
            //         onChanged: (value) {},
            //       ),
            //     ),
            //   ),
            // ),
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
            _buildGroupsFromBackend(_allGroupsFuture),
            _buildGroupsFromBackend(_myGroupsFuture),
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

  Widget _buildGroupsFromBackend(Future<List<Group>> future) {
    return FutureBuilder<List<Group>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load communities: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final groups = snapshot.data ?? const <Group>[];
        return _buildGroupList(groups);
      },
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
                builder: (_) => GroupDetailScreen(groupId: group.id, initialGroup: group),
              ),
            );
          },
          onJoinToggle: () async {
            final api = ref.read(apiServiceProvider);
            try {
              if (group.joined) {
                final ok = await api.leaveCommunity(group.id);
                if (ok) {
                  setState(() {
                    groups[index] = Group(
                      id: group.id,
                      name: group.name,
                      description: group.description,
                      memberCount: (group.memberCount > 0) ? group.memberCount - 1 : 0,
                      postCount: group.postCount,
                      image: group.image,
                      trending: group.trending,
                      categories: group.categories,
                      joined: false,
                      coverImage: group.coverImage,
                      createdAt: group.createdAt,
                      rules: group.rules,
                    );
                  });
                }
              } else {
                final ok = await api.joinCommunity(group.id);
                if (ok) {
                  setState(() {
                    groups[index] = Group(
                      id: group.id,
                      name: group.name,
                      description: group.description,
                      memberCount: group.memberCount + 1,
                      postCount: group.postCount,
                      image: group.image,
                      trending: group.trending,
                      categories: group.categories,
                      joined: true,
                      coverImage: group.coverImage,
                      createdAt: group.createdAt,
                      rules: group.rules,
                    );
                  });
                }
              }
              // Refresh the futures to keep tabs in sync
              final api2 = ref.read(apiServiceProvider);
              setState(() {
                _allGroupsFuture = api2.getCommunities(skip: 0, limit: 50);
                _myGroupsFuture = api2.getCommunities(skip: 0, limit: 50, my: true);
              });
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update membership: $e')),
                );
              }
            }
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
