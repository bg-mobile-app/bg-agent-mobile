import 'dart:convert';
import 'package:flutter/material.dart';

import '../../common/services/api_client.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key, required this.chat, this.initialMessage});

  final Conversation chat;
  final String? initialMessage;

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
    debugPrint('╔══════════════════════════════════════════════════════');
    debugPrint('║ [CONVO] _initChat START');
    debugPrint('║  conversationId = ${widget.chat.id}');
    debugPrint('║  workPermitId   = ${widget.chat.workPermitId}');
    debugPrint('║  workPermitRef  = ${widget.chat.workPermitRef}');
    debugPrint('║  receiverRole   = ${widget.chat.receiverRole}');
    debugPrint('║  status         = ${widget.chat.status}');
    debugPrint('║  initialMessage = ${widget.initialMessage}');
    debugPrint('╠══════════════════════════════════════════════════════');

    // Step 1: Load message history
    debugPrint('║  STEP 1: Loading message history...');
    final history = await _chatService.getMessageHistory(widget.chat.id);
    if (mounted) {
      setState(() {
        if (history != null) {
          _messages = history.messages;
          debugPrint('║  History loaded: ${_messages.length} messages');
          for (int i = 0; i < _messages.length; i++) {
            final m = _messages[i];
            debugPrint('║    [$i] sender=${m.senderName} role=${m.senderRole} content="${m.content?.substring(0, (m.content?.length ?? 0).clamp(0, 60))}"');
          }
        } else {
          debugPrint('║  History returned null — starting fresh conversation');
        }
        _isLoading = false;
      });

      // Step 2: Mark as read
      debugPrint('║  STEP 2: Marking messages as read...');
      _chatService.markMessagesAsRead(widget.chat.id);
      _scrollToBottom();
    }

    // Step 3: Get cookies for WS (informational)
    debugPrint('║  STEP 3: Checking stored cookies for WS auth...');
    final cookieStr = await ApiClient().tokenStorage.getCookies();
    debugPrint('║  Cookies present? = ${cookieStr != null && cookieStr.isNotEmpty}');
    debugPrint('║  NOTE: web_socket_channel does not use Dio interceptors.');
    debugPrint('║        Connecting WS without token — relies on cookie-based session.');
    debugPrint('║        If WS gets close code 4003, the session is not valid for this conversation.');

    // Step 4: Connect WebSocket
    debugPrint('║  STEP 4: Connecting WebSocket...');
    final channel = _chatService.connectWebSocket(widget.chat.id);

    if (channel == null) {
      debugPrint('║  ❌ WebSocket channel is null — connection failed immediately');
    } else {
      debugPrint('║  ✅ channel obtained — waiting for handshake...');
    }

    // Step 5: Send initial message if history is empty
    if (_messages.isEmpty && widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      debugPrint('║  STEP 5: Sending initial message (history was empty)...');
      debugPrint('║  initialMessage = "${widget.initialMessage}"');
      _chatService.sendChatMessage(widget.initialMessage!);
    } else {
      debugPrint('║  STEP 5: Skipping initial message');
      debugPrint('║    _messages.isEmpty = ${_messages.isEmpty}');
      debugPrint('║    initialMessage    = ${widget.initialMessage}');
    }

    debugPrint('║  STEP 6: Listening to WebSocket stream...');
    channel?.stream.listen(
      (messageStr) {
        debugPrint('[CONVO WS ←] Raw event: $messageStr');
        try {
          final data = jsonDecode(messageStr);
          final type = data['type'];
          debugPrint('[CONVO WS ←] type="$type"');
          if (type == 'chat_message') {
            final msg = ChatMessage.fromJson(data['message']);
            debugPrint('[CONVO WS ←] chat_message: sender=${msg.senderName} role=${msg.senderRole} content="${msg.content}"');
            setState(() {
              _messages.add(msg);
            });
            _scrollToBottom();
            _chatService.sendReadReceipt();
          } else if (type == 'user_status') {
            final isOnline = data['is_online'] == true;
            debugPrint('[CONVO WS ←] user_status: is_online=$isOnline user_id=${data['user_id']} role=${data['role']}');
            setState(() {
              _isOnline = isOnline;
            });
          } else if (type == 'typing') {
            debugPrint('[CONVO WS ←] typing: user_name=${data['user_name']} role=${data['role']}');
          } else if (type == 'read_receipt') {
            debugPrint('[CONVO WS ←] read_receipt: reader_id=${data['reader_id']} role=${data['role']}');
          } else {
            debugPrint('[CONVO WS ←] UNKNOWN type: $type — full data: $data');
          }
        } catch (e) {
          debugPrint('[CONVO WS ←] ❌ Error parsing ws message: $e | raw: $messageStr');
        }
      },
      onDone: () {
        debugPrint('[CONVO WS] ⚠️  WebSocket stream closed (onDone)');
        debugPrint('[CONVO WS]    This may be a close code 4003 (access denied) or normal disconnect.');
      },
      onError: (e) {
        debugPrint('[CONVO WS] ❌ WebSocket Error: $e');
      },
    );
    debugPrint('╚══════════════════════════════════════════════════════');
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

  String _getChatTitle(Conversation item) {
    if (item.workPermitId > 0 && item.workPermitRef?.isNotEmpty == true) {
      return 'WP#${item.workPermitId} (${item.workPermitRef})';
    } else if (item.workPermitId > 0) {
      return 'WP#${item.workPermitId}';
    } else if (item.workPermitRef?.isNotEmpty == true) {
      return 'WP: ${item.workPermitRef}';
    } else if (item.participantName.isNotEmpty) {
      return item.participantName;
    }
    return 'Conversation';
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
                  name: _getChatTitle(widget.chat), 
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attachment feature coming soon')),
                );
              },
              icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                onChanged: (_) => onTyping(),
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
