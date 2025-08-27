import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';
import '../providers/data_providers.dart';
import '../api/API_Services.dart';

class ChallengeService {
  final ApiService _apiService;

  ChallengeService(this._apiService);

  
  
  
  Future<ChallengeListResponse> getChallenges({
    int skip = 0,
    int limit = 20,
    String? activityType,
    String? status,
    String? search,
  }) async {
    String endpoint = '/challenges?skip=$skip&limit=$limit';
    
    if (activityType != null && activityType != 'All') {
      endpoint += '&activity_type=${activityType.toLowerCase()}';
    }
    if (status != null) endpoint += '&status=$status';
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=${Uri.encodeComponent(search)}';
    }

    try {
      final response = await _apiService.get(endpoint);
      return ChallengeListResponse.fromJson(response.data);
    } catch (e) {
      print('Error in getChallenges: $e');
      rethrow;
    }
  }  
  Future<Challenge> getChallenge(String challengeId) async {
    try {
      final response = await _apiService.get('/challenges/$challengeId');
      return Challenge.fromJson(response.data);
    } catch (e) {
      print('Error in getChallenge: $e');
      rethrow;
    }
  }

  
  Future<Challenge> createChallenge(ChallengeCreate challengeData) async {
    try {
      final response = await _apiService.post(
        '/challenges',
        challengeData.toJson(),
      );
      return Challenge.fromJson(response.data);
    } catch (e) {
      print('Error in createChallenge: $e');
      rethrow;
    }
  }

  
  Future<ChallengeParticipant> joinChallenge(String challengeId) async {
    try {
      final response = await _apiService.post(
        '/challenges/$challengeId/join',
        {},
      );
      return ChallengeParticipant.fromJson(response.data);
    } catch (e) {
      print('Error in joinChallenge: $e');
      rethrow;
    }
  }

  
  Future<void> leaveChallenge(String challengeId) async {
    try {
      await _apiService.post(
        '/challenges/$challengeId/leave',
        {},
      );
    } catch (e) {
      print('Error in leaveChallenge: $e');
      rethrow;
    }
  }

  
  Future<ChallengeParticipant> updateProgress(
    String challengeId,
    Map<String, dynamic> progressData,
  ) async {
    try {
      final response = await _apiService.put(
        '/challenges/$challengeId/progress',
        progressData,
      );
      return ChallengeParticipant.fromJson(response.data);
    } catch (e) {
      print('Error in updateProgress: $e');
      rethrow;
    }
  }

  
  Future<ChallengeListResponse> getMyChallenges({
    int skip = 0,
    int limit = 20,
    String? participantStatus,
  }) async {
    String endpoint = '/my-challenges?skip=$skip&limit=$limit';
    
    if (participantStatus != null) endpoint += '&participant_status=$participantStatus';

    try {
      final response = await _apiService.get(endpoint);
      return ChallengeListResponse.fromJson(response.data);
    } catch (e) {
      print('Error in getMyChallenges: $e');
      rethrow;
    }
  }

  
  Future<ChallengeListResponse> getMyCreatedChallenges({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/my-created-challenges?skip=$skip&limit=$limit',
      );
      return ChallengeListResponse.fromJson(response.data);
    } catch (e) {
      print('Error in getMyCreatedChallenges: $e');
      rethrow;
    }
  }

  Future<List<ChallengeParticipant>> getChallengeParticipants(
    String challengeId, {
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.get(
        '/challenges/$challengeId/participants?skip=$skip&limit=$limit',
      );
      
      final participantsData = response.data['participants'] as List;
      return participantsData.map((json) => ChallengeParticipant.fromJson(json)).toList();
    } catch (e) {
      print('Error in getChallengeParticipants: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getChallengeStats() async {
    try {
      final response = await _apiService.get('/challenge-stats');
      return response.data;
    } catch (e) {
      print('Error in getChallengeStats: $e');
      rethrow;
    }
  }
}

final challengeServiceProvider = Provider<ChallengeService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ChallengeService(apiService);
});
