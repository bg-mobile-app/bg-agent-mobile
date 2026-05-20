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


  Future<ReceivedBookingsResponse> getReceivedBookings({
    required String status,
    required int page,
    String search = '',
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'status': status,
        'page': page,
      };
      if (search.trim().isNotEmpty) queryParameters['search'] = search.trim();
      if (fromDate != null && fromDate.isNotEmpty) queryParameters['from_date'] = fromDate;
      if (toDate != null && toDate.isNotEmpty) queryParameters['to_date'] = toDate;

      final response = await _apiClient.get('/booking/wp/', queryParameters: queryParameters);
      if (response.data is Map<String, dynamic>) {
        return ReceivedBookingsResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response type: ${response.data.runtimeType}');
    } catch (e, stacktrace) {
      debugPrint('Error fetching received bookings: $e\n$stacktrace');
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


class ReceivedBookingsResponse {
  final int count;
  final int pageSize;
  final List<ReceivedBookingItemDto> results;

  const ReceivedBookingsResponse({required this.count, required this.pageSize, required this.results});

  factory ReceivedBookingsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = (json['results'] as List?) ?? const [];
    return ReceivedBookingsResponse(
      count: json['count'] is int ? json['count'] as int : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      pageSize: json['pageSize'] is int ? json['pageSize'] as int : int.tryParse(json['pageSize']?.toString() ?? '10') ?? 10,
      results: rawResults.whereType<Map>().map((item) => ReceivedBookingItemDto.fromJson(Map<String, dynamic>.from(item))).toList(),
    );
  }
}

class ReceivedBookingItemDto {
  final int id;
  final int workPermitId;
  final String workPermitSlug;
  final String name;
  final String? fromCountry;
  final String toCountry;
  final String serviceType;
  final String createdAt;
  final String status;
  final String statusLabel;
  final String? appointmentDate;
  final String? medicalExpiryDate;
  final String? policeClearanceExpiryDate;
  final String? visaExpiryDate;
  final String? passportNo;
  final int? packagePrice;
  final int? paidAmount;

  const ReceivedBookingItemDto({required this.id, required this.workPermitId, required this.workPermitSlug, required this.name, required this.toCountry, required this.serviceType, required this.createdAt, required this.status, required this.statusLabel, this.fromCountry, this.appointmentDate, this.medicalExpiryDate, this.policeClearanceExpiryDate, this.visaExpiryDate, this.passportNo, this.packagePrice, this.paidAmount});

  factory ReceivedBookingItemDto.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'APPLIED_FILE';
    return ReceivedBookingItemDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      workPermitId: json['workPermitId'] is int ? json['workPermitId'] as int : int.tryParse(json['workPermitId']?.toString() ?? '0') ?? 0,
      workPermitSlug: json['workPermitSlug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown User',
      fromCountry: json['fromCountry']?.toString(),
      toCountry: json['toCountry']?.toString() ?? 'Unknown Country',
      serviceType: json['serviceType']?.toString() ?? 'Work Permit',
      createdAt: json['createdAt']?.toString() ?? '',
      status: status,
      statusLabel: status.replaceAll('_', ' ').toLowerCase().split(' ').map((w)=> w.isEmpty ? w : w[0].toUpperCase()+w.substring(1)).join(' '),
      appointmentDate: json['appointmentDate']?.toString(),
      medicalExpiryDate: json['medicalExpiryDate']?.toString(),
      policeClearanceExpiryDate: json['policeClearanceExpiryDate']?.toString(),
      visaExpiryDate: json['visaExpiryDate']?.toString(),
      passportNo: json['passportNo']?.toString(),
      packagePrice: json['packagePrice'] is int ? json['packagePrice'] as int : int.tryParse(json['packagePrice']?.toString() ?? '') ?? (json['package_price'] is int ? json['package_price'] as int : int.tryParse(json['package_price']?.toString() ?? '')),
      paidAmount: json['paidAmount'] is int ? json['paidAmount'] as int : int.tryParse(json['paidAmount']?.toString() ?? '') ?? (json['paid_amount'] is int ? json['paid_amount'] as int : int.tryParse(json['paid_amount']?.toString() ?? '')),
    );
  }
}
