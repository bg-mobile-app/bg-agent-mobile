import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/home/models/agency_profile.dart';
import 'api_client.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<RecruitingAgencyMeDetailsProps?> getAgencyProfile() async {
    try {
      final response = await _apiClient.get('/profile/agency/me/');
      if (response.statusCode == 200 && response.data != null) {
        return _profileFromResponseData(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching agency profile: $e');
      return null;
    }
  }

  Future<RecruitingAgencyMeDetailsProps?> updateAgencyProfile(
    FormData formData,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/profile/agency/me/',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      if (response.statusCode == 204) {
        return getAgencyProfile();
      }

      if ((response.statusCode == 200 ||
              response.statusCode == 201 ||
              response.statusCode == 202) &&
          response.data != null) {
        final profile = _profileFromResponseData(response.data);
        return profile ?? getAgencyProfile();
      }
      return null;
    } catch (e) {
      debugPrint('Error updating agency profile: $e');
      rethrow;
    }
  }

  RecruitingAgencyMeDetailsProps? _profileFromResponseData(dynamic raw) {
    final data = raw is String ? jsonDecode(raw) : raw;
    if (data is! Map<String, dynamic>) return null;

    for (final key in const ['data', 'profile', 'account']) {
      final nested = data[key];
      if (nested is Map<String, dynamic>) {
        return RecruitingAgencyMeDetailsProps.fromJson(nested);
      }
    }

    return RecruitingAgencyMeDetailsProps.fromJson(data);
  }
}
