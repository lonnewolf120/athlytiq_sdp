import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/Exercise.dart';

class ExerciseDatabaseHelper {
  static final ExerciseDatabaseHelper _instance =
      ExerciseDatabaseHelper._internal();
  factory ExerciseDatabaseHelper() => _instance;
  ExerciseDatabaseHelper._internal();

  static Database? _database;
  static Future<void>? _loadingExercisesFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'exercises.db');

    // If a prebuilt DB is bundled in assets, copy it to the databases path
    try {
      final file = File(path);
      if (!await file.exists()) {
        // Try to load prebuilt DB from assets
        try {
          final data = await rootBundle.load('assets/data/exercises.db');
          final bytes = data.buffer.asUint8List();
          await file.create(recursive: true);
          await file.writeAsBytes(bytes, flush: true);
          print('Copied prebuilt exercises.db from assets to $path');
        } catch (e) {
          // Asset doesn't exist; we'll create DB normally in openDatabase
          print('No prebuilt DB in assets (or failed to copy): $e');
        }
      }
    } catch (e) {
      print('Error ensuring DB file exists: $e');
    }

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exercises(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        gif_url TEXT,
        body_parts TEXT,
        equipments TEXT,
        target_muscles TEXT,
        secondary_muscles TEXT,
        instructions TEXT,
        name_lower TEXT,
        search_text TEXT
      )
    ''');

    // Create indexes for faster searching
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_name_lower ON exercises(name_lower)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_body_parts ON exercises(body_parts)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_equipments ON exercises(equipments)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_target_muscles ON exercises(target_muscles)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_search_text ON exercises(search_text)',
    );
  }

  Future<void> loadExercisesFromJson() async {
    // Ensure only one load operation runs at a time
    if (_loadingExercisesFuture != null) return _loadingExercisesFuture!;

    _loadingExercisesFuture = () async {
      final db = await database;

      // Check if exercises are already loaded
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM exercises'),
      );
      if (count != null && count > 0) {
        print('Exercises already loaded in database: $count exercises');
        return;
      }

      try {
        print('Loading exercises from JSON (background parse)...');
        final jsonString = await rootBundle.loadString(
          'assets/data/exercises.json',
        );

        // Parse JSON on a background isolate to avoid blocking UI
        final List<dynamic> jsonList = await compute(
          _parseJsonList,
          jsonString,
        );

        final batch = db.batch();

        for (final exerciseJson in jsonList) {
          final exercise = Exercise.fromJson(exerciseJson);
          final searchText = _buildSearchText(exercise);

          batch.insert('exercises', {
            'id': exercise.exerciseId ?? '',
            'name': exercise.name,
            'gif_url': exercise.gifUrl,
            'body_parts': exercise.bodyParts.join(','),
            'equipments': exercise.equipments.join(','),
            'target_muscles': exercise.targetMuscles.join(','),
            'secondary_muscles': exercise.secondaryMuscles.join(','),
            'instructions': exercise.instructions.join('|'),
            'name_lower': exercise.name.toLowerCase(),
            'search_text': searchText,
          });
        }

        await batch.commit(noResult: true);
        print('Successfully loaded ${jsonList.length} exercises into database');
      } catch (e, st) {
        print('Error loading exercises from JSON: $e\n$st');
        rethrow;
      }
    }();

    return _loadingExercisesFuture!;
  }

  // parse helper for compute
  List<dynamic> _parseJsonList(String jsonString) {
    return json.decode(jsonString) as List<dynamic>;
  }

  String _buildSearchText(Exercise exercise) {
    final searchComponents = [
      exercise.name,
      ...exercise.bodyParts,
      ...exercise.equipments,
      ...exercise.targetMuscles,
      ...exercise.secondaryMuscles,
    ];
    return searchComponents.join(' ').toLowerCase();
  }

  Future<List<Exercise>> searchExercises({
    String? query,
    String? bodyPart,
    String? equipment,
    String? targetMuscle,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;

    String whereClause = '';
    List<String> conditions = [];
    List<dynamic> args = [];

    if (query != null && query.trim().isNotEmpty) {
      conditions.add('(name_lower LIKE ? OR search_text LIKE ?)');
      final searchTerm = '%${query.toLowerCase()}%';
      args.addAll([searchTerm, searchTerm]);
    }

    if (bodyPart != null && bodyPart.trim().isNotEmpty) {
      conditions.add('body_parts LIKE ?');
      args.add('%${bodyPart.toLowerCase()}%');
    }

    if (equipment != null && equipment.trim().isNotEmpty) {
      conditions.add('equipments LIKE ?');
      args.add('%${equipment.toLowerCase()}%');
    }

    if (targetMuscle != null && targetMuscle.trim().isNotEmpty) {
      conditions.add('target_muscles LIKE ?');
      args.add('%${targetMuscle.toLowerCase()}%');
    }

    if (conditions.isNotEmpty) {
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    final sql = '''
      SELECT * FROM exercises
      $whereClause
      ORDER BY 
        CASE 
          WHEN name_lower LIKE ? THEN 1
          WHEN name_lower LIKE ? THEN 2
          ELSE 3
        END,
        name
      LIMIT ? OFFSET ?
    ''';

    final queryLower = query?.toLowerCase() ?? '';
    args.addAll(['$queryLower%', '%$queryLower%', limit, offset]);

    final maps = await db.rawQuery(sql, args);
    return maps.map((map) => _exerciseFromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByBodyPart(
    String bodyPart, {
    int limit = 20,
  }) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'body_parts LIKE ?',
      whereArgs: ['%${bodyPart.toLowerCase()}%'],
      orderBy: 'name',
      limit: limit,
    );
    return maps.map((map) => _exerciseFromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByEquipment(
    String equipment, {
    int limit = 20,
  }) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'equipments LIKE ?',
      whereArgs: ['%${equipment.toLowerCase()}%'],
      orderBy: 'name',
      limit: limit,
    );
    return maps.map((map) => _exerciseFromMap(map)).toList();
  }

  Future<Exercise?> getExerciseById(String id) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _exerciseFromMap(maps.first);
  }

  Future<List<String>> getUniqueBodyParts() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT body_parts FROM exercises
      WHERE body_parts IS NOT NULL AND body_parts != ""
    ''');

    Set<String> bodyParts = {};
    for (final map in maps) {
      final parts = (map['body_parts'] as String).split(',');
      bodyParts.addAll(parts.where((part) => part.trim().isNotEmpty));
    }

    final list = bodyParts.toList()..sort();
    return list;
  }

  Future<List<String>> getUniqueEquipments() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT equipments FROM exercises
      WHERE equipments IS NOT NULL AND equipments != ""
    ''');

    Set<String> equipments = {};
    for (final map in maps) {
      final equipment = (map['equipments'] as String).split(',');
      equipments.addAll(equipment.where((eq) => eq.trim().isNotEmpty));
    }

    final list = equipments.toList()..sort();
    return list;
  }

  Future<List<String>> getUniqueTargetMuscles() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT target_muscles FROM exercises
      WHERE target_muscles IS NOT NULL AND target_muscles != ""
    ''');

    Set<String> muscles = {};
    for (final map in maps) {
      final muscle = (map['target_muscles'] as String).split(',');
      muscles.addAll(muscle.where((m) => m.trim().isNotEmpty));
    }

    final list = muscles.toList()..sort();
    return list;
  }

  Exercise _exerciseFromMap(Map<String, dynamic> map) {
    return Exercise(
      exerciseId: map['id'],
      name: map['name'],
      gifUrl: map['gif_url'],
      bodyParts:
          (map['body_parts'] as String? ?? '')
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList(),
      equipments:
          (map['equipments'] as String? ?? '')
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList(),
      targetMuscles:
          (map['target_muscles'] as String? ?? '')
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList(),
      secondaryMuscles:
          (map['secondary_muscles'] as String? ?? '')
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList(),
      instructions:
          (map['instructions'] as String? ?? '')
              .split('|')
              .where((s) => s.isNotEmpty)
              .toList(),
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
