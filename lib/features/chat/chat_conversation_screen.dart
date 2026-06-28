import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/services/api_client.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';

// ─── Palette ─────────────────────────────────────────────────────────────────
const Color _blue = Color(0xFF2563EB);
const Color _darkBlue = Color(0xFF004AC6);
const Color _bgChat = Color(0xFFDCE7F7);
const Color _outline = Color(0xFFC3C6D7);
const Color _mutedText = Color(0xFF737686);
const Color _bodyText = Color(0xFF434655);

// ─── Pending attachment data class ───────────────────────────────────────────

class _PendingAttachment {
  _PendingAttachment({required this.file, required this.name});
  final File file;
  final String name;

  bool get isImage {
    final ext = name.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp');
  }

  bool get isPdf => name.toLowerCase().endsWith('.pdf');

  String get sizeLabel {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.chat,
    this.initialMessage,
  });

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
  bool _isSending = false;

  /// File staged for sending — user sees a preview before they confirm send
  _PendingAttachment? _pendingAttachment;

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
    debugPrint('║  workPermitRef  = ${widget.chat.workPermitRef}');
    debugPrint('║  initialMessage = ${widget.initialMessage}');
    debugPrint('╠══════════════════════════════════════════════════════');

    final history = await _chatService.getMessageHistory(widget.chat.id);
    if (mounted) {
      setState(() {
        if (history != null) {
          _messages = history.messages;
          debugPrint('║  History loaded: ${_messages.length} messages');
        }
        _isLoading = false;
      });
      _chatService.markMessagesAsRead(widget.chat.id);
      _scrollToBottom();
    }

    final cookieStr = await ApiClient().tokenStorage.getCookies();
    debugPrint('║  Cookies present? = ${cookieStr != null && cookieStr.isNotEmpty}');
    final channel = _chatService.connectWebSocket(widget.chat.id);

    if (_messages.isEmpty &&
        widget.initialMessage != null &&
        widget.initialMessage!.isNotEmpty) {
      _chatService.sendChatMessage(widget.initialMessage!);
    }

    channel?.stream.listen(
      (messageStr) {
        debugPrint('[CONVO WS ←] Raw: $messageStr');
        try {
          final data = jsonDecode(messageStr as String);
          final type = data['type'];
          if (type == 'chat_message') {
            final msg = ChatMessage.fromJson(data['message']);
            if (mounted) {
              setState(() => _messages.add(msg));
              _scrollToBottom();
              _chatService.sendReadReceipt();
            }
          } else if (type == 'user_status') {
            if (mounted) setState(() => _isOnline = data['is_online'] == true);
          } else if (type == 'typing') {
            debugPrint('[CONVO WS ←] typing: ${data['user_name']}');
          } else if (type == 'read_receipt') {
            debugPrint('[CONVO WS ←] read_receipt');
          }
        } catch (e) {
          debugPrint('[CONVO WS ←] ❌ Parse error: $e');
        }
      },
      onDone: () => debugPrint('[CONVO WS] ⚠️ Stream closed'),
      onError: (e) => debugPrint('[CONVO WS] ❌ Error: $e'),
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

  // ─── Scroll ──────────────────────────────────────────────────────────────────

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

  // ─── Send text ───────────────────────────────────────────────────────────────

  void _sendMessage() {
    // If there's a staged attachment, send it first
    if (_pendingAttachment != null) {
      _sendPendingAttachment();
      return;
    }
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _chatService.sendChatMessage(text);
    _inputController.clear();
  }

  // ─── Attachment picker sheet ─────────────────────────────────────────────────

  void _showAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Send Attachment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a file type to attach',
                  style: TextStyle(fontSize: 13, color: _mutedText),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AttachOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFF7C3AED),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    _AttachOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFF059669),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _AttachOption(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'PDF',
                      color: const Color(0xFFDC2626),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickFile(['pdf']);
                      },
                    ),
                    _AttachOption(
                      icon: Icons.insert_drive_file_rounded,
                      label: 'File',
                      color: const Color(0xFF0284C7),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickFile(null);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Pick helpers ────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return;
      _setStagedAttachment(File(picked.path), picked.name);
    } catch (e) {
      debugPrint('[ATTACH] pickImage error: $e');
      if (mounted) _showError('Could not open image picker.');
    }
  }

  Future<void> _pickFile(List<String>? allowedExtensions) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final pf = result.files.first;
      if (pf.path == null) return;
      _setStagedAttachment(File(pf.path!), pf.name);
    } catch (e) {
      debugPrint('[ATTACH] pickFile error: $e');
      if (mounted) _showError('Could not open file picker.');
    }
  }

  /// Stage the chosen file — show preview in the input area, don't upload yet
  void _setStagedAttachment(File file, String name) {
    if (!mounted) return;
    setState(() {
      _pendingAttachment = _PendingAttachment(file: file, name: name);
    });
    // Give the list a moment to repaint, then scroll to bottom so the user
    // sees the preview dock
    _scrollToBottom();
  }

  void _clearStagedAttachment() {
    setState(() => _pendingAttachment = null);
  }

  // ─── Upload & send ───────────────────────────────────────────────────────────

  Future<void> _sendPendingAttachment() async {
    final attachment = _pendingAttachment;
    final text = _inputController.text.trim();
    if (attachment == null) return;

    setState(() => _isSending = true);

    debugPrint('[ATTACH] Uploading: ${attachment.name} (${attachment.sizeLabel})');

    try {
      final apiClient = ApiClient();

      final formData = FormData.fromMap({
        'attachment': await MultipartFile.fromFile(
          attachment.file.path,
          filename: attachment.name,
        ),
        if (text.isNotEmpty) 'content': text,
        'conversation_id': widget.chat.id,
      });

      // Must override Content-Type so Dio sends multipart/form-data
      // (the global header is application/json which would break multipart)
      final response = await apiClient.post(
        '/chat/conversations/${widget.chat.id}/attachments/',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );

      debugPrint('[ATTACH] Response: ${response.statusCode} — ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[ATTACH] ✅ Upload successful — message will arrive via WS');
        _inputController.clear();
        _clearStagedAttachment();
      } else {
        _showError('Upload failed (${response.statusCode}). Please retry.');
      }
    } catch (e) {
      debugPrint('[ATTACH] ❌ Upload error: $e');
      if (mounted) {
        _showError(
          'Could not send attachment. '
          'Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFDC2626),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

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

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      final h = dt.hour > 12
          ? dt.hour - 12
          : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } catch (_) {
      return '';
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgChat,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              name: _getChatTitle(widget.chat),
              isOnline: _isOnline,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue))
                  : _messages.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isSender = msg.senderRole == 'CUSTOMER';
                        return isSender
                            ? _SenderBubble(
                                msg: msg,
                                time: _formatTime(msg.timestamp),
                              )
                            : _ReceiverBubble(
                                msg: msg,
                                time: _formatTime(msg.timestamp),
                              );
                      },
                    ),
            ),

            // ── Pending attachment preview strip ─────────────────────────────
            if (_pendingAttachment != null)
              _PendingAttachmentStrip(
                attachment: _pendingAttachment!,
                onRemove: _clearStagedAttachment,
              ),

            // ── Input dock ───────────────────────────────────────────────────
            _InputDock(
              controller: _inputController,
              onSend: _sendMessage,
              onAttach: _showAttachmentSheet,
              onTyping: () => _chatService.sendTypingIndicator(''),
              isSending: _isSending,
              hasPendingAttachment: _pendingAttachment != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 34,
              color: _blue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _bodyText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Say hello to start the conversation!',
            style: TextStyle(fontSize: 13, color: _mutedText),
          ),
        ],
      ),
    );
  }
}

