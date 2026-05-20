import '../../../common/services/api_client.dart';

class TypesHandler<T> {
  const TypesHandler({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
    required this.pageSize,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;
  final int pageSize;
}

class RecruitingAgencyStaffGETProps {
  const RecruitingAgencyStaffGETProps({
    required this.id,
    required this.userId,
    required this.userCode,
    required this.email,
    required this.phone,
    required this.userRole,
    required this.designation,
    required this.isActive,
  });

  final int id;
  final String userId;
  final String userCode;
  final String email;
  final String phone;
  final String userRole;
  final String designation;
  final String isActive;

  RecruitingAgencyStaffGETProps copyWith({String? isActive}) =>
      RecruitingAgencyStaffGETProps(
        id: id,
        userId: userId,
        userCode: userCode,
        email: email,
        phone: phone,
        userRole: userRole,
        designation: designation,
        isActive: isActive ?? this.isActive,
      );

  factory RecruitingAgencyStaffGETProps.fromJson(Map<String, dynamic> json) =>
      RecruitingAgencyStaffGETProps(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        userId: (json['userId'] ?? json['user_id'] ?? json['id'])?.toString() ?? '',
        userCode: json['userCode']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        userRole: json['userRole']?.toString() ?? '',
        designation: json['designation']?.toString() ?? '',
        isActive: json['isActive']?.toString() == 'False' ? 'False' : 'True',
      );
}

class StaffAccountsService {
  StaffAccountsService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

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

  Future<TypesHandler<RecruitingAgencyStaffGETProps>> getRecruitingAgencyStaff({
    int page = 1,
  }) async {
    final response = await _apiClient.get('/profile/agency-staff/', queryParameters: {'page': page});
    final data = response.data;
    final map = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data as Map);

    final rawResults = map['results'] as List? ?? const [];

    return TypesHandler<RecruitingAgencyStaffGETProps>(
      count: map['count'] is int ? map['count'] as int : int.tryParse('${map['count']}') ?? 0,
      next: map['next']?.toString(),
      previous: map['previous']?.toString(),
      results: rawResults
          .whereType<Map>()
          .map((e) => RecruitingAgencyStaffGETProps.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pageSize: map['pageSize'] is int ? map['pageSize'] as int : int.tryParse('${map['pageSize']}') ?? 10,
    );
  }

  Future<Map<String, dynamic>> getStaffDetails(String userId) async {
    final response = await _apiClient.get('/profile/user/$userId/');
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Invalid staff details response');
  }

  Future<void> updateRecruitingAgencyStaff({
    required String userId,
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

    await _apiClient.patch('/profile/user/$userId/', data: payload);
  }

  Future<void> updateStaffVerifiedStatus({
    required String userId,
    required bool isActive,
  }) async {
    await _apiClient.patch(
      '/profile/user/$userId/verified/',
      data: {'isActive': isActive},
    );
  }
}
