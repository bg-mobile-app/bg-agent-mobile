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

class PaymentsHistory {
  final int id;
  final String postId;
  final String bookingId;
  final String terminal;
  final String passportNo;
  final String step;
  final String sequence;
  final String transactionType;
  final String status;
  final int amount;
  final DateTime collectedAt;

  const PaymentsHistory({
    required this.id,
    required this.postId,
    required this.bookingId,
    required this.terminal,
    required this.passportNo,
    required this.step,
    required this.sequence,
    required this.transactionType,
    required this.status,
    required this.amount,
    required this.collectedAt,
  });

  factory PaymentsHistory.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    int parsedAmount = 0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toInt();
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount)?.toInt() ?? int.tryParse(rawAmount) ?? 0;
    }

    return PaymentsHistory(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      postId: json['postId']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      terminal: json['terminal']?.toString() ?? '',
      passportNo: json['passportNo']?.toString() ?? '',
      step: json['step']?.toString() ?? '',
      sequence: json['sequence']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: parsedAmount,
      collectedAt: DateTime.tryParse(json['collectedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  PaymentsHistory copyWith({
    int? id,
    String? postId,
    String? bookingId,
    String? terminal,
    String? passportNo,
    String? step,
    String? sequence,
    String? transactionType,
    String? status,
    int? amount,
    DateTime? collectedAt,
  }) {
    return PaymentsHistory(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      bookingId: bookingId ?? this.bookingId,
      terminal: terminal ?? this.terminal,
      passportNo: passportNo ?? this.passportNo,
      step: step ?? this.step,
      sequence: sequence ?? this.sequence,
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }
}

class PaymentService {
  PaymentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<TypesHandler<PaymentsHistory>> getPaymentsHistory({
    String? status,
    String? search,
    int currentPage = 1,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    queryParams['page'] = currentPage;

    final response = await _apiClient.get(
      '/payment/history-agency/',
      queryParameters: queryParams,
    );

    final data = response.data;
    final map = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data as Map);

    final rawResults = map['results'] as List? ?? const [];

    return TypesHandler<PaymentsHistory>(
      count: map['count'] is int ? map['count'] as int : int.tryParse('${map['count']}') ?? 0,
      next: map['next']?.toString(),
      previous: map['previous']?.toString(),
      results: rawResults
          .whereType<Map>()
          .map((e) => PaymentsHistory.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pageSize: map['pageSize'] is int ? map['pageSize'] as int : int.tryParse('${map['pageSize']}') ?? 10,
    );
  }
}
