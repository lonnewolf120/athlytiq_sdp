import 'package:fitnation/api/API_Services.dart';
import 'package:fitnation/models/meal.dart';
import 'package:fitnation/models/food_item.dart';
import 'dart:convert';
import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage

class MealApiService {
  final ApiService _apiServices;
  final String _baseUrl =
      '${dotenv.env['BASE_URL']}/meals/users/me'; // Adjust as per your backend URL

  MealApiService(this._apiServices); // Receive ApiService instance

  Future<Meal> createMeal(Meal meal) async {
    final response = await _apiServices.post(_baseUrl, meal.toJson());

    if (response.statusCode == 201) {
      return Meal.fromJson(response.data);
    } else {
      throw Exception('Failed to create meal: ${response.data}');
    }
  }

  Future<Meal> getMeal(String mealId) async {
    final response = await _apiServices.get('$_baseUrl/$mealId');

    if (response.statusCode == 200) {
      return Meal.fromJson(response.data);
    } else {
      throw Exception('Failed to load meal: ${response.data}');
    }
  }

  Future<List<Meal>> getMealsForUser() async {
    final response = await _apiServices.get(
      '${dotenv.env['BASE_URL']}/meals/users/me/',
    ); // Adjust as per your backend URL

    if (response.statusCode == 200) {
      Iterable list = response.data;
      return list.map((model) => Meal.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load meals: ${response.data}');
    }
  }

  Future<Meal> updateMeal(String mealId, Meal meal) async {
    final response = await _apiServices.put('$_baseUrl/$mealId', meal.toJson());

    if (response.statusCode == 200) {
      return Meal.fromJson(response.data);
    } else {
      throw Exception('Failed to update meal: ${response.data}');
    }
  }

  Future<void> deleteMeal(String mealId) async {
    final response = await _apiServices.delete('$_baseUrl/$mealId');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete meal: ${response.data}');
    }
  }
}
