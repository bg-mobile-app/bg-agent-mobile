import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/models/notification.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'services/notifications_service.dart';
import 'dashboard_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = false;
  List<AppNotificationItem> _notifications = [];
  final NotificationsService _notificationsService = NotificationsService();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _loading = true);
    final notifications = await _notificationsService.fetchNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = notifications;
      _loading = false;
    });
  }

  Future<void> _markRead(int id) async {
    if (_loading) return;
    setState(() => _loading = true);
    final success = await _notificationsService.markRead(id: id);
    if (!mounted) return;
    setState(() {
      if (success) {
        _notifications = _notifications
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList();
      }
      _loading = false;
    });
  }

  Future<void> _takeAction(AppNotificationItem notification) async {
    if (notification.isRead) {
      await _openNotificationLink(notification.linkUrl);
      return;
    }

    if (_loading) return;
    setState(() => _loading = true);

    final previousNotifications = _notifications;
    setState(() {
      _notifications = _notifications
          .map((n) => n.id == notification.id ? n.copyWith(isRead: true) : n)
          .toList();
    });

    final success = await _notificationsService.markRead(id: notification.id);
    if (!mounted) return;

    if (!success) {
      setState(() {
        _notifications = previousNotifications;
        _loading = false;
      });
      return;
    }

    await _openNotificationLink(notification.linkUrl);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _openNotificationLink(String? linkUrl) async {
    if (linkUrl == null || linkUrl.trim().isEmpty) return;
    final sanitizedUrl = linkUrl.trim();
    if (sanitizedUrl.startsWith('/')) {
      if (!mounted) return;
      context.go(sanitizedUrl);
      return;
    }

    final uri = Uri.tryParse(sanitizedUrl);
    if (uri == null) return;
    final shouldOpenExternal =
        uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!shouldOpenExternal) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _markAllRead() async {
    if (_loading) return;
    setState(() => _loading = true);
    final success = await _notificationsService.markRead(id: 'ALL');
    if (!mounted) return;
    setState(() {
      if (success) {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/notifications',
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: _loading && _notifications.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _breadcrumb(),
                          const SizedBox(height: 8),
                          Text(
                            'Notifications',
                            style: AppTextStyles.headline2.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your latest activity and alerts.',
                            style: AppTextStyles.body2.copyWith(
                              color: AppPalette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (_notifications.any((n) => !n.isRead))
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _markAllRead,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppPalette.borderSoftBlue,
                                  ),
                                ),
                                icon: const Icon(Icons.done_all),
                                label: const Text('Mark all as read'),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppPalette.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppPalette.borderSoftBlue,
                              ),
                              boxShadow: AppPalette.cardShadow,
                            ),
                            child: _notifications.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 80),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.inbox_outlined,
                                            size: 48,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Your inbox is empty',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppPalette.textMuted,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "We'll notify you when something happens.",
                                            style: TextStyle(
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _notifications
                                        .map((n) => _notificationItem(n))
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
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
            'Notifications',
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

  Widget _notificationItem(AppNotificationItem n) {
    return Container(
      decoration: BoxDecoration(
        color: n.isRead ? AppPalette.surface : const Color(0x050B61FF),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: n.isRead ? const Color(0xFFF1F5F9) : AppPalette.brandBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications,
              size: 18,
              color: n.isRead ? const Color(0xFF94A3B8) : Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 420;
                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: n.isRead
                                  ? AppPalette.textMuted
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeAgo(n.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: n.isRead
                                  ? AppPalette.textMuted
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          timeAgo(n.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  n.message,
                  style: const TextStyle(color: AppPalette.textMuted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (n.linkUrl != null && n.linkUrl!.trim().isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: _loading ? null : () => _takeAction(n),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppPalette.borderSoftBlue,
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Take Action'),
                      ),
                    if (!n.isRead)
                      TextButton(
                        onPressed: () => _markRead(n.id),
                        child: const Text('Mark as read'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String timeAgo(DateTime? date) {
  if (date == null) return 'N/A';
  final seconds = DateTime.now().difference(date).inSeconds;
  if (seconds < 5) return 'just now';

  const intervals = [
    ('year', 31536000),
    ('month', 2592000),
    ('week', 604800),
    ('day', 86400),
    ('hour', 3600),
    ('min', 60),
    ('sec', 1),
  ];

  for (final interval in intervals) {
    final count = seconds ~/ interval.$2;
    if (count >= 1) {
      return '$count ${interval.$1}${count > 1 ? 's' : ''} ago';
    }
  }
  return 'just now';
}
