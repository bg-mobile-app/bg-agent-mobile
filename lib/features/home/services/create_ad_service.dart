import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../common/services/api_client.dart';
import '../../../common/services/api_exception.dart';

class CountryOption {
  const CountryOption({
    required this.value,
    required this.name,
    this.code = '',
    this.flag = '',
    this.unicodeFlag = '',
  });

  final Object value;
  final String name;
  final String code;
  final String flag;
  final String unicodeFlag;

  factory CountryOption.fromJson(Map<String, dynamic> json) {
    final name = _readCountryName(json);
    return CountryOption(
      value: _readApiValue(
        json['id'] ??
            json['country_id'] ??
            json['countryId'] ??
            json['pk'] ??
            json['value'] ??
            json['code'] ??
            name,
      ),
      name: name,
      code: (json['code'] ?? json['country_code'] ?? json['countryCode'] ?? '')
          .toString(),
      flag: (json['flag'] ?? json['country_flag'] ?? json['countryFlag'] ?? '')
          .toString(),
      unicodeFlag:
          (json['unicodeFlag'] ?? json['unicode_flag'] ?? '').toString(),
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

Object _readApiValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value?.toString().trim() ?? '';
  return int.tryParse(text) ?? text;
}

String _readName(Map<String, dynamic> json) {
  return (json['name'] ?? json['title'] ?? json['label'] ?? '').toString();
}

String _readCountryName(Map<String, dynamic> json) {
  final country = json['country'];
  if (country is Map) {
    return _readCountryName(Map<String, dynamic>.from(country));
  }
  return (json['name'] ??
          json['country_name'] ??
          json['countryName'] ??
          json['display_name'] ??
          json['displayName'] ??
          json['label'] ??
          json['title'] ??
          country ??
          json['code'] ??
          '')
      .toString();
}

class CreateAdService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CountryOption>> getCountries() async {
    try {
      final response = await _apiClient.get('/main/countries/');
      final raw = _decodeResponse(response.data);
      return _extractCountries(raw).map(CountryOption.fromJson).toList();
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
    required String country,
    required int workTypeId,
    required String title,
    required String description,
    required String selectionType,
    required int quota,
    required String applicationDeadline,
    required int packagePrice,
    required String paymentSystem,
    required List<Map<String, dynamic>> paymentSteps,
    required bool isBn,
  }) async {
    final payload = {
      'title': title,
      'country': country,
      'workType': workTypeId,
      'companyName': 'Example Company Name',
      'selectionType': selectionType,
      'salary': 50000,
      'currency': 'BDT',
      'minAge': '25',
      'maxAge': '40',
      'food': 'COMPANY',
      'workingHours': '8',
      'quota': quota,
      'contractDuration': 'TWO_YEAR',
      'accommodation': 'COMPANY',
      'gender': 'MALE',
      'documentsRequired': ['PASSPORT'],
      'packageIncludes': ['VISA'],
      'experienceRequired': 'ONE_YEAR',
      'applicationDeadline': applicationDeadline,
      'processingTime': '30 days',
      'packagePrice': packagePrice,
      'paymentSystem': paymentSystem,
      'paymentSteps': paymentSteps,
      'isBn': isBn,
      'customerPercentage': 10,
      'agentPercentage': 5,
    };

    if (description.isNotEmpty) {
      payload['description'] = description;
    }

    debugPrint(
      'CreateAdService.createAd request payload: ${jsonEncode(payload)}',
    );

    try {
      final response = await _apiClient.post('/work-permits/', data: payload);
      debugPrint(
        'CreateAdService.createAd success: '
        'statusCode=${response.statusCode}, data=${_safeEncode(response.data)}',
      );
    } on ApiException catch (e, stackTrace) {
      _logCreateAdFailure(e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('CreateAdService.createAd unexpected error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  void _logCreateAdFailure(ApiException error, StackTrace stackTrace) {
    debugPrint(
      'CreateAdService.createAd failed: '
      'statusCode=${error.statusCode}, message=${error.message}, '
      'data=${_safeEncode(error.data)}',
    );
    debugPrintStack(stackTrace: stackTrace);
  }

  String _safeEncode(dynamic value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  dynamic _decodeResponse(dynamic raw) {
    if (raw is String) return jsonDecode(raw);
    return raw;
  }

  List<Map<String, dynamic>> _extractCountries(dynamic raw) {
    final source = _extractSource(raw, preferredKeys: const [
      'results',
      'data',
      'countries',
      'country',
      'items',
    ]);

    if (source is List) {
      return source
          .map((item) {
            if (item is Map) return Map<String, dynamic>.from(item);
            final name = item?.toString().trim() ?? '';
            return <String, dynamic>{'id': name, 'name': name};
          })
          .where((item) => _readCountryName(item).isNotEmpty)
          .toList();
    }

    if (source is Map) {
      return source.entries
          .map((entry) {
            if (entry.value is Map) {
              return <String, dynamic>{
                'id': entry.key,
                ...Map<String, dynamic>.from(entry.value as Map),
              };
            }
            return <String, dynamic>{
              'id': entry.key,
              'name': entry.value?.toString() ?? entry.key.toString(),
            };
          })
          .where((item) => _readCountryName(item).isNotEmpty)
          .toList();
    }

    return [];
  }

  dynamic _extractSource(
    dynamic raw, {
    List<String> preferredKeys = const ['results', 'data', 'items'],
  }) {
    if (raw is List) return raw;
    if (raw is! Map) return const [];

    final map = Map<String, dynamic>.from(raw);
    for (final key in preferredKeys) {
      final value = map[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractSource(value, preferredKeys: preferredKeys);
        if (nested is List && nested.isNotEmpty) return nested;
        if (nested is Map && nested.isNotEmpty) return nested;
      }
    }
    return map;
  }

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    final source = _extractSource(raw);

    if (source is! List) return [];
    return source
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => _readInt(item['id']) > 0 && _readName(item).isNotEmpty)
        .toList();
  }
}
