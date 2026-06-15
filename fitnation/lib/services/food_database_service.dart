import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fitnation/api/API_Services.dart';

class FoodDatabaseService {
  final ApiService? _apiService;

  FoodDatabaseService({ApiService? apiService}) : _apiService = apiService;

  // Example: Open Food Facts API
  final String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product/';

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final backendResult = await _getProductByBarcodeFromBackend(barcode);
    if (backendResult != null) {
      return backendResult;
    }

    final url = Uri.parse('$_baseUrl$barcode.json');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          // Extract relevant nutrition info
          final product = data['product'];
          final nutriments = product['nutriments'];

          return {
            'name': product['product_name'] ?? 'Unknown Product',
            'calories': nutriments['energy-kcal_100g'] ?? 0.0,
            'protein': nutriments['proteins_100g'] ?? 0.0,
            'carbs': nutriments['carbohydrates_100g'] ?? 0.0,
            'fat': nutriments['fat_100g'] ?? 0.0,
            'quantity': 100.0, // Per 100g
            'unit': 'g',
          };
        } else {
          debugPrint('Product not found for barcode: $barcode');
          return null;
        }
      } else {
        debugPrint(
          'Failed to load product for barcode: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching product by barcode: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getProductByBarcodeFromBackend(
    String barcode,
  ) async {
    final apiService = _apiService;
    if (apiService == null) return null;

    try {
      final data = await apiService.lookupBarcode(barcode);
      if (data == null) return null;
      return {
        'name': data['name'] ?? 'Unknown Product',
        'calories': data['calories'] ?? 0.0,
        'protein': data['protein_g'] ?? 0.0,
        'carbs': data['carbs_g'] ?? 0.0,
        'fat': data['fat_g'] ?? 0.0,
        'quantity': 100.0,
        'unit': data['unit'] ?? 'g',
        'servingSize': data['serving_size'],
        'source': data['source'] ?? 'backend',
      };
    } catch (_) {
      // Backend unavailable or auth expired: use direct Open Food Facts fallback.
      return null;
    }
  }
}
