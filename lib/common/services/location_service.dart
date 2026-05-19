import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class DistrictOption {
  const DistrictOption({required this.id, required this.name});

  final int id;
  final String name;

  factory DistrictOption.fromJson(Map<String, dynamic> json) {
    return DistrictOption(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class PoliceStationOption {
  const PoliceStationOption({required this.id, required this.name});

  final int id;
  final String name;

  factory PoliceStationOption.fromJson(Map<String, dynamic> json) {
    return PoliceStationOption(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class LocationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<DistrictOption>> getDistricts() async {
    try {
      final response = await _apiClient.get('/locations/district/');
      final raw = response.data;
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().map(DistrictOption.fromJson).toList();
      }
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.whereType<Map<String, dynamic>>().map(DistrictOption.fromJson).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching districts: $e');
      return [];
    }
  }

  Future<List<PoliceStationOption>> getPoliceStations(int districtId) async {
    try {
      final response = await _apiClient.get('/locations/police-station/', queryParameters: {'district__id': districtId});
      final raw = response.data;
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().map(PoliceStationOption.fromJson).toList();
      }
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.whereType<Map<String, dynamic>>().map(PoliceStationOption.fromJson).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching police stations: $e');
      return [];
    }
  }
}
