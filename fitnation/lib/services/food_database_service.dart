import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodDatabaseService {
  // Example: Open Food Facts API
  final String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product/';

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
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
          print('Product not found for barcode: $barcode');
          return null;
        }
      } else {
        print('Failed to load product for barcode: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching product by barcode: $e');
      return null;
    }
  }
}
