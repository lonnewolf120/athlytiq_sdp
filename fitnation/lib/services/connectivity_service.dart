import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged.map((results) => results.first);

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

class NoInternetException implements Exception {
  final String message;
  NoInternetException([this.message = "No internet connection"]);

  @override
  String toString() => "NoInternetException: $message";
}