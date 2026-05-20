import 'package:flutter/foundation.dart';
import '../../../common/services/api_client.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

  Future<MyAppointmentsResponse> getMyAppointments({
    required int page,
    String search = '',
    String? aptFromDate,
    String? aptToDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page};
      if (search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (aptFromDate != null && aptFromDate.isNotEmpty) {
        queryParameters['apt_from_date'] = aptFromDate;
      }
      if (aptToDate != null && aptToDate.isNotEmpty) {
        queryParameters['apt_to_date'] = aptToDate;
      }

      final response = await _apiClient.get(
        '/booking/wp/my-bookings/',
        queryParameters: queryParameters,
      );

      if (response.data is Map<String, dynamic>) {
        return MyAppointmentsResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response type: ${response.data.runtimeType}');
      }
    } catch (e, stacktrace) {
      debugPrint('Error fetching my appointments: $e\n$stacktrace');
      rethrow;
    }
  }
}

class MyAppointmentsResponse {
  final int count;
  final int pageSize;
  final List<AppointmentBookingItemDto> results;

  const MyAppointmentsResponse({
    required this.count,
    required this.pageSize,
    required this.results,
  });

  int get totalPages => pageSize <= 0 ? 1 : (count / pageSize).ceil();

  factory MyAppointmentsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = (json['results'] as List?) ?? const [];
    return MyAppointmentsResponse(
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      pageSize: json['pageSize'] is int
          ? json['pageSize'] as int
          : int.tryParse(json['pageSize']?.toString() ?? '10') ?? 10,
      results: rawResults
          .whereType<Map>()
          .map((item) => AppointmentBookingItemDto.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class AppointmentBookingItemDto {
  final int id;
  final int workPermitId;
  final String workPermitSlug;
  final String name;
  final String toCountry;
  final String serviceType;
  final String appointmentDate;
  final String? passportNo;
  final int? packagePrice;
  final int? paidAmount;
  final String? meeting;

  const AppointmentBookingItemDto({
    required this.id,
    required this.workPermitId,
    required this.workPermitSlug,
    required this.name,
    required this.toCountry,
    required this.serviceType,
    required this.appointmentDate,
    this.passportNo,
    this.packagePrice,
    this.paidAmount,
    this.meeting,
  });

  factory AppointmentBookingItemDto.fromJson(Map<String, dynamic> json) {
    return AppointmentBookingItemDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      workPermitId: json['workPermitId'] is int
          ? json['workPermitId'] as int
          : int.tryParse(json['workPermitId']?.toString() ?? '0') ?? 0,
      workPermitSlug: json['workPermitSlug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown User',
      toCountry: json['toCountry']?.toString() ?? 'Unknown Country',
      serviceType: json['serviceType']?.toString() ?? 'Work Permit',
      appointmentDate: json['appointmentDate']?.toString() ?? '',
      passportNo: json['passportNo']?.toString(),
      packagePrice: json['packagePrice'] is int
          ? json['packagePrice'] as int
          : int.tryParse(json['packagePrice']?.toString() ?? '') ?? (json['package_price'] is int ? json['package_price'] as int : int.tryParse(json['package_price']?.toString() ?? '')),
      paidAmount: json['paidAmount'] is int
          ? json['paidAmount'] as int
          : int.tryParse(json['paidAmount']?.toString() ?? '') ?? (json['paid_amount'] is int ? json['paid_amount'] as int : int.tryParse(json['paid_amount']?.toString() ?? '')),
      meeting: json['meeting']?.toString(),
    );
  }
}
