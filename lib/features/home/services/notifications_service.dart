import 'package:flutter/foundation.dart';

import '../../../common/models/notification.dart';
import '../../../common/services/api_client.dart';

class NotificationsService {
  NotificationsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<AppNotificationItem>> fetchNotifications() async {
    try {
      final response = await _apiClient.get('/main/notifications/');
      final data = response.data;

      final List rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['results'] is List) {
        rawList = data['results'] as List;
      } else {
        rawList = const [];
      }

      return rawList.whereType<Map<String, dynamic>>().map(AppNotificationItem.fromJson).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<bool> markRead({required dynamic id}) async {
    try {
      await _apiClient.post('/main/notifications/mark-read/', data: {'id': id});
      return true;
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
      return false;
    }
  }
}
