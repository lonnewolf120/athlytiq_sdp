import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.name}, ${place.locality}, ${place.country}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Failed to get address';
    }
  }

  static Future<mapbox.Point?> getLatLngFromAddress(String address) async {
    try {
      final locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return mapbox.Point(
          coordinates: mapbox.Position(loc.longitude, loc.latitude),
        );
      }
    } catch (_) {}
    return null;
  }
}
