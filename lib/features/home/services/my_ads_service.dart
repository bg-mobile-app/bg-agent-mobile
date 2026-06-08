import 'package:flutter/foundation.dart';

import '../../../common/services/api_client.dart';

class MyAdsService {
  final ApiClient _apiClient = ApiClient();

  Future<MyAdsResponse> getOwnerOwnAdsList({
    required int page,
    String search = '',
    String status = '',
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page};
      if (search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (status.trim().isNotEmpty) {
        queryParameters['status'] = status.trim();
      }

      final response = await _apiClient.get(
        '/work-permits/my-permits/',
        queryParameters: queryParameters,
      );

      return MyAdsResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stacktrace) {
      debugPrint('Error fetching owner ads: $e\n$stacktrace');
      rethrow;
    }
  }
}

class MyAdsResponse {
  const MyAdsResponse({
    required this.count,
    required this.pageSize,
    required this.results,
  });

  final int count;
  final int pageSize;
  final List<MyAdItem> results;

  int get totalPages => pageSize <= 0 ? 1 : (count / pageSize).ceil();

  factory MyAdsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = (json['results'] as List?) ?? const [];
    return MyAdsResponse(
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      pageSize: json['pageSize'] is int
          ? json['pageSize'] as int
          : int.tryParse(json['pageSize']?.toString() ?? '10') ?? 10,
      results: rawResults
          .whereType<Map>()
          .map((item) => MyAdItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class MyAdItem {
  const MyAdItem({
    required this.id,
    required this.title,
    required this.status,
    required this.image,
    required this.country,
    required this.isBn,
  });

  final int id;
  final String title;
  final String status;
  final String image;
  final String country;
  final bool isBn;

  factory MyAdItem.fromJson(Map<String, dynamic> json) {
    final countryJson = json['country'];
    final country = countryJson is Map<String, dynamic>
        ? countryJson['name']?.toString() ?? 'Unknown'
        : 'Unknown';

    return MyAdItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Untitled',
      status: json['status']?.toString() ?? 'UNKNOWN',
      image: json['image']?.toString() ?? '',
      country: country,
      isBn: _parseBool(json['isBn'] ?? json['is_bn']),
    );
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final text = value.trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }
  return false;
}
