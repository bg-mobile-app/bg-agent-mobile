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
        if (response.data is Map<String, dynamic>) {
          return RecruitingAgencyMeDetailsProps.fromJson(response.data);
        } else if (response.data is String) {
          return RecruitingAgencyMeDetailsProps.fromJson(
            jsonDecode(response.data),
          );
        }
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
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return RecruitingAgencyMeDetailsProps.fromJson(response.data);
        } else if (response.data is String) {
          return RecruitingAgencyMeDetailsProps.fromJson(
            jsonDecode(response.data),
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating agency profile: $e');
      return null;
    }
  }
}
