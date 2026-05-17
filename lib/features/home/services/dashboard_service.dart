import 'package:flutter/foundation.dart';

import '../../../common/services/api_client.dart';
import '../models/dashboard_models.dart';

class DashboardService {
  DashboardService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AgencyDashboardStats> getAgencyDashboard(String period) async {
    try {
      final response = await _apiClient.get(
        '/filter/agency/stats/',
        queryParameters: {'period': period},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AgencyDashboardStats.fromJson(data);
      }
      if (data is Map) {
        return AgencyDashboardStats.fromJson(Map<String, dynamic>.from(data));
      }
      return AgencyDashboardStats.empty();
    } catch (e) {
      debugPrint('Error fetching agency dashboard: $e');
      rethrow;
    }
  }
}
