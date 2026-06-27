class CustomerProfileModel {
  final String? id;
  final String? image;
  final String? dob;
  final String? gender;
  final String? passportNo;
  final String? passportExpiry;
  final String? passportIssue;
  final String? address;
  final CustomerLocation? policeStation;
  final CustomerLocation? district;
  final List<String> services;
  final List<CustomerNamedItem> countries;
  final List<CustomerNamedItem> workTypes;
  final CustomerUser? user;

  const CustomerProfileModel({
    this.id,
    this.image,
    this.dob,
    this.gender,
    this.passportNo,
    this.passportExpiry,
    this.passportIssue,
    this.address,
    this.policeStation,
    this.district,
    this.services = const [],
    this.countries = const [],
    this.workTypes = const [],
    this.user,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      id: _str(json, const ['id']),
      image: _str(json, const ['image']),
      dob: _str(json, const ['dob', 'date_of_birth']),
      gender: _str(json, const ['gender']),
      passportNo: _str(json, const ['passportNo', 'passport_no']),
      passportExpiry: _str(json, const ['passportExpiry', 'passport_expiry']),
      passportIssue: _str(json, const ['passportIssue', 'passport_issue']),
      address: _str(json, const ['address']),
      policeStation: _location(json, const ['policeStation', 'police_station']),
      district: _location(json, const ['district']),
      services: _stringList(json['services']),
      countries: _namedList(json['countries']),
      workTypes: _namedList(json['workTypes'] ?? json['work_types']),
      user: _parseUser(json),
    );
  }

  static CustomerUser? _parseUser(Map<String, dynamic> json) {
    final u = json['user'];
    if (u is Map<String, dynamic>) return CustomerUser.fromJson(u);
    // Some APIs inline user fields at the top level
    final name = _str(json, const ['fullName', 'full_name']);
    final email = _str(json, const ['email']);
    final phone = _str(json, const ['phone']);
    if (name != null || email != null || phone != null) {
      return CustomerUser(fullName: name, email: email, phone: phone);
    }
    return null;
  }
}

class CustomerUser {
  final String? fullName;
  final String? email;
  final String? phone;

  const CustomerUser({this.fullName, this.email, this.phone});

  factory CustomerUser.fromJson(Map<String, dynamic> json) {
    return CustomerUser(
      fullName: _str(json, const ['fullName', 'full_name']),
      email: _str(json, const ['email']),
      phone: _str(json, const ['phone']),
    );
  }
}

class CustomerLocation {
  final dynamic id;
  final String name;

  const CustomerLocation({this.id, this.name = ''});

  factory CustomerLocation.fromJson(Map<String, dynamic> json) {
    return CustomerLocation(
      id: json['id'],
      name: _str(json, const ['name']) ?? '',
    );
  }
}

class CustomerNamedItem {
  final String name;

  const CustomerNamedItem({required this.name});

  factory CustomerNamedItem.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CustomerNamedItem(
        name: _str(json, const ['name', 'title', 'label']) ?? '',
      );
    }
    return CustomerNamedItem(name: json.toString());
  }
}

// ── helpers ───────────────────────────────────────────────────────────────────

String? _str(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final v = json[key];
    if (v is String && v.trim().isNotEmpty) return v;
    if (v is num) return v.toString();
  }
  return null;
}

CustomerLocation? _location(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final v = json[key];
    if (v is Map<String, dynamic>) return CustomerLocation.fromJson(v);
    if (v is String && v.trim().isNotEmpty) return CustomerLocation(name: v);
  }
  return null;
}

List<String> _stringList(dynamic raw) {
  if (raw is List) {
    return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }
  return [];
}

List<CustomerNamedItem> _namedList(dynamic raw) {
  if (raw is List) {
    return raw.map((e) => CustomerNamedItem.fromJson(e)).toList();
  }
  return [];
}
