import 'package:flutter/foundation.dart';
import '../../../common/services/api_client.dart';
import '../models/home_models.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<String>> getCountries() async {
    try {
      final response = await _apiClient.get('/main/countries/');
      
      final data = response.data;
      if (data is List) {
        return data.map((e) => e['name']?.toString() ?? 'Unknown').toList();
      } else if (data is Map && data['results'] is List) {
        return (data['results'] as List).map((e) => e['name']?.toString() ?? 'Unknown').toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching countries: $e");
      return [];
    }
  }

  Future<List<WorkTypeItem>> getWorkTypes() async {
    try {
      final response = await _apiClient.get('/main/work-type/');
      
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['results'] is List) {
        rawList = data['results'];
      }

      return rawList.map((json) {
        return WorkTypeItem(
          id: json['id'] ?? 0,
          name: json['name'] ?? 'Unknown',
          nameBn: json['nameBn'] ?? json['name_bn'] ?? 'Unknown',
          icon: json['icon'] ?? '',
          serial: json['serial'] ?? 0,
          totalAds: json['totalAds'] ?? json['total_ads'] ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching work types: $e");
      return [];
    }
  }

  Future<List<String>> getOfferBanners() async {
    try {
      final response = await _apiClient.get('/main/offer-banner/');
      
      final data = response.data;
      if (data is List) {
        return data.map((e) => e['image']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      } else if (data is Map && data['results'] is List) {
        return (data['results'] as List).map((e) => e['image']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching banners: $e");
      return [];
    }
  }

  Future<List<WorkPermitItem>> getWorkPermits() async {
    try {
      final response = await _apiClient.get('/work-permits/home-permits/');
      
      final data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['results'] is List) {
        rawList = data['results'];
      }

      return rawList.map((json) {
        return WorkPermitItem(
          title: json['title'] ?? 'Unknown',
          slug: json['slug'] ?? '',
          image: json['image'] ?? 'assets/img/work-permit/1.jpg', // fallback image
          customerPrice: json['customerPrice'] is int ? json['customerPrice'] : (int.tryParse(json['customerPrice']?.toString() ?? '0') ?? int.tryParse(json['customer_price']?.toString() ?? '0') ?? 0),
          agentPrice: json['agentPrice'] is int ? json['agentPrice'] : (int.tryParse(json['agentPrice']?.toString() ?? '0') ?? int.tryParse(json['agent_price']?.toString() ?? '0') ?? 0),
          countryName: json['countryName'] ?? json['country_name'] ?? 'Unknown',
          countryFlag: json['countryFlag'] ?? json['country_flag'] ?? 'assets/img/customer/appointment/world.png',
          workType: json['workType'] ?? json['work_type'] ?? 'Unknown',
          selectionType: json['selectionType'] ?? json['selection_type'] ?? 'DIRECT',
          createdAt: json['createdAt'] != null || json['created_at'] != null 
            ? DateTime.tryParse(json['createdAt'] ?? json['created_at']) ?? DateTime.now() 
            : DateTime.now(),
        );
      }).toList();
    } catch (e, stacktrace) {
      debugPrint("Error fetching work permits: $e\n$stacktrace");
      return [];
    }
  }
}
