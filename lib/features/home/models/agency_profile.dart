class RecruitingAgencyMeDetailsProps {
  final AgentUser? owner;
  final String? image;
  final String? agencyName;
  final String? agencyPhone;
  final String? agencyAddress;
  final RecruitingAgencyLocation? district;
  final RecruitingAgencyLocation? policeStation;
  final List<RecruitingAgencyBankInformation> bankInformation;
  final List<RecruitingAgencyDocument> documents;

  RecruitingAgencyMeDetailsProps({
    this.owner,
    this.image,
    this.agencyName,
    this.agencyPhone,
    this.agencyAddress,
    this.district,
    this.policeStation,
    this.bankInformation = const [],
    this.documents = const [],
  });

  factory RecruitingAgencyMeDetailsProps.fromJson(Map<String, dynamic> json) {
    return RecruitingAgencyMeDetailsProps(
      owner: json['owner'] is Map<String, dynamic>
          ? AgentUser.fromJson(json['owner'] as Map<String, dynamic>)
          : (json['user'] is Map<String, dynamic>
              ? AgentUser.fromJson(json['user'] as Map<String, dynamic>)
              : null),
      image: _readNullableString(json, const ['image']),
      agencyName: _readNullableString(json, const ['agencyName', 'agency_name']),
      agencyPhone: _readNullableString(json, const ['agencyPhone', 'agency_phone']),
      agencyAddress: _readNullableString(json, const ['agencyAddress', 'agency_address']),
      district: json['district'] is Map<String, dynamic>
          ? RecruitingAgencyLocation.fromJson(json['district'] as Map<String, dynamic>)
          : null,
      policeStation: json['policeStation'] is Map<String, dynamic>
          ? RecruitingAgencyLocation.fromJson(json['policeStation'] as Map<String, dynamic>)
          : (json['police_station'] is Map<String, dynamic>
              ? RecruitingAgencyLocation.fromJson(json['police_station'] as Map<String, dynamic>)
              : null),
      bankInformation: _toList(json, const ['bankInformation', 'bank_information'])
          .map((e) => RecruitingAgencyBankInformation.fromJson(e))
          .toList(),
      documents: _toList(json, const ['documents'])
          .map((e) => RecruitingAgencyDocument.fromJson(e))
          .toList(),
    );
  }
}

class AgentProfileProps extends RecruitingAgencyMeDetailsProps {
  AgentProfileProps({
    required AgentUser user,
    String? image,
    String? agencyName,
    String? agencyAddress,
    String? district,
    String? policeStation,
    String? nidImage,
    String? tradeLicenseImage,
  }) : super(
          owner: user,
          image: image,
          agencyName: agencyName,
          agencyAddress: agencyAddress,
          district: district != null ? RecruitingAgencyLocation(name: district) : null,
          policeStation: policeStation != null ? RecruitingAgencyLocation(name: policeStation) : null,
          documents: [
            RecruitingAgencyDocument(
              nidImage: nidImage,
              tradeLicenseImage: tradeLicenseImage,
            ),
          ],
        );

  factory AgentProfileProps.fromJson(Map<String, dynamic> json) => AgentProfileProps(
        user: AgentUser.fromJson((json['user'] as Map<String, dynamic>?) ?? {}),
        image: _readNullableString(json, const ['image']),
        agencyName: _readNullableString(json, const ['agencyName', 'agency_name']),
        agencyAddress: _readNullableString(json, const ['agencyAddress', 'agency_address']),
        district: _readNullableString(json, const ['district']),
        policeStation: _readNullableString(json, const ['policeStation', 'police_station']),
        nidImage: _readNullableString(json, const ['nidImage', 'nid_image']),
        tradeLicenseImage: _readNullableString(json, const ['tradeLicenseImage', 'trade_license_image']),
      );
}

class RecruitingAgencyLocation {
  final dynamic id;
  final String name;
  RecruitingAgencyLocation({this.id, this.name = ''});

  factory RecruitingAgencyLocation.fromJson(Map<String, dynamic> json) => RecruitingAgencyLocation(
        id: json['id'],
        name: _readNullableString(json, const ['name']) ?? '',
      );
}

class RecruitingAgencyBankInformation {
  final String? bankName;
  final String? branchName;
  final String? accountName;
  final String? accountNo;
  final String? routingNo;

  RecruitingAgencyBankInformation({
    this.bankName,
    this.branchName,
    this.accountName,
    this.accountNo,
    this.routingNo,
  });

  factory RecruitingAgencyBankInformation.fromJson(Map<String, dynamic> json) => RecruitingAgencyBankInformation(
        bankName: _readNullableString(json, const ['bankName', 'bank_name']),
        branchName: _readNullableString(json, const ['branchName', 'branch_name']),
        accountName: _readNullableString(json, const ['accountName', 'account_name']),
        accountNo: _readNullableString(json, const ['accountNo', 'account_no']),
        routingNo: _readNullableString(json, const ['routingNo', 'routing_no']),
      );
}

class RecruitingAgencyDocument {
  final String? nidImage;
  final String? tradeLicenseImage;
  final String? rlLicenseImage;
  final String? civilAviationLicenseImage;
  final String? rlNo;

  RecruitingAgencyDocument({
    this.nidImage,
    this.tradeLicenseImage,
    this.rlLicenseImage,
    this.civilAviationLicenseImage,
    this.rlNo,
  });

  factory RecruitingAgencyDocument.fromJson(Map<String, dynamic> json) => RecruitingAgencyDocument(
        nidImage: _readNullableString(json, const ['nidImage', 'nid_image']),
        tradeLicenseImage: _readNullableString(json, const ['tradeLicenseImage', 'trade_license_image']),
        rlLicenseImage: _readNullableString(json, const ['rlLicenseImage', 'rl_license_image']),
        civilAviationLicenseImage: _readNullableString(json, const ['civilAviationLicenseImage', 'civil_aviation_license_image']),
        rlNo: _readNullableString(json, const ['rlNo', 'rl_no']),
      );
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

List<Map<String, dynamic>> _toList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
  }
  return const [];
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return null;
}
