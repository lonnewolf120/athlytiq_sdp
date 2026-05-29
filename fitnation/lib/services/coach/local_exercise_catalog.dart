import 'package:fitnation/helpers/exercise_database_helper.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/services/coach/exercise_resolver.dart';

/// Concrete ExerciseCatalog backed by the bundled local exercises.db.
class LocalExerciseCatalog implements ExerciseCatalog {
  final ExerciseDatabaseHelper _db;

  LocalExerciseCatalog([ExerciseDatabaseHelper? db])
      : _db = db ?? ExerciseDatabaseHelper();

  @override
  Future<ex_db.Exercise?> getById(String id) => _db.getExerciseById(id);

  @override
  Future<List<ex_db.Exercise>> searchByName(
    String name, {
    String? bodyPart,
    String? equipment,
    int limit = 5,
  }) =>
      _db.searchExercises(
        query: name.isNotEmpty ? name : null,
        bodyPart: bodyPart,
        equipment: equipment,
        limit: limit,
      );

  @override
  Future<List<ex_db.Exercise>> getByBodyPart(String bodyPart, {int limit = 5}) =>
      _db.getExercisesByBodyPart(bodyPart, limit: limit);

  @override
  Future<List<String>> getUniqueBodyParts() => _db.getUniqueBodyParts();

  @override
  Future<List<String>> getUniqueEquipments() => _db.getUniqueEquipments();
}
