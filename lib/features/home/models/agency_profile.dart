class RecruitingAgencyMeDetailsProps {
  final int id;
  final String? image;
  final String agencyName;
  final String status;
  final Owner? owner;
  final List<Document> documents;
  final List<BankInformation> bankInformation;
  final String? agencyAddress;
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
    this.district,
    this.policeStation,
  });

  factory RecruitingAgencyMeDetailsProps.fromJson(Map<String, dynamic> json) {
    return RecruitingAgencyMeDetailsProps(
      id: json['id'] ?? 0,
      image: json['image'],
      agencyName: json['agencyName'] ?? '',
      status: json['status'] ?? '',
      owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
      documents: (json['documents'] as List?)?.map((e) => Document.fromJson(e)).toList() ?? [],
      bankInformation: (json['bankInformation'] as List?)?.map((e) => BankInformation.fromJson(e)).toList() ?? [],
      agencyAddress: json['agencyAddress'],
      district: json['district'] != null ? District.fromJson(json['district']) : null,
      policeStation: json['policeStation'] != null ? PoliceStation.fromJson(json['policeStation']) : null,
    );
  }
}

class Owner {
  final int id;
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
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
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
      rlNo: json['rlNo'],
      nidImage: json['nidImage'],
      tradeLicenseImage: json['tradeLicenseImage'],
      rlLicenseImage: json['rlLicenseImage'],
      civilAviationLicenseImage: json['civilAviationLicenseImage'],
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
      bankName: json['bankName'] ?? '',
      branchName: json['branchName'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNo: json['accountNo'] ?? '',
      routingNo: json['routingNo'] ?? '',
    );
  }
}

class District {
  final String name;

  District({required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      name: json['name'] ?? '',
    );
  }
}

class PoliceStation {
  final String name;

  PoliceStation({required this.name});

  factory PoliceStation.fromJson(Map<String, dynamic> json) {
    return PoliceStation(
      name: json['name'] ?? '',
    );
  }
}
