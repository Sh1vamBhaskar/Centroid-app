import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/chat_message.dart';
import 'api_service.dart';
import 'auth_storage.dart';

class ChatService {
  StompClient? _stompClient;

  final AuthStorage _authStorage = AuthStorage();

  bool get isConnected =>
      _stompClient?.connected ?? false;

  Future<void> connect({
    required int conversationId,
    required Function(ChatMessage message) onMessage,
    required Function() onConnected,
    required Function(String error) onError,
  }) async {
    final token = await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      onError('Please login again');
      return;
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: '${ApiService.baseUrl.replaceFirst('http', 'ws')}/ws',

        // JWT sent during STOMP CONNECT.
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },

        // Also supplied at WebSocket handshake level.
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },

        onConnect: (StompFrame frame) {
          _stompClient!.subscribe(
            destination:
            '/topic/chat/$conversationId',
            callback: (StompFrame frame) {
              if (frame.body == null ||
                  frame.body!.isEmpty) {
                return;
              }

              try {
                final data =
                jsonDecode(frame.body!)
                as Map<String, dynamic>;

                final message =
                ChatMessage.fromJson(data);

                onMessage(message);
              } catch (e) {
                onError(
                  'Unable to read incoming message',
                );
              }
            },
          );

          onConnected();
        },

        onWebSocketError: (dynamic error) {
          onError(
            'WebSocket error: $error',
          );
        },

        onStompError: (StompFrame frame) {
          onError(
            frame.body ??
                'STOMP connection error',
          );
        },

        onDisconnect: (StompFrame frame) {
          // Connection closed.
        },

        reconnectDelay:
        const Duration(seconds: 3),
      ),
    );

    _stompClient!.activate();
  }

  void sendMessage({
    required int conversationId,
    required String content,
  }) {
    if (!isConnected) {
      return;
    }

    _stompClient!.send(
      destination: '/app/chat',
      body: jsonEncode({
        'conversationId': conversationId,
        'content': content,
      }),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}