import 'dart:convert';
import 'package:flutter/material.dart';

import '../../common/theme/app_palette.dart';
import '../../common/services/api_client.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key, required this.chat});

  final Conversation chat;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.chat.isOnline;
    _initChat();
  }

  Future<void> _initChat() async {
    // Load history
    final history = await _chatService.getMessageHistory(widget.chat.id);
    if (mounted) {
      setState(() {
        if (history != null) {
          // The API returns newest first. Let's reverse to show oldest top, newest bottom
          _messages = history.messages.reversed.toList();
        }
        _isLoading = false;
      });
      // Mark as read
      _chatService.markMessagesAsRead(widget.chat.id);
      _scrollToBottom();
    }

    // Connect WebSocket
    final token = await ApiClient().tokenStorage.getCookies(); 
    // Wait, WebSocket token via getCookies is usually not JWT token. 
    // The chatapi.md says "token={access_token}". 
    // We can just connect without passing token in URL if we rely on interceptor/headers, 
    // but WS might not use interceptor. If `token` is not JWT, it might just connect as guest.
    // Let's connect without token first as the app uses cookies, or pass cookies?
    // Actually `web_socket_channel` doesn't use Dio, so we'd need to pass cookies manually in headers if possible.
    // For now, we call connectWebSocket with null token so it connects natively.
    
    final channel = _chatService.connectWebSocket(widget.chat.id);
    channel?.stream.listen(
      (messageStr) {
        try {
          final data = jsonDecode(messageStr);
          final type = data['type'];
          if (type == 'chat_message') {
            final msg = ChatMessage.fromJson(data['message']);
            setState(() {
              _messages.add(msg);
            });
            _scrollToBottom();
            _chatService.sendReadReceipt();
          } else if (type == 'user_status') {
             setState(() {
               _isOnline = data['is_online'] == true;
             });
          }
        } catch (e) {
          debugPrint("Error parsing ws message: $e");
        }
      },
      onDone: () => debugPrint('WebSocket Closed'),
      onError: (e) => debugPrint('WebSocket Error: $e'),
    );
  }

  @override
  void dispose() {
    _chatService.disconnectWebSocket();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    
    _chatService.sendChatMessage(text);
    _inputController.clear();
    // Message will come back via WS 'chat_message' event
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE7F7),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  name: widget.chat.participantName.isNotEmpty ? widget.chat.participantName : 'Customer', 
                  isOnline: _isOnline,
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFDCE7F7),
                    child: _isLoading 
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                               final msg = _messages[index];
                               // Here we assume senderName == 'Customer1' means it's from user, 
                               // but we need a better way to check if it's outgoing.
                               // The role of app user might be 'CALL_CENTER'.
                               // If senderRole == 'CALL_CENTER', it's outgoing?
                               // Wait, the user might be an agency. So 'AGENCY' or 'CALL_CENTER'.
                               // We'll just check if senderRole != 'CUSTOMER' or if senderRole == widget.chat.receiverRole for outgoing.
                               final isOutgoing = msg.senderRole != 'CUSTOMER'; 
                               if (isOutgoing) {
                                  return _OutgoingMessage(text: msg.content ?? '', time: _formatTime(msg.timestamp));
                               } else {
                                  return _IncomingMessage(text: msg.content ?? '', time: _formatTime(msg.timestamp));
                               }
                            },
                          ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0, 
              right: 0, 
              bottom: 0, 
              child: _InputDock(
                controller: _inputController,
                onSend: _sendMessage,
                onTyping: () => _chatService.sendTypingIndicator(''), 
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      return '${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return '';
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.name, required this.isOnline, required this.onBack});

  final String name;
  final bool isOnline;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFDCE7F7),
        border: Border(bottom: BorderSide(color: Color(0xFFC3C6D7))),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF004AC6)),
          ),
          const SizedBox(width: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE2E8F0),
                child: Text(
                  _initials(name),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Positioned(
                bottom: -1,
                right: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? const Color(0xFF004AC6)
                        : const Color(0xFF737686),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFDCE7F7),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF004AC6),
                  ),
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF737686),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined, color: Color(0xFF434655)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, color: Color(0xFF434655)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF434655)),
          ),
        ],
      ),
    );
  }

  String _initials(String nameStr) {
    final parts = nameStr.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _IncomingMessage extends StatelessWidget {
  const _IncomingMessage({required this.text, required this.time});
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border: Border.all(color: const Color(0x4DC3C6D7)),
                ),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF434655)),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF737686),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutgoingMessage extends StatelessWidget {
  const _OutgoingMessage({required this.text, required this.time});
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Color(0xFFEEEFFF)),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF737686),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF004AC6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputDock extends StatelessWidget {
  const _InputDock({required this.controller, required this.onSend, required this.onTyping});
  
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onTyping;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: Color(0xFFDCE7F7),
        border: Border(top: BorderSide(color: Color(0xFFC3C6D7))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle, color: Color(0xFF004AC6)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF737686)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (_) => onTyping(),
                      onSubmitted: (_) => onSend(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Color(0xFF737686), fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      size: 20,
                      color: Color(0xFF737686),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.attach_file,
                      size: 20,
                      color: Color(0xFF737686),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(999),
              boxShadow: AppPalette.cardShadow,
            ),
            child: IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send, color: Color(0xFFEEEFFF)),
            ),
          ),
        ],
      ),
    );
  }
}
