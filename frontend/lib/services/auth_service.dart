import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://backend-final-mhas.onrender.com/api';

  // Register function
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    // Create request body
    final body = json.encode({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
    });

    try {
      // Send POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Check if response is successful
      if (response.statusCode == 201) {
        // Decode the response
        return json.decode(response.body);
      } else {
        // Decode and return error message from response
        return json.decode(response.body);
      }
    } catch (error) {
      // Handle errors (e.g., no internet connection)
      return {'message': 'Something went wrong, try again later'};
    }
  }

  // Login function
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    // Create request body and encode it as JSON
    final body = json.encode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body, // Send the JSON encoded body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        // Save all user data
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['user']['id']);
        await prefs.setString('userName', data['user']['name']);
        await prefs.setString('userEmail', data['user']['email']);
        await prefs.setString('userRole', data['user']['role']);
        await prefs.setString('userPhone', data['user']['phone']);
        await prefs.setString(
            'userProfilePicture', data['user']['profilePicture']);

        return data;
      } else {
        final errorData = json.decode(response.body);
        return {'message': errorData['message'] ?? 'Invalid email or password'};
      }
    } catch (error) {
      return {'message': 'Something went wrong, try again later'};
    }
  }

  // Fetch the token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Add this new method to AuthService
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('userId'),
      'name': prefs.getString('userName'),
      'email': prefs.getString('userEmail'),
      'role': prefs.getString('userRole'),
      'phone': prefs.getString('userPhone'),
      'profilePicture': prefs.getString('userProfilePicture'),
    };
  }

  static Future<void> updateProfile(String userId, String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No token found');

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": name,
        "phone": phone,
        // Remove email from the request body
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  static Future<void> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to change password');
    }
  }
}
