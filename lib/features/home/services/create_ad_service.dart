import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../common/services/api_client.dart';

class CountryOption {
  const CountryOption({required this.id, required this.name});

  final int id;
  final String name;

  factory CountryOption.fromJson(Map<String, dynamic> json) {
    return CountryOption(
      id: _readInt(json['id']),
      name: _readName(json),
    );
  }
}

class WorkTypeOption {
  const WorkTypeOption({required this.id, required this.name});

  final int id;
  final String name;

  factory WorkTypeOption.fromJson(Map<String, dynamic> json) {
    return WorkTypeOption(
      id: _readInt(json['id']),
      name: _readName(json),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _readName(Map<String, dynamic> json) {
  return (json['name'] ?? json['title'] ?? json['label'] ?? '').toString();
}

class CreateAdService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CountryOption>> getCountries() async {
    try {
      final response = await _apiClient.get('/main/countries/');
      final raw = _decodeResponse(response.data);
      return _extractList(raw).map(CountryOption.fromJson).toList();
    } catch (e) {
      debugPrint('Error fetching countries: $e');
      return [];
    }
  }

  Future<List<WorkTypeOption>> getWorkTypes() async {
    try {
      final response = await _apiClient.get('/main/work-type/');
      final raw = _decodeResponse(response.data);
      return _extractList(raw).map(WorkTypeOption.fromJson).toList();
    } catch (e) {
      debugPrint('Error fetching work types: $e');
      return [];
    }
  }

  Future<WorkTypeOption?> suggestWorkType(String name) async {
    try {
      final response = await _apiClient.post(
        '/main/work-type/suggest/',
        data: {'name': name},
      );
      final raw = _decodeResponse(response.data);
      if (raw is Map<String, dynamic>) {
        final payload = raw['data'] is Map<String, dynamic>
            ? raw['data'] as Map<String, dynamic>
            : raw['result'] is Map<String, dynamic>
                ? raw['result'] as Map<String, dynamic>
                : raw;
        final option = WorkTypeOption.fromJson(payload);
        return option.id > 0 && option.name.isNotEmpty ? option : null;
      }
      return null;
    } catch (e) {
      debugPrint('Error suggesting work type: $e');
      rethrow;
    }
  }

  Future<void> createAd({
    required int? countryId,
    required int? workTypeId,
    required String title,
    required String description,
    required int packagePrice,
    required String paymentSystem,
    required List<Map<String, dynamic>> paymentSteps,
    required int advancePrice,
    required int afterVisa,
    required int beforeFlight,
  }) async {
    await _apiClient.post(
      '/work-permits/',
      data: {
        'country': countryId,
        'work_type': workTypeId,
        'title': title,
        'description': description,
        'packagePrice': packagePrice,
        'customerPercentage': 10,
        'agentPercentage': 5,
        'paymentSystem': paymentSystem,
        'paymentSteps': paymentSteps,
        'advancePrice': advancePrice,
        'afterVisa': afterVisa,
        'beforeFlight': beforeFlight,
      },
    );
  }

  dynamic _decodeResponse(dynamic raw) {
    if (raw is String) return jsonDecode(raw);
    return raw;
  }

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    final source = raw is List
        ? raw
        : raw is Map<String, dynamic>
            ? raw['results'] ?? raw['data'] ?? raw['items'] ?? const []
            : const [];

    if (source is! List) return [];
    return source
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => _readInt(item['id']) > 0 && _readName(item).isNotEmpty)
        .toList();
  }
}
