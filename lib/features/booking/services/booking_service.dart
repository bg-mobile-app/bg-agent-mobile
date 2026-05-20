import 'package:flutter/foundation.dart';
import '../../../common/services/api_client.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

  Future<ReceiveBookingsResponse> getReceiveBookings({
    required String status,
    required int page,
    String search = '',
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'status': status,
        'search': search.trim(),
        'page': page,
      };
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParameters['from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParameters['to_date'] = toDate;
      }

      final response = await _apiClient.get('/booking/wp/', queryParameters: queryParameters);

      if (response.data is Map<String, dynamic>) {
        return ReceiveBookingsResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response type: ${response.data.runtimeType}');
    } catch (e, stacktrace) {
      debugPrint('Error fetching receive bookings: $e\n$stacktrace');
      rethrow;
    }
  }
}

class ReceiveBookingsResponse {
  final int count;
  final int pageSize;
  final List<ReceiveBookingItemDto> results;

  const ReceiveBookingsResponse({
    required this.count,
    required this.pageSize,
    required this.results,
  });

  factory ReceiveBookingsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = (json['results'] as List?) ?? const [];
    return ReceiveBookingsResponse(
      count: _toInt(json['count']),
      pageSize: _toInt(json['pageSize'], fallback: 10),
      results: rawResults
          .whereType<Map>()
          .map((item) => ReceiveBookingItemDto.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class ReceiveBookingItemDto {
  final int id;
  final String workPermitId;
  final String serviceType;
  final String createdAt;
  final String name;
  final String fromCountry;
  final String toCountry;
  final String? passportNo;
  final int? agencyTotalCost;
  final int? paidAmount;
  final String status;
  final String statusLabel;
  final String? appointmentDate;
  final String? medicalExpiryDate;
  final String? policeClearanceExpiryDate;
  final String? visaExpiryDate;
  final bool hasAdvancePayout;
  final bool hasAfterVisaPayout;
  final bool hasBeforeFlightPayout;
  final int? paymentStepCount;
  final bool isReturn;

  const ReceiveBookingItemDto({
    required this.id,
    required this.workPermitId,
    required this.serviceType,
    required this.createdAt,
    required this.name,
    required this.fromCountry,
    required this.toCountry,
    required this.passportNo,
    required this.agencyTotalCost,
    required this.paidAmount,
    required this.status,
    required this.statusLabel,
    this.appointmentDate,
    this.medicalExpiryDate,
    this.policeClearanceExpiryDate,
    this.visaExpiryDate,
    required this.hasAdvancePayout,
    required this.hasAfterVisaPayout,
    required this.hasBeforeFlightPayout,
    this.paymentStepCount,
    required this.isReturn,
  });

  factory ReceiveBookingItemDto.fromJson(Map<String, dynamic> json) {
    final status = _pickString(json, ['status'], fallback: 'UNKNOWN');
    return ReceiveBookingItemDto(
      id: _toInt(json['id']),
      workPermitId: _pickString(json, ['workPermitId', 'work_permit_id', 'post_id']),
      serviceType: _pickString(json, ['serviceType', 'service_type'], fallback: 'Work Permit'),
      createdAt: _pickString(json, ['createdAt', 'created_at', 'apply_date']),
      name: _pickString(json, ['name', 'customer_name'], fallback: 'Unknown User'),
      fromCountry: _pickString(json, ['fromCountry', 'from_country'], fallback: '-'),
      toCountry: _pickString(json, ['toCountry', 'to_country'], fallback: '-'),
      passportNo: _pickNullableString(json, ['passportNo', 'passport_no']),
      agencyTotalCost: _pickInt(json, ['agencyTotalCost', 'agency_total_cost', 'packagePrice', 'package_price']),
      paidAmount: _pickInt(json, ['paidAmount', 'paid_amount']),
      status: status,
      statusLabel: _pickString(json, ['statusLabel', 'status_label'], fallback: status.replaceAll('_', ' ')),
      appointmentDate: _pickNullableString(json, ['appointmentDate', 'appointment_date']),
      medicalExpiryDate: _pickNullableString(json, ['medicalExpiryDate', 'medical_expiry_date']),
      policeClearanceExpiryDate: _pickNullableString(json, ['policeClearanceExpiryDate', 'police_clearance_expiry_date']),
      visaExpiryDate: _pickNullableString(json, ['visaExpiryDate', 'visa_expiry_date']),
      hasAdvancePayout: _pickBool(json, ['hasAdvancePayout', 'has_advance_payout'], fallback: true),
      hasAfterVisaPayout: _pickBool(json, ['hasAfterVisaPayout', 'has_after_visa_payout'], fallback: true),
      hasBeforeFlightPayout: _pickBool(json, ['hasBeforeFlightPayout', 'has_before_flight_payout'], fallback: true),
      paymentStepCount: _pickInt(json, ['paymentStepCount', 'payment_step_count']),
      isReturn: _pickBool(json, ['isReturn', 'is_return'], fallback: false),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _pickString(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) return value.toString();
  }
  return fallback;
}

String? _pickNullableString(Map<String, dynamic> json, List<String> keys) {
  final value = _pickString(json, keys);
  return value.isEmpty ? null : value;
}

int? _pickInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    final parsed = _toInt(value, fallback: -1);
    if (parsed >= 0) return parsed;
  }
  return null;
}

bool _pickBool(Map<String, dynamic> json, List<String> keys, {required bool fallback}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
  }
  return fallback;
}
