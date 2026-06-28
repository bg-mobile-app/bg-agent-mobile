import 'home_models.dart';

class FavouriteItem {
  final int id;
  final WorkPermitItem workPermit;
  final DateTime createdAt;

  FavouriteItem({
    required this.id,
    required this.workPermit,
    required this.createdAt,
  });

  factory FavouriteItem.fromJson(Map<String, dynamic> json) {
    final wp = json['workPermit'] ?? json['work_permit'] ?? {};
    final country = wp['country'] ?? {};
    final jobCategory = wp['job_category'] ?? {};

    return FavouriteItem(
      id: json['id'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      workPermit: WorkPermitItem(
        id: wp['id'],
        title: wp['title'] ?? 'Unknown',
        slug: wp['slug'] ?? '',
        image: wp['image'] ?? '',
        customerPrice: _parseInt(wp['customerPrice'] ?? wp['customer_price']),
        agentPrice: _parseInt(wp['agentPrice'] ?? wp['agent_price']),
        countryName: country['name'] ?? '',
        countryFlag: country['flag'] ?? '',
        workType: jobCategory['name'] ?? '',
        selectionType: wp['selectionType'] ?? wp['selection_type'] ?? '',
        createdAt: DateTime.tryParse(wp['created_at'] ?? '') ?? DateTime.now(),
      ),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
