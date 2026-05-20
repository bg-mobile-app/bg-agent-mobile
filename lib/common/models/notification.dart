class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.notificationType,
    this.linkUrl,
  });

  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? notificationType;
  final String? linkUrl;

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['createdAt'] ?? json['created_at'];
    return AppNotificationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(createdRaw?.toString() ?? '') ?? DateTime.now(),
      isRead: json['isRead'] == true || json['is_read'] == true,
      notificationType: json['notification_type']?.toString(),
      linkUrl: json['linkUrl']?.toString() ?? json['link_url']?.toString(),
    );
  }

  AppNotificationItem copyWith({bool? isRead}) {
    return AppNotificationItem(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      notificationType: notificationType,
      linkUrl: linkUrl,
    );
  }
}
