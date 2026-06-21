import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../common/services/api_client.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BranchItem>> getBranches() async {
    try {
      final response = await _apiClient.get('/main/branch/');
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => BranchItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      throw Exception('Invalid response type: ${data.runtimeType}');
    } catch (e, stacktrace) {
      debugPrint('Error fetching branches: $e\n$stacktrace');
      rethrow;
    }
  }

  Future<ReceiveBookingItemDto> getReceiveBookingDetail(int bookingId) async {
    final response = await _apiClient.get('/booking/wp/$bookingId/');
    if (response.data is Map<String, dynamic>) {
      return ReceiveBookingItemDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception('Invalid response type: ${response.data.runtimeType}');
  }

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

      final response = await _apiClient.get(
        '/booking/wp/',
        queryParameters: queryParameters,
      );

      if (response.data is Map<String, dynamic>) {
        return ReceiveBookingsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Invalid response type: ${response.data.runtimeType}');
    } catch (e, stacktrace) {
      debugPrint('Error fetching receive bookings: $e\n$stacktrace');
      rethrow;
    }
  }

  Future<ReceiveBookingsResponse> getMyBookings({
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
      if (fromDate != null && fromDate.isNotEmpty)
        queryParameters['from_date'] = fromDate;
      if (toDate != null && toDate.isNotEmpty)
        queryParameters['to_date'] = toDate;

      final response = await _apiClient.get(
        '/booking/wp/my-bookings/',
        queryParameters: queryParameters,
      );
      if (response.data is Map<String, dynamic>) {
        return ReceiveBookingsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Invalid response type: ${response.data.runtimeType}');
    } catch (e, stacktrace) {
      debugPrint('Error fetching my bookings: $e\n$stacktrace');
      rethrow;
    }
  }

  Future<void> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    await _apiClient.patch(
      '/booking/wp/status/$bookingId/set/',
      data: {'status': status},
    );
  }

  Future<void> submitAgencyPayoutRequest({
    required int bookingId,
    required String step,
    num? requestAmount,
  }) async {
    final payload = <String, dynamic>{
      'booking': bookingId,
      'step': step,
      if (requestAmount != null) 'requestAmount': requestAmount,
    };
    try {
      debugPrint('Submitting agency payout request: $payload');
      await _apiClient.post(
        '/payment/agency/payout-request/',
        data: payload,
      );
      debugPrint('Payout request submitted successfully for booking $bookingId');
    } catch (e, stacktrace) {
      debugPrint('Payout request failed for booking $bookingId: $e');
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<void> updateBookingReminders({
    required int bookingId,
    String? medicalExpiryDate,
    String? policeClearanceExpiryDate,
    String? visaExpiryDate,
  }) async {
    final payload = <String, dynamic>{};
    if (medicalExpiryDate != null && medicalExpiryDate.isNotEmpty) {
      payload['medical_expiry_date'] = medicalExpiryDate;
    }
    if (policeClearanceExpiryDate != null &&
        policeClearanceExpiryDate.isNotEmpty) {
      payload['police_clearance_expiry_date'] = policeClearanceExpiryDate;
    }
    if (visaExpiryDate != null && visaExpiryDate.isNotEmpty) {
      payload['visa_expiry_date'] = visaExpiryDate;
    }
    if (payload.isEmpty) {
      throw ArgumentError('At least one reminder date is required.');
    }

    await _apiClient.patch(
      '/booking/wp/reminders/$bookingId/update/',
      data: payload,
    );
  }

  Future<void> uploadBookingDocument({
    required int bookingId,
    required String fileName,
    required String title,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    if (filePath == null && fileBytes == null) {
      throw ArgumentError('A document path or bytes value is required.');
    }

    final extension = fileName.split('.').last.toLowerCase();
    final fieldName = extension == 'pdf' ? 'document' : 'image';
    final multipartFile = filePath != null
        ? await MultipartFile.fromFile(filePath, filename: fileName)
        : MultipartFile.fromBytes(fileBytes!, filename: fileName);

    await _apiClient.post(
      '/booking/wp/$bookingId/documents/',
      data: FormData.fromMap({
        fieldName: multipartFile,
        'title': title,
      }),
    );
  }

  Future<List<Map<String, dynamic>>> getBookingDocuments(int bookingId) async {
    final response = await _apiClient.get('/booking/wp/$bookingId/documents/');
    final data = response.data;
    if (data is Map && data['documents'] is List) {
      final list = data['documents'] as List;
      return List<Map<String, dynamic>>.from(
        list.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    return [];
  }

  Future<void> submitReturnRequest({
    required int bookingId,
    required String reason,
    num? costAmount,
    num? requestAmount,
    String? costDetails,
  }) async {
    final payload = <String, dynamic>{'bookingId': bookingId, 'reason': reason};
    if (costAmount != null) payload['costAmount'] = costAmount;
    if (requestAmount != null) payload['requestAmount'] = requestAmount;
    if (costDetails != null && costDetails.trim().isNotEmpty) {
      payload['costDetails'] = costDetails.trim();
    }
    await _apiClient.post('/booking/wp/return/file-request/', data: payload);
  }

  Future<void> submitSendPassportRequest({
    required String fullName,
    required String phone,
    required String employeeId,
    required String email,
    required String employeeOf,
    required List<int> bookingIds,
  }) async {
    await _apiClient.post(
      '/booking/wp/send-passport/list/',
      data: {
        'fullName': fullName,
        'phone': phone,
        'employeeId': employeeId,
        'email': email,
        'employeeOf': employeeOf,
        'bookingIds': bookingIds,
      },
    );
  }

  Future<MyAppointmentsResponse> getMyAppointments({
    required int page,
    String search = '',
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'search': search.trim(),
        'page': page,
      };
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParameters['apt_from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParameters['apt_to_date'] = toDate;
      }

      final response = await _apiClient.get(
        '/booking/wp/my-bookings/',
        queryParameters: queryParameters,
      );

      if (response.data is Map<String, dynamic>) {
        return MyAppointmentsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Invalid response type: ${response.data.runtimeType}');
    } catch (e, stacktrace) {
      debugPrint('Error fetching receive bookings: $e\n$stacktrace');
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
      final queryParameters = <String, dynamic>{'status': status, 'page': page};
      if (search.trim().isNotEmpty) queryParameters['search'] = search.trim();
      if (fromDate != null && fromDate.isNotEmpty)
        queryParameters['from_date'] = fromDate;
      if (toDate != null && toDate.isNotEmpty)
        queryParameters['to_date'] = toDate;

      final response = await _apiClient.get(
        '/booking/wp/',
        queryParameters: queryParameters,
      );
      if (response.data is Map<String, dynamic>) {
        return ReceivedBookingsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Invalid response type: ${response.data.runtimeType}');
    } catch (e, stacktrace) {
      debugPrint('Error fetching received bookings: $e\n$stacktrace');
      rethrow;
    }
  }

  Future<void> submitBulkWorkPermitBookings(
    List<Map<String, dynamic>> payload,
  ) async {
    try {
      final normalizedPayload = <Map<String, dynamic>>[];
      for (final item in payload) {
        final normalized = Map<String, dynamic>.from(item);
        normalized['workPermit'] = await _resolveWorkPermitPk(
          item['workPermit'],
        );
        normalizedPayload.add(normalized);
      }
      await _apiClient.post('/booking/wp/', data: normalizedPayload);
    } catch (e, stacktrace) {
      debugPrint('Error submitting bulk work permit bookings: $e\n$stacktrace');
      rethrow;
    }
  }

  Future<int> _resolveWorkPermitPk(dynamic workPermitValue) async {
    if (workPermitValue is int && workPermitValue > 0) return workPermitValue;
    if (workPermitValue is String) {
      final trimmed = workPermitValue.trim();
      if (trimmed.isEmpty) {
        throw const FormatException('Work permit reference cannot be empty.');
      }

      final parsed = int.tryParse(trimmed);
      if (parsed != null && parsed > 0) return parsed;

      final response = await _apiClient.get('/work-permits/$trimmed/');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final resolvedId = _toInt(data['id']);
        if (resolvedId > 0) return resolvedId;
      }
      throw FormatException('Unable to resolve work permit slug: $trimmed');
    }
    throw FormatException(
      'Unsupported work permit reference type: ${workPermitValue.runtimeType}',
    );
  }
}

class BranchItem {
  const BranchItem({required this.id, required this.name, this.address});

  factory BranchItem.fromJson(Map<String, dynamic> json) {
    return BranchItem(
      id: _toInt(json['id']),
      name: _pickString(json, const ['name'], fallback: 'Unknown Branch'),
      address: _pickNullableString(json, const ['address']),
    );
  }

  final int id;
  final String name;
  final String? address;
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
          .map(
            (item) =>
                ReceiveBookingItemDto.fromJson(Map<String, dynamic>.from(item)),
          )
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
    final Map<String, dynamic> returnFile = json['returnFile'] is Map
        ? Map<String, dynamic>.from(json['returnFile'] as Map)
        : <String, dynamic>{};

    // try top-level values first, then fall back to values inside `returnFile`
    final agencyTotalCostValue = _pickInt(json, [
      'agencyTotalCost',
      'agency_total_cost',
      'packagePrice',
      'package_price',
      'customerTotal',
      'customer_total',
    ]) ?? _pickInt(returnFile, ['packagePrice', 'package_price', 'customerTotal', 'customer_total']);

    final paidAmountValue = _pickInt(json, [
      'clientPaidAmount',
      'client_paid_amount',
      'paidAmount',
      'paid_amount',
    ]) ??
        _pickInt(returnFile, ['receivedAmount', 'received_amount']);

    final payoutRequestsRaw = json['payoutRequests'] ?? json['payout_requests'];
    final payoutRequests = payoutRequestsRaw is List
        ? List<Map<String, dynamic>>.from(
            payoutRequestsRaw.map((e) => Map<String, dynamic>.from(e as Map)),
          )
        : null;

    final hasAdvancePayoutValue = payoutRequests != null
        ? payoutRequests.any((i) => i['step'] == 'ADVANCE')
        : _pickBool(json, ['hasAdvancePayout', 'has_advance_payout'], fallback: false);

    final hasAfterVisaPayoutValue = payoutRequests != null
        ? payoutRequests.any((i) => i['step'] == 'AFTER_VISA')
        : _pickBool(json, ['hasAfterVisaPayout', 'has_after_visa_payout'], fallback: false);

    final hasBeforeFlightPayoutValue = payoutRequests != null
        ? payoutRequests.any((i) => i['step'] == 'BEFORE_FLIGHT')
        : _pickBool(json, ['hasBeforeFlightPayout', 'has_before_flight_payout'], fallback: false);

    return ReceiveBookingItemDto(
      id: _toInt(json['id']),
      workPermitId: _pickString(json, [
        'workPermitId',
        'work_permit_id',
        'post_id',
      ]),
      serviceType: _pickString(json, [
        'serviceType',
        'service_type',
      ], fallback: 'Work Permit'),
      createdAt: _pickString(json, ['createdAt', 'created_at', 'apply_date']),
      name: _pickString(json, [
        'name',
        'customer_name',
      ], fallback: 'Unknown User'),
      fromCountry: _pickString(json, [
        'fromCountry',
        'from_country',
      ], fallback: '-'),
      toCountry: _pickString(json, ['toCountry', 'to_country'], fallback: '-'),
      passportNo: _pickNullableString(json, ['passportNo', 'passport_no']),
      agencyTotalCost: agencyTotalCostValue,
      paidAmount: paidAmountValue,
      status: status,
      statusLabel: _pickString(json, [
        'statusLabel',
        'status_label',
      ], fallback: status.replaceAll('_', ' ')),
      appointmentDate: _pickNullableString(json, [
        'appointmentDate',
        'appointment_date',
      ]),
      medicalExpiryDate: _pickNullableString(json, [
        'medicalExpiryDate',
        'medical_expiry_date',
      ]),
      policeClearanceExpiryDate: _pickNullableString(json, [
        'policeClearanceExpiryDate',
        'police_clearance_expiry_date',
      ]),
      visaExpiryDate: _pickNullableString(json, [
        'visaExpiryDate',
        'visa_expiry_date',
      ]),
      hasAdvancePayout: hasAdvancePayoutValue,
      hasAfterVisaPayout: hasAfterVisaPayoutValue,
      hasBeforeFlightPayout: hasBeforeFlightPayoutValue,
      paymentStepCount: _pickInt(json, [
        'paymentStepCount',
        'payment_step_count',
      ]),
      isReturn: _pickBool(json, ['isReturn', 'is_return'], fallback: false),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  final normalized = value?.toString().trim().replaceAll(',', '') ?? '';
  if (normalized.isEmpty) return fallback;

  return int.tryParse(normalized) ??
      double.tryParse(normalized)?.toInt() ??
      fallback;
}

String _pickString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty)
      return value.toString();
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

bool _pickBool(
  Map<String, dynamic> json,
  List<String> keys, {
  required bool fallback,
}) {
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

class MyAppointmentsResponse {
  final int count;
  final int pageSize;
  final List<ReceivedBookingItemDto> results;

  int get totalPages {
    if (pageSize <= 0) return 1;
    final pages = (count / pageSize).ceil();
    return pages > 0 ? pages : 1;
  }

  const MyAppointmentsResponse({
    required this.count,
    required this.pageSize,
    required this.results,
  });

  factory MyAppointmentsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = (json['results'] as List?) ?? const [];
    return MyAppointmentsResponse(
      count: _toInt(json['count']),
      pageSize: _toInt(json['pageSize'], fallback: 10),
      results: rawResults
          .whereType<Map>()
          .map(
            (item) => ReceivedBookingItemDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}

class ReceivedBookingsResponse {
  final int count;
  final int pageSize;
  final List<ReceivedBookingItemDto> results;

  const ReceivedBookingsResponse({
    required this.count,
    required this.pageSize,
    required this.results,
  });

  factory ReceivedBookingsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = (json['results'] as List?) ?? const [];
    return ReceivedBookingsResponse(
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      pageSize: json['pageSize'] is int
          ? json['pageSize'] as int
          : int.tryParse(json['pageSize']?.toString() ?? '10') ?? 10,
      results: rawResults
          .whereType<Map>()
          .map(
            (item) => ReceivedBookingItemDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
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
  final String? meeting;

  const ReceivedBookingItemDto({
    required this.id,
    required this.workPermitId,
    required this.workPermitSlug,
    required this.name,
    required this.toCountry,
    required this.serviceType,
    required this.createdAt,
    required this.status,
    required this.statusLabel,
    this.fromCountry,
    this.appointmentDate,
    this.medicalExpiryDate,
    this.policeClearanceExpiryDate,
    this.visaExpiryDate,
    this.passportNo,
    this.packagePrice,
    this.paidAmount,
    this.meeting,
  });

  factory ReceivedBookingItemDto.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'APPLIED_FILE';
    return ReceivedBookingItemDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      workPermitId: json['workPermitId'] is int
          ? json['workPermitId'] as int
          : int.tryParse(json['workPermitId']?.toString() ?? '0') ?? 0,
      workPermitSlug: json['workPermitSlug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown User',
      fromCountry: json['fromCountry']?.toString(),
      toCountry: json['toCountry']?.toString() ?? 'Unknown Country',
      serviceType: json['serviceType']?.toString() ?? 'Work Permit',
      createdAt: json['createdAt']?.toString() ?? '',
      status: status,
      statusLabel: status
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' '),
      appointmentDate: json['appointmentDate']?.toString(),
      medicalExpiryDate: json['medicalExpiryDate']?.toString(),
      policeClearanceExpiryDate: json['policeClearanceExpiryDate']?.toString(),
      visaExpiryDate: json['visaExpiryDate']?.toString(),
      passportNo: json['passportNo']?.toString(),
      packagePrice: _pickInt(json, [
        'agencyTotalCost',
        'agency_total_cost',
        'packagePrice',
        'package_price',
      ]),
      paidAmount: _pickInt(json, ['paidAmount', 'paid_amount']),
      meeting: json['meeting']?.toString(),
    );
  }
}
