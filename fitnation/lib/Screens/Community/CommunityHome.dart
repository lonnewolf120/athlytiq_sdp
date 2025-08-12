import 'package:fitnation/Screens/Community/CreatePostScreen.dart';
import 'package:fitnation/Screens/Community/messages_page.dart';
import 'package:fitnation/widgets/community/PostCard.dart';
import 'package:fitnation/widgets/community/StoryBubble.dart';
import 'package:fitnation/models/CommunityContentModel.dart';
import 'package:fitnation/providers/data_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:fitnation/widgets/common/CustomAppBar.dart'; // Import CustomAppBar
// import 'package:intl/intl.dart'; // For date formatting

class CommunityHomeScreen extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  const CommunityHomeScreen({super.key});

  @override
  ConsumerState<CommunityHomeScreen> createState() =>
      _CommunityHomeScreenState(); // Change state type
}

class _CommunityHomeScreenState
    extends
        ConsumerState<CommunityHomeScreen> // Change state type
    with TickerProviderStateMixin<CommunityHomeScreen> {
  // Corrected mixin type
  late TabController _tabController;
  List<Story> _userStories = []; // Make stories mutable

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userStories = List.from(dummyStories); // Initialize with dummy data
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Feed',
        showMenuButton: false, // Disable menu button
        showProfileMenu: true, // Enable profile menu
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePostScreen(communityId: null),
                ),
              ); // Pass communityId if creating from specific group
            },
          ),

          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.redAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessagesPage()),
              ); // Pass communityId if creating from specific group
            },
          ),
        ],
      ),
      body: _buildFeedTab(context),
    );
  }

  Widget _buildFeedTab(BuildContext context) {
    final postsAsyncValue = ref.watch(
      postsFeedProvider,
    ); // Watch the posts provider

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the posts provider
        ref.refresh(postsFeedProvider);
        // You might want to await a future that completes when the refresh is done,
        // but for FutureProvider, ref.refresh itself triggers the reload.
        // If postsFeedProvider were a StateNotifierProvider, you'd call a method
        // on your notifier that returns a Future.
        // For simplicity, we'll assume the refresh is quick or the UI handles
        // the loading state appropriately.
        await ref.read(
          postsFeedProvider.future,
        ); // Ensure the refresh completes
      },
      child: ListView(
        children: [
          _buildStoriesSection(context),
          const SizedBox(height: 16), // Margin between sections
          // Post Cards - Use postsAsyncValue to handle loading/error/data
          postsAsyncValue.when(
            data: (posts) {
              if (posts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("No posts yet. Be the first to share!"),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Section padding
                child: ListView.builder(
                  shrinkWrap: true, // Important for ListView inside ListView
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable its own scrolling
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    // Each PostCard should handle its own padding if it's a Card
                    return PostCard(post: post);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading posts: $error'),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection(BuildContext context) {
    return Container(
      height: 120, // Adjust height as needed
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _userStories.length,
        itemBuilder: (context, index) {
          final story = _userStories[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16.0 : 8.0,
              right: index == _userStories.length - 1 ? 16.0 : 0.0,
            ), // Comma is now definitely here.
            child: StoryBubble(
              story: story,
              onYourStoryTap: (newContent) {
                if (newContent != null) {
                  setState(() {
                    final yourStoryIndex = _userStories.indexWhere(
                      (s) => s.isYourStory,
                    );
                    if (yourStoryIndex != -1) {
                      final currentStory = _userStories[yourStoryIndex];
                      final updatedContent = List<StoryContentItem>.from(
                        currentStory.storyContent ?? [],
                      );
                      updatedContent.add(newContent);
                      _userStories[yourStoryIndex] = Story(
                        id: currentStory.id,
                        name: currentStory.name,
                        image: currentStory.image,
                        isYourStory: currentStory.isYourStory,
                        storyContent: updatedContent,
                      );
                    } else {
                      _userStories.add(
                        Story(
                          id: 's_new_${DateTime.now().millisecondsSinceEpoch}',
                          name: 'Your Story',
                          isYourStory: true,
                          image: null,
                          storyContent: [newContent],
                        ),
                      );
                    }
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
