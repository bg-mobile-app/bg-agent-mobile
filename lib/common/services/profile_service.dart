import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/home/models/agency_profile.dart';
import '../../features/home/models/favourite_model.dart';
import 'api_client.dart';
import 'agency_access.dart';
import 'auth_service.dart';

class ProfileService {
  RecruitingAgencyMeDetailsProps? _cachedProfile;
  DateTime? _cachedAt;
  static const Duration _cacheDuration = Duration(minutes: 5);
  final ApiClient _apiClient = ApiClient();

  Future<RecruitingAgencyMeDetailsProps?> getAgencyProfile() async {
    if (AgencyAccess.isAgencyStaffAccount(AuthService.currentUserData)) {
      return null;
    }

    final now = DateTime.now();
    if (_cachedProfile != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheDuration) {
      return _cachedProfile;
    }

    try {
      final response = await _apiClient.get('/profile/agents/me/');
      if (response.statusCode == 200 && response.data != null) {
        _cachedProfile = _profileFromResponseData(response.data);
        _cachedAt = now;
        return _cachedProfile;
      }
      return _cachedProfile;
    } catch (e) {
      debugPrint('Error fetching agency profile: $e');
      return _cachedProfile;
    }
  }

  void invalidateCache() {
    _cachedProfile = null;
    _cachedAt = null;
  }

  Future<RecruitingAgencyMeDetailsProps?> updateAgencyProfile(
    FormData formData,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/profile/agents/me/',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      if (response.statusCode == 204) {
        invalidateCache();
        return getAgencyProfile();
      }

      if ((response.statusCode == 200 ||
              response.statusCode == 201 ||
              response.statusCode == 202) &&
          response.data != null) {
        final profile = _profileFromResponseData(response.data);
        if (profile != null) {
          _cachedProfile = profile;
          _cachedAt = DateTime.now();
        }
        return profile ?? _cachedProfile;
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

  Future<Map<String, dynamic>?> getAgencyStaffProfile() async {
    debugPrint('Calling getAgencyStaffProfile API at /profile/agency-staff/');
    try {
      final response = await _apiClient.get('/profile/agency-staff/');
      debugPrint('getAgencyStaffProfile Response Status: ${response.statusCode}');
      debugPrint('getAgencyStaffProfile Response Data: ${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        final data = raw is String ? jsonDecode(raw) : raw;
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Exception in getAgencyStaffProfile: $e');
      if (e is DioException) {
        debugPrint('DioException Status: ${e.response?.statusCode}');
        debugPrint('DioException Data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  // ── Customer Profile ───────────────────────────────────────────────────────

  static const _customerProfileEndpoint = '/profile/customers/me/';

  Map<String, dynamic>? _cachedCustomerRaw;
  DateTime? _cachedCustomerAt;

  /// Fetches GET /profile/customers/me/ with a 5-minute in-memory cache.
  Future<Map<String, dynamic>?> getCustomerProfile() async {
    final now = DateTime.now();
    if (_cachedCustomerRaw != null &&
        _cachedCustomerAt != null &&
        now.difference(_cachedCustomerAt!) < _cacheDuration) {
      return _cachedCustomerRaw;
    }

    try {
      final response = await _apiClient.get(_customerProfileEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        final data = raw is String ? jsonDecode(raw) : raw;
        if (data is Map<String, dynamic>) {
          // Unwrap common envelope keys
          for (final key in const ['data', 'profile', 'result']) {
            final nested = data[key];
            if (nested is Map<String, dynamic>) {
              _cachedCustomerRaw = nested;
              _cachedCustomerAt = now;
              return _cachedCustomerRaw;
            }
          }
          _cachedCustomerRaw = data;
          _cachedCustomerAt = now;
          return _cachedCustomerRaw;
        }
      }
      return _cachedCustomerRaw;
    } catch (e) {
      debugPrint('Error fetching customer profile: $e');
      return _cachedCustomerRaw;
    }
  }

  /// Clears the customer profile cache so the next call re-fetches from API.
  void invalidateCustomerCache() {
    _cachedCustomerRaw = null;
    _cachedCustomerAt = null;
  }

  Future<Map<String, dynamic>?> updateCustomerProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        _customerProfileEndpoint,
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        invalidateCustomerCache();
        return getCustomerProfile();
      }
      return null;
    } catch (e) {
      debugPrint('Error updating customer profile: $e');
      rethrow;
    }
  }

  // ── Favourites ────────────────────────────────────────────────────────────

  Future<List<FavouriteItem>> getFavourites() async {
    try {
      final response = await _apiClient.get('/profile/favorite/');
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        final data = raw is String ? jsonDecode(raw) : raw;
        if (data is List) {
          return data
              .map((e) => FavouriteItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching favourites: $e');
      return [];
    }
  }

  Future<bool> toggleFavourite(int workPermitId) async {
    try {
      final response = await _apiClient.post(
        '/profile/favorite/',
        data: {'work_permit': workPermitId},
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      debugPrint('Error toggling favourite: $e');
      return false;
    }
  }
}
