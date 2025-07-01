import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitnation/models/User.dart'; // Assuming you have a User model
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:fitnation/services/connectivity_service.dart'; // Import ConnectivityService
import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage

class ApiService {
  final Ref _ref;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final String _baseUrl = 'http://10.0.2.2:8000';
  String? _accessToken;

  ApiService(this._ref)
      : _dio = Dio(),
        _secureStorage = const FlutterSecureStorage();

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<void> _checkConnectivity() async {
    final connectivityService = _ref.read(connectivityServiceProvider);
    if (!(await connectivityService.hasInternetConnection())) {
      throw NoInternetException();
    }
  }

  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data, {bool includeAuth = false}) async {
    await _checkConnectivity(); // Check connectivity before making the request
    final url = '$_baseUrl$endpoint';
    final response = await _dio.post(
      url,
      options: Options(headers: _getHeaders(includeAuth: includeAuth)),
      data: json.encode(data),
    );

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      final errorBody = response.data;
      debugPrint("API Error: ${response.statusCode} - ${errorBody['detail']}");
      throw Exception(errorBody['detail'] ?? 'Failed to load data');
    }
  }

  Future<Map<String, dynamic>> _get(String endpoint, {bool includeAuth = true}) async {
    await _checkConnectivity(); // Check connectivity before making the request
    final url = '$_baseUrl$endpoint';
    final response = await _dio.get(
      url,
      options: Options(headers: _getHeaders(includeAuth: includeAuth)),
    );

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      final errorBody = response.data;
      debugPrint("API Error: ${response.statusCode} - ${errorBody['detail']}");
      throw Exception(errorBody['detail'] ?? 'Failed to load data');
    }
  }

  // Auth Endpoints
  Future<Map<String, dynamic>> login(String username, String password) async {
    await _checkConnectivity(); // Check connectivity before making the request
    final response = await _dio.post(
      '$_baseUrl/api/v1/auth/login/access-token',
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      ),
      data: {
        'username': username,
        'password': password,
      },
      // Dio handles encoding automatically for map data
    );

    if (response.statusCode == 200) {
      final data = response.data; // Dio response data
      setAccessToken(data['access_token']); // Set the token upon successful login
      return data;
    } else {
      final errorBody = response.data; // Dio response data
      throw Exception(errorBody['detail'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    await _checkConnectivity(); // Check connectivity before making the request
    return _post(
      '/api/v1/auth/register',
      {
        'username': username,
        'email': email,
        'password': password,
      },
    );
  }

  Future<User> getCurrentUser() async {
    await _checkConnectivity(); // Check connectivity before making the request
    final data = await _get('/api/v1/users/me');
    return User.fromJson(data);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    await _checkConnectivity(); // Check connectivity before making the request
    return _post(
      '/api/v1/auth/refresh-token',
      {'refresh_token': refreshToken},
      includeAuth: false, // Refresh token endpoint might not require auth header
    );
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    await _checkConnectivity(); // Check connectivity before making the request
    return _post(
      '/api/v1/auth/google-login',
      {'id_token': idToken},
      includeAuth: false, // Google login endpoint doesn't use our bearer token
    );
  }

  Future<void> forgotPassword(String email) async {
    await _checkConnectivity(); // Check connectivity before making the request
    await _post(
      '/api/v1/auth/forgot-password',
      {'email': email},
      includeAuth: false,
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _checkConnectivity(); // Check connectivity before making the request
    await _post(
      '/api/v1/auth/reset-password',
      {'token': token, 'new_password': newPassword},
      includeAuth: false,
    );
  }

  // Other API calls can be added here
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});
