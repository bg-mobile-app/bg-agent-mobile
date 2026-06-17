import '../../../common/services/api_client.dart';

class PayoutRequestPage {
  const PayoutRequestPage({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<PayoutRequestItem> results;
}

class PayoutRequestItem {
  const PayoutRequestItem({
    required this.id,
    required this.postId,
    required this.bookingId,
    required this.customerName,
    required this.passportNo,
    required this.processingBy,
    required this.referenceBy,
    required this.rlNo,
    required this.step,
    required this.status,
    required this.totalAmount,
    required this.paidAmount,
    required this.currentRequest,
  });

  final int id;
  final String postId;
  final String bookingId;
  final String customerName;
  final String passportNo;
  final String processingBy;
  final String referenceBy;
  final String rlNo;
  final String step;
  final String status;
  final int totalAmount;
  final int paidAmount;
  final String currentRequest;

  factory PayoutRequestItem.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();

      final normalized = value?.toString().trim().replaceAll(',', '') ?? '';
      if (normalized.isEmpty) return 0;
      return int.tryParse(normalized) ?? double.tryParse(normalized)?.toInt() ?? 0;
    }

    String toStringValue(dynamic value) {
      if (value == null) return '';
      return value.toString().trim();
    }

    return PayoutRequestItem(
      id: toInt(json['id']),
      postId: json['postId']?.toString() ?? json['post_id']?.toString() ?? '-',
      bookingId:
          json['booking']?.toString() ??
          json['bookingId']?.toString() ??
          json['booking_id']?.toString() ??
          '-',
      customerName:
          json['customerName']?.toString() ??
          json['customer_name']?.toString() ??
          '-',
      passportNo:
          json['passportNo']?.toString() ??
          json['passport_no']?.toString() ??
          '-',
      processingBy:
          json['processingBy']?.toString() ??
          json['processing_by']?.toString() ??
          '-',
      referenceBy:
          json['referenceBy']?.toString() ??
          json['reference_by']?.toString() ??
          '-',
      rlNo: json['rlNo']?.toString() ?? json['rl_no']?.toString() ?? '-',
      step: json['step']?.toString() ?? '-',
      status: json['status']?.toString() ?? '-',
      totalAmount: toInt(json['totalAmount'] ??
          json['total_amount'] ??
          json['agencyTotalCost'] ??
          json['agency_total_cost'] ??
          json['packagePrice'] ??
          json['package_price'] ??
          json['total']),
      paidAmount: toInt(json['paidAmount'] ??
          json['paid_amount'] ??
          json['customerAmount'] ??
          json['customer_amount'] ??
          json['paid']),
      currentRequest: toStringValue(json['currentRequest']).isNotEmpty
          ? toStringValue(json['currentRequest'])
          : toStringValue(json['current_request']).isNotEmpty
              ? toStringValue(json['current_request'])
              : toStringValue(json['currentAmount']).isNotEmpty
                  ? toStringValue(json['currentAmount'])
                  : toStringValue(json['current_amount']).isNotEmpty
                      ? toStringValue(json['current_amount'])
                      : toStringValue(json['status']).isNotEmpty
                          ? toStringValue(json['status'])
                          : '-',
    );
  }
}

class PayoutRequestService {
  PayoutRequestService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PayoutRequestPage> getRequests({
    String? status,
    String? search,
    String? branch,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page};
    if ((status ?? '').isNotEmpty) query['status'] = status;
    if ((search ?? '').isNotEmpty) query['search'] = search;
    if ((branch ?? '').isNotEmpty) query['branch'] = branch;

    final response = await _apiClient.get(
      '/payment/agency/payout-request/',
      queryParameters: query,
    );
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data as Map);
    final rawResults = data['results'] as List? ?? const [];

    return PayoutRequestPage(
      count: int.tryParse('${data['count'] ?? 0}') ?? 0,
      next: data['next']?.toString(),
      previous: data['previous']?.toString(),
      results: rawResults
          .whereType<Map>()
          .map((e) => PayoutRequestItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
