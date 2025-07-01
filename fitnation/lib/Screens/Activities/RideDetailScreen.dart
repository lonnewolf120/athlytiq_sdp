// import 'dart:typed_data'; // For Uint8List when loading images
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // For rootBundle
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fitnation/models/RideActivity.dart'
//     hide LatLng; // Hide old LatLng
// import 'package:fitnation/providers/ui_providers.dart';
// import 'package:fitnation/widgets/ParticipantAvatar.dart';

// // Import the new Mapbox Maps Flutter plugin and its necessary components
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
//     as Mbm; // Aliasing

// // Import the old mapbox_gl LatLng specifically for converting from your model
// // This assumes your RideActivity.routeCoordinates still holds mapbox_gl.LatLng objects.
// // If you've updated RideActivity model to use a generic LatLng or mapbox_maps_flutter's Position,
// // then this import might not be needed, and the conversion logic will change.
// import 'package:mapbox_gl/mapbox_gl.dart' as MGL;

// class RideDetailScreen extends ConsumerStatefulWidget {
//   const RideDetailScreen({super.key});

//   @override
//   ConsumerState<RideDetailScreen> createState() => _RideDetailScreenState();
// }

// class _RideDetailScreenState extends ConsumerState<RideDetailScreen> {
//   Mbm.MapboxMap? _mapboxMap;
//   Mbm.PointAnnotationManager? _pointAnnotationManager;
//   Mbm.PolylineAnnotationManager? _polylineAnnotationManager;

//   static const String START_MARKER_IMAGE_ID = "start-marker-image";
//   static const String END_MARKER_IMAGE_ID = "end-marker-image";

//   // Helper to convert mapbox_gl.LatLng to mapbox_maps_flutter's Point geometry (for annotations)
//   // which expects a GeoJSON Point structure.
//   Map<String, dynamic> _mglLatLngToGeoJsonPoint(MGL.LatLng mglLatLng) {
//     return {
//       "type": "Point",
//       "coordinates": [mglLatLng.longitude, mglLatLng.latitude], // Lng, Lat
//     };
//   }

//   // Helper to convert list of mapbox_gl.LatLng to GeoJSON LineString geometry
//   Map<String, dynamic> _mglLatLngListToGeoJsonLineString(
//     List<MGL.LatLng> mglLatLngList,
//   ) {
//     return {
//       "type": "LineString",
//       "coordinates":
//           mglLatLngList.map((p) => [p.longitude, p.latitude]).toList(),
//     };
//   }

//   // Helper to convert mapbox_gl.LatLng to mapbox_maps_flutter's ScreenCoordinate (if needed, though less common here)
//   // Mbm.ScreenCoordinate _mglLatLngToScreenCoordinate(MGL.LatLng mglLatLng) {
//   //   // This would require projection, usually done by the map itself.
//   //   // For annotation geometry, GeoJSON is preferred.
//   //   // For camera center, Mbm.Point is used.
//   //   throw UnimplementedError("Direct conversion to ScreenCoordinate is complex and usually not needed for geometry.");
//   // }

//   // Helper to convert mapbox_gl.LatLng to mapbox_maps_flutter's Mbm.Point (for camera options)
//   Mbm.Point _mglLatLngToMbmPoint(MGL.LatLng mglLatLng) {
//     return Mbm.Point(
//       coordinates: Mbm.Position(mglLatLng.longitude, mglLatLng.latitude),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     // It's good practice to set the access token programmatically,
//     // especially if it's not hardcoded in Info.plist or AndroidManifest.xml.
//     // However, mapbox_maps_flutter typically reads it from platform configurations.
//     // If you have issues, you can try:
//     // Mbm.MapboxOptions.setAccessToken("YOUR_MAPBOX_ACCESS_TOKEN");
//   }

//   Future<void> _loadMarkerImage(String assetName, String imageId) async {
//     final ByteData bytes = await rootBundle.load(assetName);
//     final Uint8List list = bytes.buffer.asUint8List();
//     // The MbxImage data parameter expects Uint8List
//     return _mapboxMap?.style.addStyleImage(
//       imageId, // Unique ID for the image
//       1.0, //scale
//       Mbm.MbxImage(
//         width: 35,
//         height: 35,
//         data: list,
//       ), // Adjust width/height as needed
//       false, // sdf
//       [], // stretchX
//       [], // stretchY
//       null, // content
//     );
//   }

//   Future<void> _onMapCreated(Mbm.MapboxMap mapboxMap) async {
//     _mapboxMap = mapboxMap;
//     final ride = ref.read(selectedRideProvider);

