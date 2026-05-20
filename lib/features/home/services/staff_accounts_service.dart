import '../../../common/services/api_client.dart';

class StaffAccountsService {
  StaffAccountsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> createRecruitingAgencyStaff({
    required String fullName,
    required String contactNo,
    required String gender,
    required String designation,
    required List<String> permissions,
    required String email,
    String? username,
    String? password,
  }) async {
    final payload = <String, dynamic>{
      'fullName': fullName,
      'contactNo': contactNo,
      'gender': gender,
      'designation': designation,
      'permissions': permissions,
      'email': email,
      if (username != null && username.isNotEmpty) 'username': username,
      if (password != null && password.isNotEmpty) 'password': password,
    };

    await _apiClient.post('/user/register/agency/staff/', data: payload);
  }
}