// ─── Pending Attachment Strip ─────────────────────────────────────────────────

class _PendingAttachmentStrip extends StatelessWidget {
  const _PendingAttachmentStrip({
    required this.attachment,
    required this.onRemove,
  });

  final _PendingAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _blue.withValues(alpha: 0.15)),
          bottom: BorderSide(color: _outline.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        children: [
          // Preview thumbnail or icon
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: attachment.isImage
                ? Image.file(
                    attachment.file,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _fileIconBox(Icons.broken_image_rounded, const Color(0xFF94A3B8)),
                  )
                : _fileIconBox(
                    attachment.isPdf
                        ? Icons.picture_as_pdf_rounded
                        : Icons.insert_drive_file_rounded,
                    attachment.isPdf
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF0284C7),
                  ),
          ),
          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        attachment.isImage
                            ? 'Image'
                            : attachment.isPdf
                            ? 'PDF'
                            : 'File',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      attachment.sizeLabel,
                      style: const TextStyle(fontSize: 11, color: _mutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to send — tap ➤ to confirm',
                  style: TextStyle(
                    fontSize: 11,
                    color: _blue.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Color(0xFFDC2626),
              ),
            ),
            tooltip: 'Remove attachment',
          ),
        ],
      ),
    );
  }

  Widget _fileIconBox(IconData icon, Color color) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.name,
    required this.isOnline,
    required this.onBack,
  });

  final String name;
  final bool isOnline;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFDCE7F7),
        border: Border(bottom: BorderSide(color: _outline)),
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
            icon: const Icon(Icons.arrow_back, color: _darkBlue),
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
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF737686),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDCE7F7), width: 2),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _darkBlue,
                  ),
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isOnline ? const Color(0xFF16A34A) : _mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String nameStr) {
    final parts = nameStr.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ─── Sender Bubble (CUSTOMER — right, blue) ──────────────────────────────────

class _SenderBubble extends StatelessWidget {
  const _SenderBubble({required this.msg, required this.time});

  final ChatMessage msg;
  final String time;

  @override
  Widget build(BuildContext context) {
    final hasAttachment =
        msg.attachmentUrl != null && msg.attachmentUrl!.isNotEmpty;
    final hasText = msg.content != null && msg.content!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.72,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: hasAttachment ? 10 : 16,
                  vertical: hasAttachment ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasAttachment)
                      _BubbleAttachment(
                        url: msg.attachmentUrl!,
                        name: msg.attachmentName,
                        isSender: true,
                      ),
                    if (hasAttachment && hasText) const SizedBox(height: 8),
                    if (hasText)
                      Text(
                        msg.content!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 15,
                    color: msg.isRead ? _darkBlue : _mutedText,
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

// ─── Receiver Bubble (other roles — left, white) ─────────────────────────────

class _ReceiverBubble extends StatelessWidget {
  const _ReceiverBubble({required this.msg, required this.time});

  final ChatMessage msg;
  final String time;

  @override
  Widget build(BuildContext context) {
    final hasAttachment =
        msg.attachmentUrl != null && msg.attachmentUrl!.isNotEmpty;
    final hasText = msg.content != null && msg.content!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.72,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.senderName != null && msg.senderName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    msg.senderName!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _darkBlue,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: hasAttachment ? 10 : 16,
                  vertical: hasAttachment ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border:
                      Border.all(color: _outline.withValues(alpha: 0.5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasAttachment)
                      _BubbleAttachment(
                        url: msg.attachmentUrl!,
                        name: msg.attachmentName,
                        isSender: false,
                      ),
                    if (hasAttachment && hasText) const SizedBox(height: 8),
                    if (hasText)
                      Text(
                        msg.content!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: _bodyText,
                          height: 1.4,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _mutedText,
                    fontWeight: FontWeight.w500,
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

// ─── Attachment inside a bubble ───────────────────────────────────────────────

class _BubbleAttachment extends StatelessWidget {
  const _BubbleAttachment({
    required this.url,
    required this.name,
    required this.isSender,
  });

  final String url;
  final String? name;
  final bool isSender;

  bool get _isImage {
    final lower = url.toLowerCase().split('?').first;
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _FullScreenImageViewer(url: url),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                width: double.infinity,
                height: 160,
                color: isSender
                    ? Colors.white.withValues(alpha: 0.15)
                    : const Color(0xFFF1F5FF),
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                        : null,
                    color: isSender ? Colors.white : _blue,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => _fileChip(),
          ),
        ),
      );
    }
    return _fileChip();
  }

  Widget _fileChip() {
    final isPdf = (name ?? url).toLowerCase().endsWith('.pdf');
    final textColor = isSender ? Colors.white : _bodyText;
    final iconColor = isSender
        ? Colors.white70
        : (isPdf ? const Color(0xFFDC2626) : _darkBlue);
    final bgColor = isSender
        ? Colors.white.withValues(alpha: 0.15)
        : (isPdf
            ? const Color(0xFFDC2626).withValues(alpha: 0.08)
            : const Color(0xFFEFF4FF));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPdf
                ? Icons.picture_as_pdf_rounded
                : Icons.insert_drive_file_rounded,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              name ?? 'Attachment',
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Attach option tile ───────────────────────────────────────────────────────

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input Dock ───────────────────────────────────────────────────────────────

class _InputDock extends StatelessWidget {
  const _InputDock({
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.onTyping,
    required this.isSending,
    required this.hasPendingAttachment,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onTyping;
  final bool isSending;
  final bool hasPendingAttachment;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: hasPendingAttachment
                ? _blue.withValues(alpha: 0.25)
                : const Color(0xFFEEF2FF),
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach button — show filled/active when attachment staged
          IconButton(
            onPressed: isSending ? null : onAttach,
            icon: Icon(
              hasPendingAttachment
                  ? Icons.attach_file_rounded
                  : Icons.add_circle_outline_rounded,
              color: hasPendingAttachment ? _blue : _darkBlue,
              size: 26,
            ),
            tooltip: 'Attach file',
          ),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDEE4FF)),
              ),
              child: TextField(
                controller: controller,
                onChanged: (_) => onTyping(),
                onSubmitted: (_) => onSend(),
                enabled: !isSending,
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF0B1C30),
                ),
                decoration: InputDecoration(
                  hintText: hasPendingAttachment
                      ? 'Add a caption… (optional)'
                      : 'Type a message…',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button — shows spinner while uploading
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSending
                    ? [const Color(0xFF64748B), const Color(0xFF475569)]
                    : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: _blue.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isSending
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: onSend,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Full Screen Image Viewer ────────────────────────────────────────────────

class _FullScreenImageViewer extends StatelessWidget {
  const _FullScreenImageViewer({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
