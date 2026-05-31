import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';

typedef AssetLoader = Future<String> Function(String key);

class AnatomyRepository {
  static const assetKey = 'assets/data/muscle_anatomy.json';

  final AssetLoader _loadAsset;
  MuscleAnatomy? _cache;

  AnatomyRepository({AssetLoader? loadAsset})
      : _loadAsset = loadAsset ?? rootBundle.loadString;

  Future<MuscleAnatomy> load() async {
    if (_cache != null) return _cache!;
    final raw = await _loadAsset(assetKey);
    final decoded = json.decode(raw); // throws FormatException on bad json
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('muscle_anatomy.json root is not an object');
    }
    return _cache = MuscleAnatomy.fromJson(decoded);
  }
}
