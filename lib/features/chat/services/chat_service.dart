import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
    debugPrint('╔══════════════════════════════════════════════════════');
    debugPrint('║ [CHAT] createConversation START');
    debugPrint('║  workPermitId   = $workPermitId');
    debugPrint('║  participantName = $participantName');
    debugPrint('║  participantRole = $participantRole');
    debugPrint('║  receiverRole    = $receiverRole');
    debugPrint('║  API endpoint    = POST ${_apiClient.baseUrl}/chat/conversations/');
    debugPrint('╠══════════════════════════════════════════════════════');
    try {
      final payload = {
        "participant_name": participantName,
        "participant_role": participantRole,
        "receiver_role": receiverRole,
        "work_permit_id": workPermitId,
      };
      debugPrint('║  Request body: $payload');

      final response = await _apiClient.post(
        '/chat/conversations/',
        data: payload,
      );
      debugPrint('║  Response status: ${response.statusCode}');
      debugPrint('║  Response data: ${response.data}');

      // 201 = new conversation created
      // 200 = existing conversation returned (server found one for this work permit already)
      if ((response.statusCode == 201 || response.statusCode == 200) && response.data != null) {
        final conv = Conversation.fromJson(response.data);
        final isNew = response.statusCode == 201 ? 'NEW' : 'EXISTING (reopened)';
        debugPrint('║  ✅ Conversation $isNew: id=${conv.id}');
        debugPrint('║  status=${conv.status} participantRole=${conv.participantRole}');
        debugPrint('╚══════════════════════════════════════════════════════');
        return conv;
      } else {
        debugPrint('║  ❌ Unexpected status: ${response.statusCode} — expected 200 or 201');
        debugPrint('╚══════════════════════════════════════════════════════');
      }
    } catch (e) {
      debugPrint('║  ❌ Exception in createConversation: $e');
      debugPrint('╚══════════════════════════════════════════════════════');
    }
    return null;
  }

  Future<List<Conversation>> getConversations() async {
    debugPrint('[CHAT] getConversations: GET ${_apiClient.baseUrl}/chat/conversations/');
    try {
      final response = await _apiClient.get('/chat/conversations/', useCache: false);
      debugPrint('[CHAT] getConversations: status=${response.statusCode}, count=${(response.data as List?)?.length ?? 0}');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint("[CHAT] getConversations ERROR: $e");
    }
    return [];
  }

  Future<ChatHistoryResponse?> getMessageHistory(String conversationId, {int limit = 40}) async {
    debugPrint('╔══════════════════════════════════════════════════════');
    debugPrint('║ [CHAT] getMessageHistory');
    debugPrint('║  conversationId = $conversationId');
    debugPrint('║  limit          = $limit');
    debugPrint('║  API endpoint   = GET ${_apiClient.baseUrl}/chat/conversations/$conversationId/messages/?limit=$limit');
    debugPrint('╠══════════════════════════════════════════════════════');
    try {
      final response = await _apiClient.get(
        '/chat/conversations/$conversationId/messages/',
        queryParameters: {'limit': limit},
        useCache: false,
      );
      debugPrint('║  Response status: ${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        final history = ChatHistoryResponse.fromJson(response.data);
        debugPrint('║  ✅ Loaded ${history.messages.length} messages, hasMore=${history.hasMore}');
        debugPrint('╚══════════════════════════════════════════════════════');
        return history;
      } else {
        debugPrint('║  ❌ Unexpected status: ${response.statusCode}');
        debugPrint('╚══════════════════════════════════════════════════════');
      }
    } catch (e) {
      debugPrint('║  ❌ Exception in getMessageHistory: $e');
      debugPrint('╚══════════════════════════════════════════════════════');
    }
    return null;
  }

  Future<bool> markMessagesAsRead(String conversationId) async {
    debugPrint('[CHAT] markMessagesAsRead: POST ${_apiClient.baseUrl}/chat/conversations/$conversationId/mark_read/');
    try {
      final response = await _apiClient.post('/chat/conversations/$conversationId/mark_read/');
      debugPrint('[CHAT] markMessagesAsRead: status=${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("[CHAT] markMessagesAsRead ERROR: $e");
      return false;
    }
  }

  // WebSocket Methods

  WebSocketChannel? _channel;

  WebSocketChannel? connectWebSocket(String conversationId, {String? token}) {
    final host = _apiClient.baseUri.host;
    final scheme = _apiClient.baseUri.scheme == 'http' ? 'ws' : 'wss';
    debugPrint('╔══════════════════════════════════════════════════════');
    debugPrint('║ [CHAT] connectWebSocket');
    debugPrint('║  conversationId = $conversationId');
    debugPrint('║  host           = $host');
    debugPrint('║  scheme         = $scheme');
    debugPrint('║  token passed?  = ${token != null}');

    try {
      late Uri wsUri;
      if (token != null) {
        wsUri = Uri.parse('$scheme://$host/ws/chat/$conversationId/?token=$token');
        debugPrint('║  Connecting with token in URL (fallback mode)');
      } else {
        wsUri = Uri.parse('$scheme://$host/ws/chat/$conversationId/');
        debugPrint('║  Connecting WITHOUT token (cookie-based auth)');
      }
      debugPrint('║  WebSocket URL  = $wsUri');
      debugPrint('╠══════════════════════════════════════════════════════');
      _channel = WebSocketChannel.connect(wsUri);
      debugPrint('║  ✅ WebSocketChannel created (connection pending handshake)');
      debugPrint('╚══════════════════════════════════════════════════════');
      return _channel;
    } catch (e) {
      debugPrint('║  ❌ WebSocket Connection Error: $e');
      debugPrint('╚══════════════════════════════════════════════════════');
      return null;
    }
  }

  void disconnectWebSocket() {
    debugPrint('[CHAT] disconnectWebSocket: closing channel');
    _channel?.sink.close();
    _channel = null;
  }

  void sendChatMessage(String content) {
    if (_channel != null) {
      final payload = jsonEncode({
        "type": "chat_message",
        "content": content,
      });
      debugPrint('[CHAT] sendChatMessage → $payload');
      _channel!.sink.add(payload);
    } else {
      debugPrint('[CHAT] sendChatMessage SKIPPED — channel is null (WS not connected)');
    }
  }

  void sendReadReceipt() {
    if (_channel != null) {
      final payload = jsonEncode({
        "type": "read_receipt",
      });
      debugPrint('[CHAT] sendReadReceipt → $payload');
      _channel!.sink.add(payload);
    } else {
      debugPrint('[CHAT] sendReadReceipt SKIPPED — channel is null');
    }
  }

  void sendTypingIndicator(String userName) {
    if (_channel != null) {
      final payload = jsonEncode({
        "type": "typing",
        "user_name": userName,
      });
      debugPrint('[CHAT] sendTypingIndicator → $payload');
      _channel!.sink.add(payload);
    } else {
      debugPrint('[CHAT] sendTypingIndicator SKIPPED — channel is null');
    }
  }
}

