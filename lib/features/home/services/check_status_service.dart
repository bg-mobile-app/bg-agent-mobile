import 'package:flutter/foundation.dart';

import '../../../common/services/api_client.dart';

class CheckStatusService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BookingStatusDto>> getMyBookingStatus({
    required String passportNo,
    required String bookingId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/booking/wp/status/my-bookings/',
        queryParameters: {
          'id': bookingId,
          'passport_no': passportNo,
        },
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => BookingStatusDto.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      throw Exception('Invalid response type: ${data.runtimeType}');
    } catch (e, stacktrace) {
      debugPrint('Error checking booking status: $e\n$stacktrace');
      rethrow;
    }
  }
}

class BookingStatusDto {
  const BookingStatusDto({
    required this.id,
    required this.name,
    required this.passportNo,
    required this.toCountry,
    required this.serviceType,
    required this.branch,
    required this.statusLabel,
    required this.appointmentDate,
    this.medicalExpiryDate,
    this.policeClearanceExpiryDate,
    this.visaExpiryDate,
  });

  final int id;
  final String name;
  final String passportNo;
  final String toCountry;
  final String serviceType;
  final String branch;
  final String statusLabel;
  final String appointmentDate;
  final String? medicalExpiryDate;
  final String? policeClearanceExpiryDate;
  final String? visaExpiryDate;

  factory BookingStatusDto.fromJson(Map<String, dynamic> json) {
    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return null;
    }

    return BookingStatusDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: pickString(['name']) ?? '',
      passportNo: pickString(['passportNo', 'passport_no']) ?? '',
      toCountry: pickString(['toCountry', 'to_country']) ?? '',
      serviceType: pickString(['serviceType', 'service_type']) ?? '',
      branch: pickString(['branch']) ?? '',
      statusLabel: pickString(['statusLabel', 'status_label']) ?? '',
      appointmentDate: pickString(['appointmentDate', 'appointment_date']) ?? '',
      medicalExpiryDate: pickString(['medicalExpiryDate', 'medical_expiry_date']),
      policeClearanceExpiryDate: pickString(['policeClearanceExpiryDate', 'police_clearance_expiry_date']),
      visaExpiryDate: pickString(['visaExpiryDate', 'visa_expiry_date']),
    );
  }
}
