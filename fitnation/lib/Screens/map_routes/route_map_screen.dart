import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:map_routes/themes/colors.dart';
import 'package:map_routes/themes/text_styles.dart';

class RouteMapScreen extends StatefulWidget {
  final Point destination;

  const RouteMapScreen({super.key, required this.destination});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late MapboxMap mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Route Map',
          style: AppTextStyles.lightHeadline,
        ),
        backgroundColor: AppColors.primary,
      ),
      body: MapWidget(
        key: const ValueKey("route-map"),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        cameraOptions: CameraOptions(
          center: widget.destination,
          zoom: 14.0,
        ),
        textureView: true,
        resourceOptions: ResourceOptions(
          accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN']!,
        ),
        onMapCreated: (controller) {
          mapboxMap = controller;
          mapboxMap.flyTo(
            CameraOptions(center: widget.destination, zoom: 14),
            MapAnimationOptions(duration: Duration(milliseconds: 1500)),
          );
        },
      ),
    );
  }
}
