import 'package:flutter/material.dart';

import '../../common/theme/app_palette.dart';
import 'chat_list_screen.dart';

class ChatConversationScreen extends StatelessWidget {
  const ChatConversationScreen({super.key, required this.chat});

  final ChatItem chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FF),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(chat: chat),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF1F3FF),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                      children: [
                        const Center(child: _DateChip(label: 'Today')),
                        const SizedBox(height: 18),
                        _IncomingMessage(
                          text: chat.lastMessage,
                          time: chat.time,
                        ),
                        const SizedBox(height: 16),
                        const _IncomingMessage(
                          text:
                              "Hello! I've reviewed the documents for the Riyadh route.",
                          time: '10:45 AM',
                        ),
                        const SizedBox(height: 16),
                        const _OutgoingMessage(
                          text:
                              'Great, thanks Sarah. Are they ready for the visa submission?',
                          time: '10:46 AM',
                        ),
                        const SizedBox(height: 16),
                        const _IncomingMessage(
                          text:
                              'Yes, almost. I just need the updated medical clearance for candidate #902.',
                          time: '10:48 AM',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(left: 0, right: 0, bottom: 0, child: _InputDock()),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.chat});

  final ChatItem chat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F3FF),
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
            onPressed: () => Navigator.pop(context),
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
                  _initials(chat.name),
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
                    color: chat.isOnline
                        ? const Color(0xFF004AC6)
                        : const Color(0xFF737686),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFF1F3FF),
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
                  chat.name,
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
                  chat.isOnline ? 'Online' : 'Offline',
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE2F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF434655),
        ),
      ),
    );
  }
}

class _IncomingMessage extends StatelessWidget {
  const _IncomingMessage({required this.text, required this.time});
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
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
    );
  }
}

class _OutgoingMessage extends StatelessWidget {
  const _OutgoingMessage({required this.text, required this.time});
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
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
    );
  }
}

class _InputDock extends StatelessWidget {
  const _InputDock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F3FF),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF737686)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Type a message...',
                      style: TextStyle(color: Color(0xFF737686), fontSize: 16),
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
              onPressed: () {},
              icon: const Icon(Icons.send, color: Color(0xFFEEEFFF)),
            ),
          ),
        ],
      ),
    );
  }
}
