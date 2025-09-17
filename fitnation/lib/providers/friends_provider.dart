import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/friends_api_service.dart';
import '../models/friend_models.dart';

// Providers for dependencies
final dioProvider = Provider<Dio>((ref) => Dio());
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

// Friends API Service Provider
final friendsApiServiceProvider = Provider<FriendsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return FriendsApiService(dio, secureStorage);
});

// Friends List State
final friendsProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
  final apiService = ref.watch(friendsApiServiceProvider);
  return FriendsNotifier(apiService);
});

class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  final FriendsApiService _apiService;

  FriendsNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> loadFriends() async {
    state = const AsyncValue.loading();
    try {
      final friends = await _apiService.getFriends();
      state = AsyncValue.data(friends);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void refresh() {
    loadFriends();
  }
}

// Friend Requests State
final friendRequestsProvider = StateNotifierProvider<FriendRequestsNotifier, AsyncValue<List<FriendRequest>>>((ref) {
  final apiService = ref.watch(friendsApiServiceProvider);
  return FriendRequestsNotifier(apiService);
});

class FriendRequestsNotifier extends StateNotifier<AsyncValue<List<FriendRequest>>> {
  final FriendsApiService _apiService;

  FriendRequestsNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> loadReceivedRequests() async {
    state = const AsyncValue.loading();
    try {
      final requests = await _apiService.getReceivedFriendRequests();
      state = AsyncValue.data(requests);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadSentRequests() async {
    state = const AsyncValue.loading();
    try {
      final requests = await _apiService.getSentFriendRequests();
      state = AsyncValue.data(requests);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<bool> acceptRequest(String requestId) async {
    try {
      await _apiService.handleFriendRequest(requestId, 'accepted');
      loadReceivedRequests(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRequest(String requestId) async {
    try {
      await _apiService.handleFriendRequest(requestId, 'rejected');
      loadReceivedRequests(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  void refresh() {
    loadReceivedRequests();
  }
}

// User Search State
final userSearchProvider = StateNotifierProvider<UserSearchNotifier, AsyncValue<List<UserSearchResult>>>((ref) {
  final apiService = ref.watch(friendsApiServiceProvider);
  return UserSearchNotifier(apiService);
});

class UserSearchNotifier extends StateNotifier<AsyncValue<List<UserSearchResult>>> {
  final FriendsApiService _apiService;

  UserSearchNotifier(this._apiService) : super(const AsyncValue.data([]));

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final users = await _apiService.searchUsers(query: query.trim());
      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<bool> sendFriendRequest(String receiverId) async {
    try {
      await _apiService.sendFriendRequest(receiverId);
      // Update the local state to reflect the sent request
      state.whenData((users) {
        final updatedUsers = users.map((user) {
          if (user.id == receiverId) {
            return UserSearchResult(
              id: user.id,
              username: user.username,
              firstName: user.firstName,
              lastName: user.lastName,
              profileImageUrl: user.profileImageUrl,
              friendshipStatus: 'request_sent',
            );
          }
          return user;
        }).toList();
        state = AsyncValue.data(updatedUsers);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearResults() {
    state = const AsyncValue.data([]);
  }
}

// Search Query State
final searchQueryProvider = StateProvider<String>((ref) => '');

// Loading States for actions
final sendingRequestProvider = StateProvider<Set<String>>((ref) => {});
final handlingRequestProvider = StateProvider<Set<String>>((ref) => {});
