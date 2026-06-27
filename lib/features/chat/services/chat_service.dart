import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';

import '../../../common/services/api_client.dart';
import '../models/chat_models.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiClient _apiClient = ApiClient();

  // REST API Endpoints

  Future<Conversation?> createConversation({
    required String workPermitId,
    String participantName = "Customer1",
    String participantRole = "CUSTOMER",
    String receiverRole = "CALL_CENTER",
  }) async {
    try {
      final response = await _apiClient.post(
        '/chat/conversations/',
        data: {
          "participant_name": participantName,
          "participant_role": participantRole,
          "receiver_role": receiverRole,
          "work_permit_id": workPermitId,
        },
      );
      if (response.statusCode == 201 && response.data != null) {
        return Conversation.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Error creating conversation: $e");
    }
    return null;
  }

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _apiClient.get('/chat/conversations/', useCache: false);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching conversations: $e");
    }
    return [];
  }

  Future<ChatHistoryResponse?> getMessageHistory(String conversationId, {int limit = 40}) async {
    try {
      final response = await _apiClient.get(
        '/chat/conversations/$conversationId/messages/',
        queryParameters: {'limit': limit},
        useCache: false,
      );
      if (response.statusCode == 200 && response.data != null) {
        return ChatHistoryResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Error fetching message history: $e");
    }
    return null;
  }

  Future<bool> markMessagesAsRead(String conversationId) async {
    try {
      final response = await _apiClient.post('/chat/conversations/$conversationId/mark_read/');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error marking messages as read: $e");
      return false;
    }
  }

  // WebSocket Methods

  WebSocketChannel? _channel;

  WebSocketChannel? connectWebSocket(String conversationId, {String? token}) {
    final host = _apiClient.baseUri.host;
    final scheme = _apiClient.baseUri.scheme == 'http' ? 'ws' : 'wss';
    final wsUrl = Uri.parse('$scheme://$host/ws/chat/$conversationId/');
    
    // In many WS clients, we can pass headers. Using web_socket_channel we can pass headers on IO.
    // However, as a fallback, we pass token in URL.
    try {
      if (token != null) {
         final uriWithToken = Uri.parse('$scheme://$host/ws/chat/$conversationId/?token=$token');
         _channel = WebSocketChannel.connect(uriWithToken);
      } else {
         _channel = WebSocketChannel.connect(wsUrl);
      }
      return _channel;
    } catch (e) {
      debugPrint("WebSocket Connection Error: $e");
      return null;
    }
  }

  void disconnectWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  void sendChatMessage(String content) {
    if (_channel != null) {
      final payload = jsonEncode({
        "type": "chat_message",
        "content": content,
      });
      _channel!.sink.add(payload);
    }
  }

  void sendReadReceipt() {
    if (_channel != null) {
      final payload = jsonEncode({
        "type": "read_receipt",
      });
      _channel!.sink.add(payload);
    }
  }

  void sendTypingIndicator(String userName) {
    if (_channel != null) {
      final payload = jsonEncode({
        "type": "typing",
        "user_name": userName,
      });
      _channel!.sink.add(payload);
    }
  }
}
