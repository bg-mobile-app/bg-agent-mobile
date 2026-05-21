import '../../../common/services/api_client.dart';

class ReceivePaymentHistoryPage {
  const ReceivePaymentHistoryPage({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<ReceivePaymentHistoryItem> results;
}

class ReceivePaymentHistoryItem {
  const ReceivePaymentHistoryItem({
    required this.id,
    required this.paymentReference,
    required this.totalAmount,
    required this.status,
    required this.paidAt,
  });

  final int id;
  final String paymentReference;
  final double totalAmount;
  final String status;
  final DateTime? paidAt;

  String get invoiceLabel {
    if (paymentReference.isNotEmpty) return paymentReference;
    return '#INV-$id';
  }

  factory ReceivePaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['totalAmount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '') ?? 0;

    return ReceivePaymentHistoryItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      paymentReference: json['paymentReference']?.toString() ?? '',
      totalAmount: amount,
      status: json['status']?.toString() ?? '',
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
    );
  }
}

class ReceivePaymentHistoryService {
  ReceivePaymentHistoryService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ReceivePaymentHistoryPage> getHistory({
    String status = '',
    String search = '',
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (status.isNotEmpty) query['status'] = status;
    if (search.isNotEmpty) query['search'] = search;

    final response = await _apiClient.get('/payment/history-agency/', queryParameters: query);
    final data = response.data;
    final map = data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data as Map);
    final rawResults = map['results'] as List? ?? const [];

    return ReceivePaymentHistoryPage(
      count: map['count'] is int ? map['count'] as int : int.tryParse('${map['count']}') ?? 0,
      next: map['next']?.toString(),
      previous: map['previous']?.toString(),
      results: rawResults.whereType<Map>().map((e) => ReceivePaymentHistoryItem.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