//     if (ride == null ||
//         ride.routeCoordinates == null ||
//         ride.routeCoordinates!.isEmpty) {
//       return;
//     }

//     // 1. Load marker images into the map's style (do this before creating annotations that use them)
//     // Make sure 'assets/images/marker-start.png' and 'assets/images/marker-end.png' exist
//     // and are declared in pubspec.yaml
//     try {
//       await _loadMarkerImage(
//         'assets/images/marker-start.png',
//         START_MARKER_IMAGE_ID,
//       ); // Replace with your actual asset path
//       await _loadMarkerImage(
//         'assets/images/marker-end.png',
//         END_MARKER_IMAGE_ID,
//       ); // Replace with your actual asset path
//     } catch (e) {
//       print(
//         "Error loading marker images: $e. Ensure assets exist and are in pubspec.yaml.",
//       );
//       // Fallback or no custom markers if loading fails
//     }

//     // 2. Create Annotation Managers AFTER map and style are ready
//     // (onStyleLoaded is a safer place if issues persist, but onMapCreated often works)
//     _pointAnnotationManager =
//         await _mapboxMap?.annotations.createPointAnnotationManager();
//     _polylineAnnotationManager =
//         await _mapboxMap?.annotations.createPolylineAnnotationManager();

//     // 3. Prepare route coordinates (List<MGL.LatLng> from your model)
//     final List<MGL.LatLng> routeMglLatLngs = ride.routeCoordinates!;

//     // 4. Add Route Polyline
//     if (routeMglLatLngs.isNotEmpty) {
//       final lineGeoJson = _mglLatLngListToGeoJsonLineString(routeMglLatLngs);
//       await _polylineAnnotationManager?.create(
//         Mbm.PolylineAnnotationOptions(
//           geometry: lineGeoJson, // Use the GeoJSON map directly
//           lineColor: Colors.orange.value,
//           lineWidth: 4.0,
//           lineOpacity: 0.8,
//         ),
//       );
//     }

//     // 5. Add Start and End Markers (PointAnnotations)
//     if (routeMglLatLngs.isNotEmpty) {
//       // Start Marker
//       await _pointAnnotationManager?.create(
//         Mbm.PointAnnotationOptions(
//           geometry: _mglLatLngToGeoJsonPoint(
//             routeMglLatLngs.first,
//           ), // Use the GeoJSON map
//           iconImage: START_MARKER_IMAGE_ID, // Reference the loaded image ID
//           iconSize: 1.0, // Default size, or adjust if image is SDF
//           // textField: "Start", // Optional text
//           // textColor: Colors.white.value,
//           // textOffset: [0.0, -2.5]
//         ),
//       );

//       // End Marker
//       if (routeMglLatLngs.length > 1) {
//         // Only add end marker if there's more than one point
//         await _pointAnnotationManager?.create(
//           Mbm.PointAnnotationOptions(
//             geometry: _mglLatLngToGeoJsonPoint(
//               routeMglLatLngs.last,
//             ), // Use the GeoJSON map
//             iconImage: END_MARKER_IMAGE_ID, // Reference the loaded image ID
//             iconSize: 1.0,
//             // textField: "End",
//             // textColor: Colors.white.value,
//             // textOffset: [0.0, -2.5]
//           ),
//         );
//       }
//     }

//     // 6. Move camera to fit the route
//     if (routeMglLatLngs.isNotEmpty) {
//       List<Mbm.Point> mbmPoints =
//           routeMglLatLngs.map(_mglLatLngToMbmPoint).toList();
//       if (mbmPoints.length > 1) {
//         // For bounds, we need a list of Mbm.Point objects
//         Mbm.CoordinateBounds bounds = await _mapboxMap!.camera
//             .coordinateBoundsForPoints(mbmPoints);
//         _mapboxMap?.flyTo(
//           Mbm.CameraOptions(
//             bounds: bounds,
//             padding: const Mbm.MbxEdgeInsets(
//               top: 50,
//               left: 50,
//               bottom: 350,
//               right: 50,
//             ),
//           ),
//           Mbm.MapAnimationOptions(duration: 1500),
//         );
//       } else {
//         // Single point
//         _mapboxMap?.flyTo(
//           Mbm.CameraOptions(
//             center: _mglLatLngToMbmPoint(routeMglLatLngs.first).toJsonValue(),
//             zoom: 12.0,
//           ),
//           Mbm.MapAnimationOptions(duration: 1500),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     // It's good practice to remove managers if the map controller might be disposed before them,
//     // though the plugin should handle this.
//     // _pointAnnotationManager?.deleteAll(); // This might be too aggressive if map is reused
//     // _polylineAnnotationManager?.deleteAll();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ride = ref.watch(selectedRideProvider);

