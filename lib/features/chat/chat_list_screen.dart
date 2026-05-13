import 'package:flutter/material.dart';

import '../../common/theme/app_palette.dart';
import '../../common/widgets/app_search_bar.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  final List<ChatItem> _chats = const [
    ChatItem(
      name: 'Rakib Hasan',
      lastMessage: 'Brother, I uploaded my passport copy. Please check once.',
      time: '10:45 AM',
      unreadCount: 2,
      isOnline: true,
    ),
    ChatItem(
      name: 'Nusrat Jahan',
      lastMessage: 'Thanks. I will complete the payment by tonight.',
      time: '9:12 AM',
      unreadCount: 0,
      isOnline: false,
    ),
    ChatItem(
      name: 'Mehedi Rahman',
      lastMessage: 'When is my visa appointment date?',
      time: 'Yesterday',
      unreadCount: 4,
      isOnline: true,
    ),
    ChatItem(
      name: 'Farida Begum',
      lastMessage: 'Received the ticket details, thank you so much.',
      time: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
    ),
    ChatItem(
      name: 'Jahidul Islam',
      lastMessage: 'Please call me when the BG sent passport is ready.',
      time: 'Mon',
      unreadCount: 1,
      isOnline: true,
    ),
    ChatItem(
      name: 'Tahmid Chowdhury',
      lastMessage: 'I just sent the additional documents in email.',
      time: 'Sun',
      unreadCount: 0,
      isOnline: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatItem> get _filteredChats {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _chats;
    return _chats.where((chat) {
      return chat.name.toLowerCase().contains(query) ||
          chat.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chat',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              AppSearchBar(
                controller: _searchController,
                hintText: 'Find a chat',
                onChanged: (value) => setState(() => _searchQuery = value),
                onSearchTap: () =>
                    setState(() => _searchQuery = _searchController.text),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredChats.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _filteredChats[index];
                    return _ChatCard(
                      item: item,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatConversationScreen(chat: item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({required this.item, required this.onTap});

  final ChatItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white),
          boxShadow: AppPalette.cardShadow,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFE2E8F0),
                  child: Text(
                    _initials(item.name),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                if (item.isOnline)
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.brandBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: item.unreadCount > 0
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (item.unreadCount > 0)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppPalette.brandBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${item.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
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

class ChatItem {
  const ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
  });

  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
}
