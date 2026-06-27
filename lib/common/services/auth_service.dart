import 'dart:convert';
import 'api_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  static Map<String, dynamic>? _currentUserData;
  static Map<String, dynamic>? get currentUserData => _currentUserData;

  Future<Response> registerAgent(FormData formData) async {
    return _apiClient.post(
      '/user/register/agent/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response> registerCustomer(Map<String, dynamic> data) async {
    return _apiClient.post('/user/register/customer/', data: data);
  }

  Future<Response> resendOtp({required String username}) async {
    return _apiClient.post('/auth/otp/resend/', data: {'username': username});
  }

  Future<Response> verifyOtp({
    required String username,
    required String otp,
  }) async {
    return _apiClient.post(
      '/auth/otp/verify/',
      data: {'username': username, 'otp': otp},
    );
  }

  Future<void> getSingOut() async {
    try {
      await _apiClient.get(
        '/auth/logout/',
        useCache: false,
        forceRefresh: true,
      );
    } finally {
      _currentUserData = null;
      await _apiClient.tokenStorage.clearCookies();
      _apiClient.clearResponseCache();
    }
  }

  Future<Response> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me/');
    if (response.statusCode == 200 && response.data != null) {
      final raw = response.data;
      final data = raw is String ? jsonDecode(raw) : raw;
      if (data is Map<String, dynamic>) {
        _currentUserData = data;
      }
    }
    return response;
  }
}