//     if (ride == null) {
//       return Scaffold(
//         appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
//         body: const Center(
//           child: Text(
//             'No ride selected.',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

//     Mbm.Point initialMapCenter;
//     double initialMapZoom = 10.0;

//     if (ride.routeCoordinates != null && ride.routeCoordinates!.isNotEmpty) {
//       // Use the middle point of the route for initial center
//       final MGL.LatLng centerMglLatLng =
//           ride.routeCoordinates![ride.routeCoordinates!.length ~/ 2];
//       initialMapCenter = _mglLatLngToMbmPoint(centerMglLatLng);
//     } else {
//       initialMapCenter = Mbm.Point(
//         coordinates: Mbm.Position(0, 0),
//       ); // Default fallback (Lng, Lat)
//     }

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         // ... (app bar remains the same)
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_horiz, color: Colors.white),
//             onPressed: () {
//               /* Handle more options */
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Mbm.MapWidget(
//             key: const ValueKey("rideDetailMap"),
//             resourceOptions: Mbm.ResourceOptions(
//               accessToken: "YOUR_MAPBOX_ACCESS_TOKEN",
//             ), // Replace!
//             cameraOptions: Mbm.CameraOptions(
//               center:
//                   initialMapCenter
//                       .toJsonValue(), // This expects a Map<String, dynamic> like {"type": "Point", "coordinates": [lng, lat]}
//               zoom: initialMapZoom,
//             ),
//             styleUri: Mbm.MapboxStyles.DARK,
//             onMapCreated:
//                 _onMapCreated, // Called when MapboxMap controller is available
//             onStyleLoadedListener: (Mbm.StyleLoadedEventData data) {
//               print("Style loaded. Timestamp: ${data.timestamp}");
//               // If _onMapCreated has issues with style readiness, you might move some
//               // style-dependent operations (like addStyleImage) here, or re-trigger
//               // drawing annotations if needed. For initial load, _onMapCreated is usually sufficient.
//             },
//             onMapIdleListener: (Mbm.MapIdleEventData data) {
//               // Can be useful for knowing when all loading/animations are done
//             },
//           ),
//           DraggableScrollableSheet(
//             // ... (DraggableScrollableSheet UI remains the same)
//             initialChildSize: 0.45,
//             minChildSize: 0.45,
//             maxChildSize: 0.8,
//             builder: (BuildContext context, ScrollController scrollController) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.9),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       spreadRadius: 5,
//                       blurRadius: 7,
//                     ),
//                   ],
//                 ),
//                 child: ListView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.all(16.0),
//                   children: [
//                     Center(
//                       child: Container(
//                         width: 40,
//                         height: 5,
//                         margin: const EdgeInsets.only(bottom: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[700],
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     _buildStatsCard(ride),
//                     const SizedBox(height: 24),
//                     _buildPoiItem(
//                       Icons.circle,
//                       Colors.greenAccent,
//                       ride.locationName ?? 'N/A',
//                     ),
//                     const Divider(
//                       color: Colors.white24,
//                       height: 1,
//                       indent: 40,
//                       endIndent: 10,
//                     ),
//                     _buildPoiItem(
//                       Icons.location_pin,
//                       Colors.orange,
//                       ride.parkName ?? 'N/A',
//                     ),
//                     const SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'People Who Joined',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {},
//                           child: const Text(
//                             'View all',
//                             style: TextStyle(color: Colors.orange),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     SizedBox(
//                       height: 100,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: ride.participants?.length ?? 0,
//                         itemBuilder: (context, index) {
//                           final user = ride.participants![index];
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 16.0),
//                             child: Column(
//                               children: [
//                                 ParticipantAvatar(user: user, radius: 28),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   user.displayName.split(' ').first,
//                                   style: const TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 Text(
//                                   'View Profile',
//                                   style: TextStyle(
//                                     color: Colors.orange[300],
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ... (_buildStatsCard, _buildStatItem, _buildPoiItem methods remain the same)
//   Widget _buildStatsCard(RideActivity ride) {
//     return Card(
//       elevation: 0,
//       color: Colors.grey[900]?.withOpacity(0.7),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildStatItem('Length', ride.distanceDisplay),
//             _buildStatItem('Elevation', ride.elevationDisplay),
//             _buildStatItem('Type', ride.typeDisplay),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value) {
//     return Column(
//       children: [
//         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPoiItem(IconData icon, Color iconColor, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: iconColor, size: 20),
//           const SizedBox(width: 16),
//           Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
//         ],
//       ),
//     );
//   }
// }
