import 'dart:convert';

import 'package:futhub2/models/futsal_model.dart';
import 'package:futhub2/models/team_request_model.dart';
import 'package:futhub2/models/user_model.dart';
import 'package:futhub2/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl = AuthService.baseUrl; // Backend API URL

  // Fetch the stored token
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch analytics data (stats)
  Future<Map<String, dynamic>> fetchStats() async {
    String? token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token is missing.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/admin/analytics'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Assuming the response body contains a JSON object with the stats
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  /// Fetch a single user by ID.
  Future<User> getUser(String id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Fetch all users and filter by role = 'futsal_owner'
  // Future<List<User>> fetchOwners() async {
  //   String? token = await _getToken();
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/admin/users'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final decoded = json.decode(response.body);
  //     List<dynamic> jsonData;

  //     // Check if the decoded JSON is a Map with the key "owners"
  //     if (decoded is Map && decoded.containsKey("owners")) {
  //       jsonData = decoded["owners"] as List<dynamic>;
  //     }
  //     // Otherwise, if it's directly a list, use it (fallback)
  //     else if (decoded is List) {
  //       jsonData = decoded;
  //     } else {
  //       throw Exception(
  //           "Expected a list of users in the response, but got null or an unexpected structure.");
  //     }

  //     // Map the list to User objects
  //     List<User> users = jsonData.map((json) => User.fromJson(json)).toList();

  //     // (Optionally) Filter for futsal owners; if the JSON structure already separates owners, this may be redundant.
  //     return users.where((user) => user.role == 'futsal_owner').toList();
  //   } else {
  //     throw Exception('Failed to load owners');
  //   }
  // }

// Fetch all users and filter by role = 'futsal_owner'
  Future<List<User>> fetchOwners() async {
    String? token = await _getToken();
    try {
      print('Fetching owners...');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print('Decoded response: $decoded');

        List<dynamic> jsonData;

        // Handle different response structures
        if (decoded is Map) {
          if (decoded.containsKey("users")) {
            jsonData = decoded["users"] as List<dynamic>;
          } else if (decoded.containsKey("owners")) {
            jsonData = decoded["owners"] as List<dynamic>;
          } else {
            print(
                'Unexpected response structure. Keys found: ${decoded.keys.toList()}');
            jsonData = [];
          }
        } else if (decoded is List) {
          jsonData = decoded;
        } else {
          print('Unexpected response type: ${decoded.runtimeType}');
          jsonData = [];
        }

        print('Parsed JSON data length: ${jsonData.length}');

        // Map the list to User objects with error handling
        List<User> users = [];
        for (var json in jsonData) {
          try {
            final user = User.fromJson(json);
            if (user.role == 'futsal_owner') {
              users.add(user);
            }
          } catch (e, stackTrace) {
            print('Error parsing user: $e');
            print('Stack trace: $stackTrace');
            print('Problematic JSON: $json');
          }
        }

        print('Final users list length: ${users.length}');
        return users;
      } else {
        throw Exception(
            'Failed to load owners. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in fetchOwners: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<User>> fetchPlayers() async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> jsonData;

      // Check if the decoded JSON is a Map with the key "players"
      if (decoded is Map && decoded.containsKey("players")) {
        jsonData = decoded["players"] as List<dynamic>;
      }
      // Otherwise, if it's directly a list, use it (fallback)
      else if (decoded is List) {
        jsonData = decoded;
      } else {
        throw Exception(
            "Expected a list of users in the response, but got null or an unexpected structure.");
      }

      // Map the list to User objects
      List<User> users = jsonData.map((json) => User.fromJson(json)).toList();

      // Filter for players
      return users.where((user) => user.role == 'player').toList();
    } else {
      throw Exception('Failed to load players');
    }
  }

  // Fetch list of Futsals
  Future<List<Futsal>> getFutsals() async {
    String? token = await _getToken(); // Retrieve the token

    if (token == null) {
      throw Exception('Token is missing or expired');
    }

    // Making the API request with Authorization header
    final response = await http.get(
      Uri.parse('$baseUrl/futsals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include token in the header
      },
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Decode the response body into a list
      List<dynamic> data = json.decode(response.body);

      // Map the data to Futsal objects
      return data.map((futsal) => Futsal.fromJson(futsal)).toList();
    } else {
      // If the response code is not 200, print the response body for debugging
      print('Failed to load futsals: ${response.body}');
      throw Exception('Failed to load futsals');
    }
  }

  // Fetch details of a specific Futsal by ID
  Future<Futsal> getFutsalById(String id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/futsals/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return Futsal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load futsal');
    }
  }

  // Create a Booking
  // Future<Booking> createBooking(String futsalId, String userId) async {
  //   String? token = await _getToken();
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/bookings'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //     body: json.encode({
  //       'futsal_id': futsalId,
  //       'user_id': userId,
  //       'booking_date': DateTime.now().toIso8601String(),
  //       'status': 'pending',
  //     }),
  //   );
  //   if (response.statusCode == 201) {
  //     return Booking.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to create booking');
  //   }
  // }

  // Fetch Team Requests
  Future<List<TeamRequest>> getTeamRequests() async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/team_requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((teamRequest) => TeamRequest.fromJson(teamRequest))
          .toList();
    } else {
      throw Exception('Failed to load team requests');
    }
  }

  // Create a Team Request
  Future<TeamRequest> createTeamRequest(
      String playerId, String teamName) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/team_requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'player_id': playerId,
        'team_name': teamName,
        'request_status': 'pending',
      }),
    );
    if (response.statusCode == 201) {
      return TeamRequest.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create team request');
    }
  }
}
