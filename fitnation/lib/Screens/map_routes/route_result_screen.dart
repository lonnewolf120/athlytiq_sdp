import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../themes/colors.dart';
import '../../themes/text_styles.dart';

class RouteResultScreen extends StatefulWidget {
  final Point destination;

  const RouteResultScreen({super.key, required this.destination});

  @override
  State<RouteResultScreen> createState() => _RouteResultScreenState();
}

class _RouteResultScreenState extends State<RouteResultScreen> {
  late MapboxMap mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Route Results', style: AppTextStyles.lightHeadlineMedium),
        backgroundColor: AppColors.primary,
      ),
      body: MapWidget(
        key: const ValueKey("route-result-map"),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        textureView: true,
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
        resourceOptions: ResourceOptions(
          accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN']!,
        ),
        cameraOptions: CameraOptions(center: widget.destination, zoom: 14.0),
        onMapCreated: (controller) {
          mapboxMap = controller;
          mapboxMap.flyTo(
            CameraOptions(center: widget.destination, zoom: 14.0),
            MapAnimationOptions(duration: const Duration(milliseconds: 1500)),
          );
        },
      ),
    );
  }
}
