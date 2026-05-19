import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../common/services/api_client.dart';

class CountryOption {
  const CountryOption({required this.id, required this.name});

  final int id;
  final String name;

  factory CountryOption.fromJson(Map<String, dynamic> json) {
    return CountryOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class WorkTypeOption {
  const WorkTypeOption({required this.id, required this.name});

  final int id;
  final String name;

  factory WorkTypeOption.fromJson(Map<String, dynamic> json) {
    return WorkTypeOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CreateAdService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CountryOption>> getCountries() async {
    try {
      final response = await _apiClient.get('/main/countries/');
      final raw = response.data;
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(CountryOption.fromJson)
            .toList();
      }
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(CountryOption.fromJson)
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching countries: $e');
      return [];
    }
  }

  Future<List<WorkTypeOption>> getWorkTypes() async {
    try {
      final response = await _apiClient.get('/main/work-type/');
      final raw = response.data;
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(WorkTypeOption.fromJson)
            .toList();
      }
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(WorkTypeOption.fromJson)
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching work types: $e');
      return [];
    }
  }

  Future<void> createAd({
    required int? countryId,
    required int? workTypeId,
    required String title,
    required String description,
  }) async {
    await _apiClient.post(
      '/work-permits/',
      data: {
        'country': countryId,
        'work_type': workTypeId,
        'title': title,
        'description': description,
      },
    );
  }
}
