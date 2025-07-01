// import 'package:mapbox_gl/mapbox_gl.dart'; // For LatLng
import 'package:fitnation/models/User.dart';

// Simple LatLng class if you don't want to use an external package
class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

// Corresponds to RIDE_ACTIVITY_TYPE ENUM in SQL
enum RideActivityType {
  mountain,
  road,
  tandem,
  cyclocross,
  running,
  hiking,
  other_workout,
}

class RideActivity {
  final String id;
  final String organizerUserId; // ID of the user who organized
  final User? organizer; // Optionally fetch the full User object
  final String name;
  final String? description;
  final String? imageUrl;
  final double? distanceKm;
  final int? elevationMeters;
  final RideActivityType type;
  final List<LatLng>? routeCoordinates; // Parsed from JSONB
  final String? locationName;
  final String? parkName;
  final DateTime? startTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<User>? participants; // List of users participating
  final int? participantCount; // Could be fetched or derived

  RideActivity({
    required this.id,
    required this.organizerUserId,
    this.organizer,
    required this.name,
    this.description,
    this.imageUrl,
    this.distanceKm,
    this.elevationMeters,
    required this.type,
    this.routeCoordinates,
    this.locationName,
    this.parkName,
    this.startTime,
    required this.createdAt,
    required this.updatedAt,
    this.participants,
    this.participantCount,
  });

  // UI Helpers
  String get distanceDisplay =>
      distanceKm != null ? "${distanceKm?.toStringAsFixed(0)} km" : "N/A";
  String get elevationDisplay =>
      elevationMeters != null ? "${elevationMeters} m" : "N/A";
  String get typeDisplay {
    switch (type) {
      case RideActivityType.mountain:
        return "Mountain";
      case RideActivityType.road:
        return "Road";
      case RideActivityType.tandem:
        return "Tandem";
      case RideActivityType.cyclocross:
        return "Cyclocross";
      case RideActivityType.running:
        return "Running";
      case RideActivityType.hiking:
        return "Hiking";
      case RideActivityType.other_workout:
        return "Workout";
    }
  }

  factory RideActivity.fromJson(Map<String, dynamic> json) {
    List<LatLng>? coords;
    if (json['route_coordinates'] != null) {
      // Assuming route_coordinates is stored as a list of {"lat": ..., "lng": ...} objects
      // Adjust parsing based on your actual JSONB structure (e.g., GeoJSON)
      var rawCoords = json['route_coordinates'] as List<dynamic>;
      coords =
          rawCoords
              .map(
                (c) => LatLng(
                  (c['lat'] as num).toDouble(),
                  (c['lng'] as num).toDouble(),
                ),
              )
              .toList();
    }

    return RideActivity(
      id: json['id'] as String,
      organizerUserId: json['organizer_user_id'] as String,
      organizer:
          json['organizer'] != null
              ? User.fromJson(json['organizer'] as Map<String, dynamic>)
              : null,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      elevationMeters: json['elevation_meters'] as int?,
      type: RideActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => RideActivityType.other_workout,
      ),
      routeCoordinates: coords,
      locationName: json['location_name'] as String?,
      parkName: json['park_name'] as String?,
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'] as String)
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((p) => User.fromJson(p as Map<String, dynamic>))
              .toList(),
      participantCount:
          json['participant_count'] as int? ??
          (json['participants'] as List<dynamic>?)?.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizer_user_id': organizerUserId,
      'organizer': organizer?.toJson(),
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'distance_km': distanceKm,
      'elevation_meters': elevationMeters,
      'type': type.toString().split('.').last,
      'route_coordinates':
          routeCoordinates
              ?.map((c) => {'lat': c.latitude, 'lng': c.longitude})
              .toList(),
      'location_name': locationName,
      'park_name': parkName,
      'start_time': startTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'participants': participants?.map((p) => p.toJson()).toList(),
      'participant_count': participantCount,
    };
  }
}
