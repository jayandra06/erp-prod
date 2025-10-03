import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';
  static String? _token;
  static String? _refreshToken;

  // Token management
  static String? get token => _token;
  static String? get refreshToken => _refreshToken;

  static Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
    }
  }

  static Future<void> setRefreshToken(String? refreshToken) async {
    _refreshToken = refreshToken;
    if (refreshToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('refresh_token', refreshToken);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('refresh_token');
    }
  }

  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  static Future<void> clearTokens() async {
    await setToken(null);
    await setRefreshToken(null);
  }

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Health check
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }

  // Authentication endpoints
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'userType': userType,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed login data: $data');
        
        if (data['token'] != null) {
          await setToken(data['token']);
        }
        return data;
      } else {
        final error = jsonDecode(response.body);
        print('Login error response: $error');
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    String? companyName,
    String? phone,
    String? vesselType,
    String? preferredCurrency,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'userType': userType,
          if (companyName != null) 'companyName': companyName,
          if (phone != null) 'phone': phone,
          if (vesselType != null) 'vesselType': vesselType,
          if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await setToken(data['token']);
        }
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: _headers,
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await clearTokens();
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      print('Get current user error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await setToken(data['token']);
        }
        return data;
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      print('Token refresh error: $e');
      rethrow;
    }
  }

  // Technical portal endpoints
  static Future<Map<String, dynamic>> getTechnicalDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/technical/dashboard'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Permission denied: Cannot access technical dashboard');
      } else {
        throw Exception('Failed to get technical dashboard: ${response.body}');
      }
    } catch (e) {
      print('Get technical dashboard error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/technical/system-health'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Permission denied: Cannot access system health');
      } else {
        throw Exception('Failed to get system health: ${response.body}');
      }
    } catch (e) {
      print('Get system health error: $e');
      rethrow;
    }
  }

  // User management endpoints
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['users'] ?? []);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Permission denied - return empty list for now
        return [];
      } else {
        throw Exception('Failed to get users: ${response.body}');
      }
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: _headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Permission denied: Cannot create users');
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: _headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Permission denied: Cannot update user');
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Permission denied: Cannot delete user');
      } else {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // RFQ endpoints
  static Future<List<Map<String, dynamic>>> getRFQs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/technical/rfq'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['rfqs'] ?? []);
      } else {
        throw Exception('Failed to get RFQs: ${response.body}');
      }
    } catch (e) {
      print('Error getting RFQs: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createRFQ(Map<String, dynamic> rfqData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/technical/rfq'),
        headers: _headers,
        body: jsonEncode(rfqData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create RFQ: ${response.body}');
      }
    } catch (e) {
      print('Error creating RFQ: $e');
      rethrow;
    }
  }

  // Quote endpoints
  static Future<List<Map<String, dynamic>>> getQuotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/technical/quotes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['quotes'] ?? []);
      } else {
        throw Exception('Failed to get quotes: ${response.body}');
      }
    } catch (e) {
      print('Error getting quotes: $e');
      return [];
    }
  }

  // Analytics endpoints
  static Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/technical/analytics'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get analytics: ${response.body}');
      }
    } catch (e) {
      print('Error getting analytics: $e');
      rethrow;
    }
  }
}
