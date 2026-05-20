class RecruitingAgencyMeDetailsProps {
  final dynamic id;
  final String? image;
  final String agencyName;
  final String status;
  final Owner? owner;
  final List<Document> documents;
  final List<BankInformation> bankInformation;
  final String? agencyAddress;
  final String? agencyPhone;
  final District? district;
  final PoliceStation? policeStation;

  RecruitingAgencyMeDetailsProps({
    required this.id,
    this.image,
    required this.agencyName,
    required this.status,
    this.owner,
    this.documents = const [],
    this.bankInformation = const [],
    this.agencyAddress,
    this.agencyPhone,
    this.district,
    this.policeStation,
  });

  factory RecruitingAgencyMeDetailsProps.fromJson(Map<String, dynamic> json) {
    return RecruitingAgencyMeDetailsProps(
      id: json['id'],
      image: json['image'],
      agencyName: _readString(json, const ['agencyName', 'agency_name']),
      status: json['status'] ?? '',
      owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
      documents: (json['documents'] as List?)?.map((e) => Document.fromJson(e)).toList() ?? [],
      bankInformation: (json['bankInformation'] as List? ?? json['bank_information'] as List?)
              ?.map((e) => BankInformation.fromJson(e))
              .toList() ??
          [],
      agencyAddress: _readNullableString(json, const ['agencyAddress', 'agency_address']),
      agencyPhone: _readNullableString(json, const ['agencyPhone', 'agency_phone']),
      district: json['district'] != null ? District.fromJson(json['district']) : null,
      policeStation: (json['policeStation'] ?? json['police_station']) != null
          ? PoliceStation.fromJson(json['policeStation'] ?? json['police_station'])
          : null,
    );
  }
}

class Owner {
  final dynamic id;
  final String fullName;
  final String email;
  final String phone;

  Owner({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      fullName: _readString(json, const ['fullName', 'full_name']),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class Document {
  final String? rlNo;
  final String? nidImage;
  final String? tradeLicenseImage;
  final String? rlLicenseImage;
  final String? civilAviationLicenseImage;

  Document({
    this.rlNo,
    this.nidImage,
    this.tradeLicenseImage,
    this.rlLicenseImage,
    this.civilAviationLicenseImage,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      rlNo: _readNullableString(json, const ['rlNo', 'rl_no']),
      nidImage: _readNullableString(json, const ['nidImage', 'nid_image']),
      tradeLicenseImage: _readNullableString(json, const ['tradeLicenseImage', 'trade_license_image']),
      rlLicenseImage: _readNullableString(json, const ['rlLicenseImage', 'rl_license_image']),
      civilAviationLicenseImage:
          _readNullableString(json, const ['civilAviationLicenseImage', 'civil_aviation_license_image']),
    );
  }
}

class BankInformation {
  final String bankName;
  final String branchName;
  final String accountName;
  final String accountNo;
  final String routingNo;

  BankInformation({
    required this.bankName,
    required this.branchName,
    required this.accountName,
    required this.accountNo,
    required this.routingNo,
  });

  factory BankInformation.fromJson(Map<String, dynamic> json) {
    return BankInformation(
      bankName: _readString(json, const ['bankName', 'bank_name']),
      branchName: _readString(json, const ['branchName', 'branch_name']),
      accountName: _readString(json, const ['accountName', 'account_name']),
      accountNo: _readString(json, const ['accountNo', 'account_no']),
      routingNo: _readString(json, const ['routingNo', 'routing_no']),
    );
  }
}

class District {
  final dynamic id;
  final String name;

  District({this.id, required this.name});

  factory District.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return District(
        id: json['id'],
        name: json['name'] ?? '',
      );
    } else if (json is String) {
      return District(
        id: null,
        name: json,
      );
    }
    return District(id: null, name: '');
  }
}

class PoliceStation {
  final dynamic id;
  final String name;

  PoliceStation({this.id, required this.name});

  factory PoliceStation.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return PoliceStation(
        id: json['id'],
        name: json['name'] ?? '',
      );
    } else if (json is String) {
      return PoliceStation(
        id: null,
        name: json,
      );
    }
    return PoliceStation(id: null, name: '');
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
  }
  return '';
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
  }
  return null;
}
