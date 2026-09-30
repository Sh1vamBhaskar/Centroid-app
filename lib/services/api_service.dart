import 'dart:convert';
import '../models/nearby_user.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';

import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class ApiService {
  // IMPORTANT:
  // Replace this with your PC's IPv4 address.
  // Example: http://192.168.1.7:8080
  static const String baseUrl =
      'http://192.168.0.105:8080';

  static final AuthStorage _authStorage = AuthStorage();

  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      data = jsonDecode(response.body);
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final token = data['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception(
          'Login succeeded but no JWT was returned',
        );
      }

      await _authStorage.saveToken(
        token.toString(),
      );

      return data;
    }

    throw Exception(
      data['message'] ??
          data['error'] ??
          'Login failed (${response.statusCode})',
    );
  }
  static Future<void> updateLocation(
      double latitude,
      double longitude,
      ) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/location'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    Map<String, dynamic> errorData = {};

    if (response.body.isNotEmpty) {
      try {
        errorData = jsonDecode(response.body)
        as Map<String, dynamic>;
      } catch (_) {
        // Response was not JSON.
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      errorData['message'] ??
          errorData['error'] ??
          'Unable to update location',
    );
  }
  static Future<void> sendInteraction(
      int receiverId,
      ) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/interactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiverId': receiverId,
      }),
    );

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      data = jsonDecode(response.body);
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      data['message'] ??
          data['error'] ??
          'Unable to send connection request',
    );
  }
  static Future<Map<String, dynamic>> getInteractionStatus(
      int userId,
      ) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/interactions/status/$userId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body)
      as Map<String, dynamic>;
    }

    Map<String, dynamic> errorData = {};

    if (response.body.isNotEmpty) {
      errorData = jsonDecode(response.body);
    }

    throw Exception(
      errorData['message'] ??
          errorData['error'] ??
          'Unable to get interaction status',
    );
  }
  static Future<List<Map<String, dynamic>>>
  getPendingInteractions() async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/interactions/pending'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final List<dynamic> data =
      jsonDecode(response.body);

      return data
          .map((item) =>
      item as Map<String, dynamic>)
          .toList();
    }

    Map<String, dynamic> errorData = {};

    if (response.body.isNotEmpty) {
      errorData = jsonDecode(response.body);
    }

    throw Exception(
      errorData['message'] ??
          errorData['error'] ??
          'Unable to load requests',
    );
  }

  static Future<void> acceptInteraction(
      int interactionId,
      ) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/interactions/$interactionId/accept',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    Map<String, dynamic> errorData = {};

    if (response.body.isNotEmpty) {
      errorData = jsonDecode(response.body);
    }

    throw Exception(
      errorData['message'] ??
          errorData['error'] ??
          'Unable to accept request',
    );
  }

  static Future<void> declineInteraction(
      int interactionId,
      ) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/interactions/$interactionId/decline',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    Map<String, dynamic> errorData = {};

    if (response.body.isNotEmpty) {
      errorData = jsonDecode(response.body);
    }

    throw Exception(
      errorData['message'] ??
          errorData['error'] ??
          'Unable to decline request',
    );
  }
  static Future<Map<String, dynamic>> getMyProfile() async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/profile/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body)
      as Map<String, dynamic>;
    }

    Map<String, dynamic> errorData = {};

    if (response.body.isNotEmpty) {
      try {
        errorData = jsonDecode(response.body)
        as Map<String, dynamic>;
      } catch (_) {
        // Response was not JSON.
      }
    }

    throw Exception(
      errorData['message'] ??
          errorData['error'] ??
          'Unable to load profile',
    );
  }
  static Future<Map<String, dynamic>> updateProfile({
    required String displayName,
    String? profilePicture,
    String? socialLink,
    String? bio,
  }) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/profile/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'displayName': displayName,
        'profilePicture': profilePicture,
        'socialLink': socialLink,
        'bio': bio,
      }),
    );

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body)
        as Map<String, dynamic>;
      } catch (_) {
        // Response was not JSON.
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ??
          data['error'] ??
          'Unable to update profile',
    );
  }

  static Future<void> logout() async {
    await _authStorage.clearToken();
  }
  static Future<List<NearbyUser>> getNearbyUsers(
      double radius,
      ) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final uri = Uri.parse(
      '$baseUrl/api/location/nearby',
    ).replace(
      queryParameters: {
        'radius': radius.round().toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final List<dynamic> data =
      jsonDecode(response.body);

      return data
          .map(
            (json) => NearbyUser.fromJson(
          json as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    Map<String, dynamic> errorData = {};

    if (response.body.isNotEmpty) {
      errorData = jsonDecode(response.body);
    }

    throw Exception(
      errorData['message'] ??
          errorData['error'] ??
          'Unable to load nearby users',
    );
  }
  static Future<Conversation> createConversationFromInteraction(
      int interactionId,
      ) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/conversations/from-interaction/$interactionId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Conversation.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Unable to create conversation (${response.statusCode})',
    );
  }
  static Future<List<ChatMessage>> getMessages(
      int conversationId,
      ) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/messages/$conversationId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
      jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => ChatMessage.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      'Unable to load messages (${response.statusCode})',
    );
  }
  static Future<List<Map<String, dynamic>>> getMyConversations() async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login again');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/conversations'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      throw Exception('Invalid conversations response');
    }

    Map<String, dynamic> errorData = {};

    if (response.body.isNotEmpty) {
      try {
        errorData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}
    }

    throw Exception(
      errorData['message'] ??
          errorData['error'] ??
          'Unable to load conversations',
    );
  }
}