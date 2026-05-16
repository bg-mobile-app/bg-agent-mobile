import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';
import '../home/dashboard_screen.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';
  String _activeFilter = 'All';

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
    var filtered = _chats;
    
    if (_activeFilter == 'Unread') {
      filtered = filtered.where((c) => c.unreadCount > 0).toList();
    } else if (_activeFilter == 'Online') {
      filtered = filtered.where((c) => c.isOnline).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((chat) {
        return chat.name.toLowerCase().contains(query) ||
            chat.lastMessage.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/chat',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _breadcrumb(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981), shape: BoxShape.circle
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('3 Online', style: TextStyle(color: Color(0xFF0369A1), fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppSearchBar(
                  controller: _searchController,
                  hintText: 'Search conversations...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onSearchTap: () =>
                      setState(() => _searchQuery = _searchController.text),
                ),
                const SizedBox(height: 16),
                _buildFilters(),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      _filteredChats.isEmpty 
                        ? const Center(child: Text('No conversations found.', style: TextStyle(color: AppPalette.textMuted)))
                        : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 80),
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
                      Positioned(
                        bottom: 16,
                        right: 0,
                        child: FloatingActionButton(
                          backgroundColor: AppPalette.brandBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.edit_square, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _breadcrumb() {
    return BreadCrumb(
      items: <BreadCrumbItem>[
        BreadCrumbItem(
          content: Text(
            'Dashboard',
            style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Chat',
            style: AppTextStyles.caption.copyWith(
              color: AppPalette.textStrongBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      divider: const Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Unread', 'Online'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _activeFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppPalette.brandBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppPalette.brandBlue : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
