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
      final response = await _apiClient.get(
        '/work-permits/$slug/related-permits/',
      );

      final related = _extractWorkPermitList(
        response.data,
      ).where((item) => item.slug != slug).toList();
      if (related.isNotEmpty) return related;

      final fallbackResponse = await _apiClient.get(
        '/work-permits/home-permits/',
      );
      return _extractWorkPermitList(
        fallbackResponse.data,
      ).where((item) => item.slug != slug).toList();
    } catch (e) {
      debugPrint("Error fetching similar work permits: $e");
      return [];
    }
  }

  List<WorkPermitItem> _extractWorkPermitList(dynamic data) {
    final rawList = _extractRawList(data);
    return rawList
        .whereType<Map>()
        .map((json) => _toWorkPermitItem(Map<String, dynamic>.from(json)))
        .toList();
  }

  List<dynamic> _extractRawList(dynamic data) {
    if (data is List) return data;
    if (data is! Map) return [];

    for (final key in [
      'results',
      'data',
      'related',
      'relatedPermits',
      'related_permits',
      'workPermits',
      'work_permits',
    ]) {
      final value = data[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractRawList(value);
        if (nested.isNotEmpty) return nested;
      }
    }

    return [];
  }

  WorkPermitItem _toWorkPermitItem(Map<String, dynamic> json) {
    return WorkPermitItem(
      id: int.tryParse((json['id'] ?? '').toString()),
      title: json['title'] ?? 'Unknown',
      slug: json['slug'] ?? '',
      image: json['image'] ?? 'assets/img/work-permit/1.jpg',
      customerPrice: _parseInt(
        json['customerPrice'] ?? json['customer_price'] ?? json['packagePrice'],
      ),
      agentPrice: _parseInt(json['agentPrice'] ?? json['agent_price']),
      countryName: _stringFromMaybeMap(
        json['countryName'] ?? json['country_name'] ?? json['country'],
        mapKey: 'name',
        fallback: 'Unknown',
      ),
      countryFlag: _stringFromMaybeMap(
        json['countryFlag'] ?? json['country_flag'] ?? json['country'],
        mapKey: 'flag',
        fallback: 'assets/img/customer/appointment/world.png',
      ),
      workType: _stringFromMaybeMap(
        json['workType'] ?? json['work_type'],
        mapKey: 'name',
        fallback: 'Unknown',
      ),
      selectionType:
          (json['selectionType'] ?? json['selection_type'] ?? 'DIRECT')
              .toString(),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at']) ??
                DateTime.now()
          : DateTime.now(),
    );
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ??
        double.tryParse(value.toString())?.toInt() ??
        0;
  }

  String _stringFromMaybeMap(
    dynamic value, {
    required String mapKey,
    required String fallback,
  }) {
    if (value is Map) return (value[mapKey] ?? fallback).toString();
    if (value == null) return fallback;
    return value.toString();
  }
}
