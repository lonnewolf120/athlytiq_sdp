import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/RideActivity.dart';

// Provider for the selected category in HomeScreen
final selectedCategoryProvider = StateProvider<RideActivityType>(
  (ref) => RideActivityType.mountain,
);

// Provider for the currently selected ride to show details
// Initially null, set when a ride card is tapped.
final selectedRideProvider = StateProvider<RideActivity?>((ref) => null);
