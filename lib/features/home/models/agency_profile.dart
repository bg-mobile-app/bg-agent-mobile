class AgentProfileProps {
  final AgentUser user;
  final String? image;
  final String? gender;
  final String? dob;
  final String? agencyName;
  final String? agencyAddress;
  final String? address;
  final String? policeStation;
  final String? district;
  final String? nidImage;
  final String? tradeLicenseImage;

  AgentProfileProps({
    required this.user,
    this.image,
    this.gender,
    this.dob,
    this.agencyName,
    this.agencyAddress,
    this.address,
    this.policeStation,
    this.district,
    this.nidImage,
    this.tradeLicenseImage,
  });

  factory AgentProfileProps.fromJson(Map<String, dynamic> json) {
    return AgentProfileProps(
      user: AgentUser.fromJson((json['user'] as Map<String, dynamic>?) ?? {}),
      image: _readNullableString(json, const ['image']),
      gender: _readNullableString(json, const ['gender']),
      dob: _readNullableString(json, const ['dob']),
      agencyName: _readNullableString(json, const ['agencyName', 'agency_name']),
      agencyAddress: _readNullableString(json, const ['agencyAddress', 'agency_address']),
      address: _readNullableString(json, const ['address']),
      policeStation: _readNullableString(json, const ['policeStation', 'police_station']),
      district: _readNullableString(json, const ['district']),
      nidImage: _readNullableString(json, const ['nidImage', 'nid_image']),
      tradeLicenseImage: _readNullableString(json, const ['tradeLicenseImage', 'trade_license_image']),
    );
  }
}

class AgentUser {
  final String? userCode;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? status;

  AgentUser({
    this.userCode,
    this.fullName,
    this.email,
    this.phone,
    this.status,
  });

  factory AgentUser.fromJson(Map<String, dynamic> json) {
    return AgentUser(
      userCode: _readNullableString(json, const ['userCode', 'user_code']),
      fullName: _readNullableString(json, const ['fullName', 'full_name']),
      email: _readNullableString(json, const ['email']),
      phone: _readNullableString(json, const ['phone']),
      status: _readNullableString(json, const ['status']),
    );
  }
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return null;
}
