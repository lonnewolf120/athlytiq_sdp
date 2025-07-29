import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Represents a single route's data
class RouteModel {
  final String title;
  final String distance;
  final String duration;
  final String difficulty;
  final Point location;

  RouteModel({
    required this.title,
    required this.distance,
    required this.duration,
    required this.difficulty,
    required this.location,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'distance': distance,
    'duration': duration,
    'difficulty': difficulty,
    'location': location.toJson(),
  };

  factory RouteModel.fromMap(Map<String, dynamic> map) => RouteModel(
    title: map['title'],
    distance: map['distance'],
    duration: map['duration'],
    difficulty: map['difficulty'],
    location: Point.fromJson(map['location']),
  );
}

/// Provider to hold the currently selected route
final selectedRouteProvider = StateProvider<RouteModel?>((ref) => null);

/// Provider to manage recent routes (basic history)
final recentRoutesProvider =
    StateNotifierProvider<RecentRoutesNotifier, List<RouteModel>>(
      (ref) => RecentRoutesNotifier(),
    );

class RecentRoutesNotifier extends StateNotifier<List<RouteModel>> {
  RecentRoutesNotifier() : super([]);

  void addRoute(RouteModel route) {
    // Avoid duplicates by title
    state = [
      route,
      ...state.where((r) => r.title != route.title),
    ].take(5).toList(); // Keep last 5 routes
  }

  void clearRoutes() {
    state = [];
  }
}
