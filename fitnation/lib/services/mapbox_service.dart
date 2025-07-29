import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapboxService {
  static final String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  static const String styleUrl = MapboxStyles.MAPBOX_STREETS;

  /// Get the initial camera position based on coordinates
  static CameraOptions getInitialCameraPosition({
    required double lat,
    required double lng,
  }) {
    return CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: 14.0,
    );
  }

  /// Draw route polyline on map using Mapbox Directions API
  static Future<void> drawRoute({
    required MapboxMap map,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'walking', // Can be 'driving', 'walking', 'cycling'
  }) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/$mode/$originLng,$originLat;$destLng,$destLat?geometries=geojson&access_token=$accessToken';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;

        final route = coords.map<Point>((c) {
          return Point(coordinates: Position(c[0].toDouble(), c[1].toDouble()));
        }).toList();

        final lineManager =
            await map.annotations.createPolylineAnnotationManager();
        await lineManager.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: route).toJson(),
            lineColor: "#007AFF",
            lineWidth: 5.0,
            lineOpacity: 0.8,
          ),
        );
      } else {
        print("Mapbox API error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to draw route: $e");
    }
  }

  /// Forward Geocoding: Address to Mapbox Point
  static Future<Point?> forwardGeocode(String address) async {
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$address.json?access_token=$accessToken',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'];
        return Point(coordinates: Position(coords[0], coords[1]));
      }
    } catch (e) {
      print('Forward geocoding error: $e');
    }
    return null;
  }

  /// Reverse Geocoding: Coordinates to address string
  static Future<String?> reverseGeocode(double lat, double lng) async {
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json?access_token=$accessToken',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['features'][0]['place_name'];
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
    return null;
  }
}
