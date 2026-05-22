import 'api_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Response> registerRecruitingAgency(FormData formData) async {
    return _apiClient.post(
      '/user/register/recruiting-agency/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response> resendOtp({required String username}) async {
    return _apiClient.post('/auth/otp/resend/', data: {'username': username});
  }

  Future<Response> verifyOtp({required String username, required String otp}) async {
    return _apiClient.post('/auth/otp/verify/', data: {'username': username, 'otp': otp});
  }

  Future<void> getSingOut() async {
    await _apiClient.get('/auth/logout/');
  }

  Future<Response> getCurrentUser() async {
    return _apiClient.get('/auth/me/');
  }
}
