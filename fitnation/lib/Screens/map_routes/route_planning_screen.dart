import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/location_service.dart';
import '../../services/mapbox_service.dart';
import '../../themes/text_styles.dart';
import '../widgets/shared/rounded_button.dart';
import 'route_map_screen.dart';

class RoutePlanningScreen extends StatefulWidget {
  const RoutePlanningScreen({super.key});

  @override
  State<RoutePlanningScreen> createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  List<String> _suggestions = [];
  List<String> _recentDestinations = [];
  MapboxMap? _mapboxMap;

  final List<Map<String, String>> filters = [
    {'emoji': '🚶‍♂️', 'label': 'Walk'},
    {'emoji': '🚴‍♀️', 'label': 'Bike'},
    {'emoji': '🏃‍♂️', 'label': 'Run'},
    {'emoji': '🔥', 'label': 'HIIT'},
    {'emoji': '🏊‍♂️', 'label': 'Swim'},
  ];
  int selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedFilter();
    _loadRecentDestinations();
    _setFromCurrentLocation();
  }

  Future<void> _setFromCurrentLocation() async {
    final position = await LocationService.getCurrentLocation();
    final place = await MapboxService.reverseGeocode(
      position.latitude,
      position.longitude,
    );
    setState(() {
      _fromController.text =
          place ?? '${position.latitude}, ${position.longitude}';
    });
  }

  Future<void> _loadSelectedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFilterIndex = prefs.getInt('selected_filter') ?? 0;
    });
  }

  Future<void> _saveSelectedFilter(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_filter', index);
  }

  Future<void> _loadRecentDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('recent_destinations');
    if (saved != null) {
      setState(() {
        _recentDestinations = saved;
      });
    }
  }

  Future<void> _saveRecentDestination(String destination) async {
    final prefs = await SharedPreferences.getInstance();
    _recentDestinations.remove(destination);
    _recentDestinations.insert(0, destination);
    if (_recentDestinations.length > 5) {
      _recentDestinations = _recentDestinations.sublist(0, 5);
    }
    await prefs.setStringList('recent_destinations', _recentDestinations);
  }

  Future<void> _getSuggestions(String query) async {
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=${dotenv.env['MAPBOX_ACCESS_TOKEN']}&autocomplete=true',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List;
      setState(() {
        _suggestions = features.map((e) => e['place_name'] as String).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Plan Your Route',
                    style: AppTextStyles.lightHeadlineMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildFilterChips(),
                  const SizedBox(height: 12),
                  _buildInputField(
                    'From (Current Location)',
                    controller: _fromController,
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    'To (Destination)',
                    controller: _toController,
                    onChanged: _getSuggestions,
                  ),
                  _buildSuggestionList(),
                  const SizedBox(height: 12),
                  _buildRecentDestinations(),
                ],
              ),
            ),
            Expanded(
              child: MapWidget(
                key: const ValueKey("mapWidget"),
                resourceOptions: ResourceOptions(
                  accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN']!,
                ),
                styleUri: MapboxStyles.MAPBOX_STREETS,
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(90.4125, 23.8103)),
                  zoom: 12.0,
                ),
                onMapCreated: (controller) {
                  _mapboxMap = controller;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RoundedButton(
                text: "Plan Route",
                onPressed: () async {
                  final destination =
                      await MapboxService.forwardGeocode(_toController.text);
                  if (destination != null) {
                    await _saveRecentDestination(_toController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RouteMapScreen(destination: destination),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid destination")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8.0,
      children: List.generate(filters.length, (i) {
        final isSelected = i == selectedFilterIndex;
        return ChoiceChip(
          label: Text('${filters[i]['emoji']} ${filters[i]['label']}'),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => selectedFilterIndex = i);
            _saveSelectedFilter(i);
          },
        );
      }),
    );
  }

  Widget _buildInputField(
    String label, {
    required TextEditingController controller,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildSuggestionList() {
    if (_suggestions.isEmpty) return const SizedBox();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_suggestions[index]),
          onTap: () {
            setState(() {
              _toController.text = _suggestions[index];
              _suggestions = [];
            });
          },
        );
      },
    );
  }

  Widget _buildRecentDestinations() {
    if (_recentDestinations.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Recent Destinations:'),
        Wrap(
          spacing: 8.0,
          children: _recentDestinations.map((dest) {
            return ActionChip(
              label: Text(dest),
              onPressed: () {
                setState(() {
                  _toController.text = dest;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
