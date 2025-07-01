import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/data_providers.dart'; // Import apiServiceProvider from data_providers
import 'package:fitnation/api/API_Services.dart'; // Import your ApiService class
import 'package:fitnation/models/Exercise.dart'; // Import your updated Exercise model
// Import other models as needed

// Provider for the ApiService instance (keep this)

// --- ExerciseDB Related Providers (Updated) ---

// Provider for fetching the list of body parts
final bodyPartListProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(apiServiceProvider).getBodyPartList();
});

// Provider for fetching the list of equipment
final equipmentListProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(apiServiceProvider).getEquipmentList();
});

// Provider for fetching the list of muscles (formerly targets)
final muscleListProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(apiServiceProvider).getMuscleList();
});

// Provider to fetch exercises by Body Part Name (using family)
final exercisesByBodyPartNameProvider = FutureProvider.family<List<Exercise>, String>((ref, bodyPartName) async {
   // Add limit/offset if you want pagination in the UI
  return ref.watch(apiServiceProvider).getExercisesByBodyPartName(bodyPartName);
});

// Provider to fetch exercises by Equipment Name (using family)
final exercisesByEquipmentNameProvider = FutureProvider.family<List<Exercise>, String>((ref, equipmentName) async {
   // Add limit/offset if you want pagination in the UI
  return ref.watch(apiServiceProvider).getExercisesByEquipmentName(equipmentName);
});

// Provider to fetch exercises by Muscle Name (using family)
final exercisesByMuscleNameProvider = FutureProvider.family<List<Exercise>, String>((ref, muscleName) async {
   // Add limit/offset if you want pagination in the UI
  return ref.watch(apiServiceProvider).getExercisesByMuscleName(muscleName);
});

// Provider to fetch a single exercise by ID (using family)
final exerciseByIdProvider = FutureProvider.family<Exercise, String>((ref, exerciseId) async { // Use exerciseId parameter name
  return ref.watch(apiServiceProvider).getExerciseById(exerciseId);
});

// Provider to search exercises by Name (using family)
final exercisesSearchByNameProvider = FutureProvider.family<List<Exercise>, String>((ref, query) async { // Renamed for clarity
   if (query.isEmpty) return []; // Don't search with empty query
   // Add limit/offset if you want pagination in the UI
  return ref.watch(apiServiceProvider).searchExercisesByName(query);
});

// Provider for exercise autocomplete suggestions
final exerciseAutocompleteProvider = FutureProvider.family<List<String>, String>((ref, query) async {
   if (query.isEmpty) return []; // Don't autocomplete with empty query
   return ref.watch(apiServiceProvider).autocompleteExerciseSearch(query);
});


// Provider to fetch ALL exercises (use with caution, consider UI needs)
final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  return ref.watch(apiServiceProvider).getAllExercises();
});
