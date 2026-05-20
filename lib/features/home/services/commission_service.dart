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

class WPMyBookingGETProps {
  final int id;
  final String workPermitId;
  final String workPermitSlug;
  final String fromCountry;
  final String toCountry;
  final String serviceType;
  final DateTime createdAt;
  final String statusLabel;
  final String name;
  final String passportNo;
  final int customerTotal;
  final int paidAmount;
  final int commission;

  const WPMyBookingGETProps({
    required this.id,
    required this.workPermitId,
    required this.workPermitSlug,
    required this.fromCountry,
    required this.toCountry,
    required this.serviceType,
    required this.createdAt,
    required this.statusLabel,
    required this.name,
    required this.passportNo,
    required this.customerTotal,
    required this.paidAmount,
    required this.commission,
  });

  factory WPMyBookingGETProps.fromJson(Map<String, dynamic> json) {
    return WPMyBookingGETProps(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      workPermitId: json['workPermitId']?.toString() ?? '',
      workPermitSlug: json['workPermitSlug']?.toString() ?? '',
      fromCountry: json['fromCountry']?.toString() ?? '',
      toCountry: json['toCountry']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      statusLabel: json['statusLabel']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      passportNo: json['passportNo']?.toString() ?? '',
      customerTotal: _toInt(json['customerTotal']),
      paidAmount: _toInt(json['paidAmount']),
      commission: _toInt(json['commission']),
    );
  }

  static int _toInt(dynamic val) {
    if (val is num) return val.toInt();
    if (val is String) return double.tryParse(val)?.toInt() ?? int.tryParse(val) ?? 0;
    return 0;
  }
}

class CommissionService {
  CommissionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<TypesHandler<WPMyBookingGETProps>> getCommissions({
    String? search,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'status': '', // In this specific component, status is always an empty string
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParams['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParams['to_date'] = toDate;
    }

    final response = await _apiClient.get(
      '/booking/wp/my-bookings/',
      queryParameters: queryParams,
    );

    final data = response.data;
    final map = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data as Map);

    final rawResults = map['results'] as List? ?? const [];

    return TypesHandler<WPMyBookingGETProps>(
      count: map['count'] is int ? map['count'] as int : int.tryParse('${map['count']}') ?? 0,
      next: map['next']?.toString(),
      previous: map['previous']?.toString(),
      results: rawResults
          .whereType<Map>()
          .map((e) => WPMyBookingGETProps.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pageSize: map['pageSize'] is int ? map['pageSize'] as int : int.tryParse('${map['pageSize']}') ?? 10,
    );
  }
}
