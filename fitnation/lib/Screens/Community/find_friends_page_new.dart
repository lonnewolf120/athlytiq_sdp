import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/providers/friends_provider.dart';
import 'package:fitnation/models/friend_models.dart';

class FindFriendsPage extends ConsumerStatefulWidget {
  const FindFriendsPage({super.key});

  @override
  ConsumerState<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends ConsumerState<FindFriendsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load friend requests when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendRequestsProvider.notifier).loadReceivedRequests();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    if (query.trim().isNotEmpty) {
      ref.read(userSearchProvider.notifier).searchUsers(query);
    } else {
      ref.read(userSearchProvider.notifier).clearResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            "Find Friends",
            style: TextStyle(color: AppColors.darkPrimaryText),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.darkPrimaryText,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: AppColors.darkPrimaryText,
            unselectedLabelColor: AppColors.darkHintText,
            indicatorColor: AppColors.secondary,
            tabs: [
              Tab(text: "Search Users"),
              Tab(text: "Friend Requests")
            ],
          ),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: AppColors.darkPrimaryText),
                decoration: InputDecoration(
                  hintText: "Search for users...",
                  hintStyle: const TextStyle(color: AppColors.darkHintText),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.darkIcon,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.darkIcon),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.darkInputBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Tab content
            const Expanded(
              child: TabBarView(
                children: [
                  SearchUsersTab(),
                  FriendRequestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchUsersTab extends ConsumerWidget {
  const SearchUsersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(userSearchProvider);
    final sendingRequests = ref.watch(sendingRequestProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return searchResults.when(
      data: (users) {
        if (searchQuery.trim().isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: AppColors.darkHintText,
                ),
                SizedBox(height: 16),
                Text(
                  "Search for users to add as friends",
                  style: TextStyle(
                    color: AppColors.darkHintText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: AppColors.darkHintText,
                ),
                SizedBox(height: 16),
                Text(
                  "No users found",
                  style: TextStyle(
                    color: AppColors.darkHintText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final user = users[index];
            final isSendingRequest = sendingRequests.contains(user.id);
            
            return Card(
              color: AppColors.darkSurface,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  backgroundImage: user.profileImageUrl != null 
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Text(
                          user.displayName.isNotEmpty 
                              ? user.displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  user.displayName,
                  style: const TextStyle(
                    color: AppColors.darkPrimaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '@${user.username}',
                  style: const TextStyle(
                    color: AppColors.darkHintText,
                  ),
                ),
                trailing: _buildActionButton(context, ref, user, isSendingRequest),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              "Error: $error",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final query = ref.read(searchQueryProvider);
                if (query.trim().isNotEmpty) {
                  ref.read(userSearchProvider.notifier).searchUsers(query);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, UserSearchResult user, bool isLoading) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.secondary,
        ),
      );
    }

    switch (user.friendshipStatus) {
      case 'none':
        return ElevatedButton(
          onPressed: () => _sendFriendRequest(context, ref, user),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
          child: const Text("Add Friend"),
        );
      case 'request_sent':
      case 'pending':
        return const Chip(
          label: Text("Pending"),
          backgroundColor: AppColors.darkHintText,
          labelStyle: TextStyle(color: Colors.white),
        );
      case 'friends':
        return const Chip(
          label: Text("Friends"),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _sendFriendRequest(BuildContext context, WidgetRef ref, UserSearchResult user) async {
    // Add to sending state
    final sendingSet = {...ref.read(sendingRequestProvider)};
    sendingSet.add(user.id);
    ref.read(sendingRequestProvider.notifier).state = sendingSet;

    try {
      final success = await ref.read(userSearchProvider.notifier).sendFriendRequest(user.id);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Friend request sent to ${user.displayName}"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send friend request"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Remove from sending state
      final sendingSet = {...ref.read(sendingRequestProvider)};
      sendingSet.remove(user.id);
      ref.read(sendingRequestProvider.notifier).state = sendingSet;
    }
  }
}

class FriendRequestsTab extends ConsumerWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(friendRequestsProvider);
    final handlingRequests = ref.watch(handlingRequestProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 64,
                  color: AppColors.darkHintText,
                ),
                SizedBox(height: 16),
                Text(
                  "No friend requests",
                  style: TextStyle(
                    color: AppColors.darkHintText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.read(friendRequestsProvider.notifier).loadReceivedRequests();
          },
          child: ListView.builder(
            itemCount: requests.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final request = requests[index];
              final isHandling = handlingRequests.contains(request.id);
              
              return Card(
                color: AppColors.darkSurface,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    backgroundImage: request.senderProfileImageUrl != null 
                        ? NetworkImage(request.senderProfileImageUrl!)
                        : null,
                    child: request.senderProfileImageUrl == null
                        ? Text(
                            request.senderDisplayName.isNotEmpty 
                                ? request.senderDisplayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    request.senderDisplayName,
                    style: const TextStyle(
                      color: AppColors.darkPrimaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${request.senderUsername}',
                        style: const TextStyle(color: AppColors.darkHintText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Sent ${_formatDate(request.createdAt)}",
                        style: const TextStyle(
                          color: AppColors.darkHintText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: isHandling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _handleRequest(context, ref, request, 'accepted'),
                              icon: const Icon(Icons.check, color: Colors.green),
                              tooltip: "Accept",
                            ),
                            IconButton(
                              onPressed: () => _handleRequest(context, ref, request, 'rejected'),
                              icon: const Icon(Icons.close, color: Colors.red),
                              tooltip: "Reject",
                            ),
                          ],
                        ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              "Error loading friend requests: $error",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(friendRequestsProvider.notifier).loadReceivedRequests();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequest(BuildContext context, WidgetRef ref, FriendRequest request, String action) async {
    // Add to handling state
    final handlingSet = {...ref.read(handlingRequestProvider)};
    handlingSet.add(request.id);
    ref.read(handlingRequestProvider.notifier).state = handlingSet;

    try {
      final success = action == 'accepted'
          ? await ref.read(friendRequestsProvider.notifier).acceptRequest(request.id)
          : await ref.read(friendRequestsProvider.notifier).rejectRequest(request.id);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'accepted' 
                  ? "Friend request accepted!" 
                  : "Friend request rejected"
            ),
            backgroundColor: action == 'accepted' ? Colors.green : Colors.orange,
          ),
        );
        // Refresh friends list if accepted
        if (action == 'accepted') {
          ref.read(friendsProvider.notifier).refresh();
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to ${action == 'accepted' ? 'accept' : 'reject'} friend request"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Remove from handling state
      final handlingSet = {...ref.read(handlingRequestProvider)};
      handlingSet.remove(request.id);
      ref.read(handlingRequestProvider.notifier).state = handlingSet;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
    } else {
      return "Just now";
    }
  }
}
