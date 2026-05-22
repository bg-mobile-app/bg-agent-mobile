import 'package:flutter/foundation.dart';
import '../../../common/services/api_client.dart';
import '../../home/models/home_models.dart';
import '../models/work_permit_details.dart';

class WorkPermitService {
  final ApiClient _apiClient = ApiClient();

  Future<WorkPermitDetails?> getWorkPermitDetails(String slug) async {
    try {
      final response = await _apiClient.get('/work-permits/$slug/');
      return WorkPermitDetails.fromJson(response.data);
    } catch (e) {
      debugPrint("Error fetching work permit details: $e");
      return null;
    }
  }

  Future<List<WorkPermitItem>> getSimilarWorkPermits(String slug) async {
    try {
      final response = await _apiClient.get('/work-permits/$slug/related-permits/');
      
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['results'] is List) {
        rawList = data['results'];
      }

      return rawList.map((json) {
        return WorkPermitItem(
          id: int.tryParse((json['id'] ?? '').toString()),
          title: json['title'] ?? 'Unknown',
          slug: json['slug'] ?? '',
          image: json['image'] ?? 'assets/img/work-permit/1.jpg',
          customerPrice: json['customerPrice'] ?? json['customer_price'] ?? 0,
          agentPrice: json['agentPrice'] ?? json['agent_price'] ?? 0,
          countryName: json['countryName'] ?? json['country_name'] ?? 'Unknown',
          countryFlag: json['countryFlag'] ?? json['country_flag'] ?? 'assets/img/customer/appointment/world.png',
          workType: json['workType'] ?? json['work_type'] ?? 'Unknown',
          selectionType: json['selectionType'] ?? json['selection_type'] ?? 'DIRECT',
          createdAt: json['createdAt'] != null || json['created_at'] != null 
            ? DateTime.tryParse(json['createdAt'] ?? json['created_at']) ?? DateTime.now() 
            : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching similar work permits: $e");
      return [];
    }
  }
}
