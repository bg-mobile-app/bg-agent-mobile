import 'package:flutter/foundation.dart';

import '../../../common/services/api_client.dart';
import '../models/dashboard_models.dart';

class DashboardService {
  DashboardService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

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

  Future<AgentDashboardStats> getAgentDashboard(String period) async {
    try {
      final response = await _apiClient.get(
        '/filter/agent/stats/',
        queryParameters: {'period': period},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AgentDashboardStats.fromJson(data);
      }
      if (data is Map) {
        return AgentDashboardStats.fromJson(Map<String, dynamic>.from(data));
      }
      return AgentDashboardStats.empty();
    } catch (e) {
      debugPrint('Error fetching agent dashboard: $e');
      rethrow;
    }
  }

  /// Calls GET /filter/customer/stats/ with a period query parameter.
  Future<CustomerDashboardStats> getCustomerDashboard(String period) async {
    try {
      final response = await _apiClient.get(
        '/filter/customer/stats/',
        queryParameters: {'period': period},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CustomerDashboardStats.fromJson(data);
      }
      if (data is Map) {
        return CustomerDashboardStats.fromJson(Map<String, dynamic>.from(data));
      }
      return CustomerDashboardStats.empty();
    } catch (e) {
      debugPrint('Error fetching customer dashboard: $e');
      rethrow;
    }
  }
}
