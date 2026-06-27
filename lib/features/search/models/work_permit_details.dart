import 'package:flutter/foundation.dart';

class AgencyProps {
  final int id;
  final String name;
  final String phone;
  final String status;
  final String rlNumber;
  final String logo;

  AgencyProps({
    required this.id,
    required this.name,
    this.phone = '',
    this.status = '',
    required this.rlNumber,
    required this.logo,
  });

  factory AgencyProps.fromJson(Map<String, dynamic> json) {
    final documents = json['documents'];
    String documentRlNumber = '';
    String documentLogo = '';
    if (documents is List && documents.isNotEmpty) {
      final firstDocument = documents.first;
      if (firstDocument is Map) {
        documentRlNumber =
            (firstDocument['rlNo'] ?? firstDocument['rl_no'] ?? '').toString();
        documentLogo = (firstDocument['image'] ?? '').toString();
      }
    }

    return AgencyProps(
      id: json['id'] ?? 0,
      name:
          json['name'] ??
          json['agencyName'] ??
          json['agency_name'] ??
          'Unknown Agency',
      phone: json['phone'] ?? json['agencyPhone'] ?? json['agency_phone'] ?? '',
      status: json['status'] ?? '',
      rlNumber: (json['rlNumber'] ?? json['rl_number'] ?? documentRlNumber)
          .toString(),
      logo: json['logo'] ?? documentLogo,
    );
  }
}

class WorkTypeProps {
  final int id;
  final String name;

  WorkTypeProps({required this.id, required this.name});

  factory WorkTypeProps.fromJson(Map<String, dynamic> json) {
    return WorkTypeProps(id: json['id'] ?? 0, name: json['name'] ?? 'Unknown');
  }
}

class PaymentStepProps {
  final String name;
  final double amount;
  final String percentage;

  PaymentStepProps({
    required this.name,
    required this.amount,
    required this.percentage,
  });

  factory PaymentStepProps.fromJson(
    Map<String, dynamic> json, {
    bool isBn = false,
  }) {
    final rawName = (
      json['name'] ??
      json['step'] ??
      json['title'] ??
      json['label'] ??
      json['paymentStepName'] ??
      json['stepName'] ??
      json['payment_step_name'] ??
      json['payment_step'] ??
      ''
    ).toString();
    final amountValue =
        json['amount'] ??
        json['price'] ??
        json['value'] ??
        json['total'] ??
        json['priceAmount'] ??
        json['price_amount'] ??
        json['sequence'];
    final percentageValue = json['percentage'] ?? json['percent'] ?? '';
    return PaymentStepProps(
      name: _formatEnumLabel(rawName, isBn: isBn),
      amount: _parseAmount(amountValue),
      percentage: percentageValue.toString(),
    );
  }

  factory PaymentStepProps.fromFallback({
    required String name,
    required double amount,
    String percentage = '',
    bool isBn = false,
  }) {
    return PaymentStepProps(
      name: _formatEnumLabel(name, isBn: isBn),
      amount: amount,
      percentage: percentage,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _formatEnumLabel(String value, {bool isBn = false}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    final normalized = trimmed.toLowerCase();
    if (isBn) {
      if (normalized.contains('advance') || normalized.contains('অগ্রিম')) {
        return 'অগ্রিম';
      }
      if (normalized.contains('after') && normalized.contains('visa')) {
        return 'ভিসার পর';
      }
      if (normalized.contains('before') && normalized.contains('flight')) {
        return 'ফ্লাইটের আগে';
      }
    }

    return trimmed
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }
}

class WorkPermitDetails {
  final int id;
  final String slug;
  final String status;
  final int customerPrice;
  final int? agentPrice;
  final int? packagePrice;
  final String countryName;
  final String countryFlag;
  final String image;
  final AgencyProps? agency;
  final WorkTypeProps? workType;
  final int favoriteCount;
  final int bookedQuota;
  final int availableQuota;
  final String title;
  final String companyName;
  final String companyAddress;
  final String visaSponsorName;
  final String selectionType;
  final String visaOccupation;
  final int salary;
  final String currency;
  final String currencyFlag;
  final int minAge;
  final int maxAge;
  final String iqama;
  final String food;
  final String accommodation;
  final String workingHours;
  final int quota;
  final String contractDuration;
  final bool isRenewable;
  final String gender;
  final List<String> documentsRequired;
  final List<String> packageIncludes;
  final String experienceRequired;
  final String processingTime;
  final DateTime? applicationDeadline;
  final DateTime? startDate;
  final DateTime? endDate;
  final int customerPercentage;
  final int agentPercentage;
  final String paymentSystem;
  final bool isBn;
  final String description;
  final List<PaymentStepProps> paymentSteps;
  final int advancePrice;
  final int afterVisa;
  final int beforeFlight;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkPermitDetails({
    required this.id,
    required this.slug,
    required this.status,
    required this.customerPrice,
    required this.agentPrice,
    required this.packagePrice,
    required this.countryName,
    required this.countryFlag,
    required this.image,
    this.agency,
    this.workType,
    required this.favoriteCount,
    required this.bookedQuota,
    required this.availableQuota,
    required this.title,
    required this.companyName,
    required this.companyAddress,
    required this.visaSponsorName,
    required this.selectionType,
    required this.visaOccupation,
    required this.salary,
    required this.currency,
    required this.currencyFlag,
    required this.minAge,
    required this.maxAge,
    required this.iqama,
    required this.food,
    required this.accommodation,
    required this.workingHours,
    required this.quota,
    required this.contractDuration,
    required this.isRenewable,
    required this.gender,
    required this.documentsRequired,
    required this.packageIncludes,
    required this.experienceRequired,
    required this.processingTime,
    this.applicationDeadline,
    this.startDate,
    this.endDate,
    required this.customerPercentage,
    required this.agentPercentage,
    required this.paymentSystem,
    required this.isBn,
    required this.description,
    required this.paymentSteps,
    required this.advancePrice,
    required this.afterVisa,
    required this.beforeFlight,
    required this.createdAt,
    this.updatedAt,
  });

  factory WorkPermitDetails.fromJson(Map<String, dynamic> json) {
    final isBn = _parseBool(json['isBn'] ?? json['is_bn']);
    final rawPaymentSteps =
        json['paymentSteps'] ??
        json['payment_steps'] ??
        json['paymentStep'] ??
        json['payment_step'];
    debugPrint('[WorkPermitDetails] Raw paymentSteps payload: $rawPaymentSteps');
    final parsedPaymentSteps = _parsePaymentSteps(rawPaymentSteps, isBn: isBn);
    final hasFallbackPaymentSteps = parsedPaymentSteps.isEmpty;

    final fallbackSteps = hasFallbackPaymentSteps
        ? <PaymentStepProps>[
            PaymentStepProps.fromFallback(
              name: 'Advance',
              amount: _parseInt(
                json['advancePrice'] ??
                    json['advance_price'] ??
                    json['advance'] ??
                    json['initialPayment'],
              ).toDouble(),
              isBn: isBn,
            ),
            PaymentStepProps.fromFallback(
              name: 'After Visa',
              amount: _parseInt(
                json['afterVisa'] ??
                    json['after_visa'] ??
                    json['afterVisaPrice'] ??
                    json['after_visa_price'],
              ).toDouble(),
              isBn: isBn,
            ),
            PaymentStepProps.fromFallback(
              name: 'Before Flight',
              amount: _parseInt(
                json['beforeFlight'] ??
                    json['before_flight'] ??
                    json['beforeFlightPrice'] ??
                    json['before_flight_price'],
              ).toDouble(),
              isBn: isBn,
            ),
          ]
        : parsedPaymentSteps;

    return WorkPermitDetails(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      customerPrice: _parseInt(
        json['customerPrice'] ?? json['customer_price'] ?? json['packagePrice'],
      ),
      agentPrice: _parseNullableInt(json['agentPrice'] ?? json['agent_price']),
      packagePrice: _parseNullableInt(
        json['packagePrice'] ?? json['package_price'],
      ),
      countryName:
          json['countryName'] ??
          json['country_name'] ??
          json['country'] ??
          'Unknown',
      countryFlag: json['countryFlag'] ?? json['country_flag'] ?? '',
      image: json['image'] ?? '',
      agency: json['agency'] != null
          ? AgencyProps.fromJson(json['agency'])
          : null,
      workType: json['workType'] != null
          ? WorkTypeProps.fromJson(json['workType'])
          : null,
      favoriteCount: _parseInt(json['favoriteCount'] ?? json['favorite_count']),
      bookedQuota: _parseInt(json['bookedQuota'] ?? json['booked_quota']),
      availableQuota: _parseInt(
        json['availableQuota'] ?? json['available_quota'],
      ),
      title: json['title'] ?? 'Unknown',
      companyName:
          json['companyName'] ?? json['company_name'] ?? 'Unknown Company',
      companyAddress: json['companyAddress'] ?? json['company_address'] ?? '',
      visaSponsorName:
          json['visaSponsorName'] ?? json['visa_sponsor_name'] ?? '',
      selectionType:
          json['selectionType'] ?? json['selection_type'] ?? 'DIRECT',
      visaOccupation: json['visaOccupation'] ?? json['visa_occupation'] ?? '',
      salary: _parseInt(json['salary']),
      currency: json['currency'] ?? 'BDT',
      currencyFlag: json['currencyFlag'] ?? json['currency_flag'] ?? '',
      minAge: _parseInt(json['minAge'] ?? json['min_age']),
      maxAge: _parseInt(json['maxAge'] ?? json['max_age']),
      iqama: _parseSelfCompany(json['iqama']),
      food: _parseSelfCompany(json['food']),
      accommodation: _parseSelfCompany(json['accommodation']),
      workingHours: json['workingHours'] ?? json['working_hours'] ?? '8',
      quota: _parseInt(json['quota']),
      contractDuration: _parseContractDuration(
        json['contractDuration'] ?? json['contract_duration'],
      ),
      isRenewable: _parseBool(json['isRenewable'] ?? json['is_renewable']),
      gender: json['gender'] ?? 'Any',
      documentsRequired: _parseStringList(
        json['documentsRequired'] ?? json['documents_required'],
      ),
      packageIncludes: _parseStringList(
        json['packageIncludes'] ?? json['package_includes'],
      ),
      experienceRequired:
          json['experienceRequired'] ??
          json['experience_required'] ??
          'Not Required',
      processingTime:
          json['processingTime'] ?? json['processing_time'] ?? 'Unknown',
      applicationDeadline:
          json['applicationDeadline'] != null ||
              json['application_deadline'] != null
          ? DateTime.tryParse(
              json['applicationDeadline'] ?? json['application_deadline'],
            )
          : null,
      startDate: json['startDate'] != null || json['start_date'] != null
          ? DateTime.tryParse(json['startDate'] ?? json['start_date'])
          : null,
      endDate: json['endDate'] != null || json['end_date'] != null
          ? DateTime.tryParse(json['endDate'] ?? json['end_date'])
          : null,
      customerPercentage: _parseInt(
        json['customerPercentage'] ?? json['customer_percentage'],
      ),
      agentPercentage: _parseInt(
        json['agentPercentage'] ?? json['agent_percentage'],
      ),
      paymentSystem: json['paymentSystem'] ?? json['payment_system'] ?? '',
      isBn: isBn,
      description: json['description'] ?? '',
      paymentSteps: fallbackSteps,
      advancePrice: _parseInt(json['advancePrice'] ?? json['advance_price']),
      afterVisa: _parseInt(json['afterVisa'] ?? json['after_visa']),
      beforeFlight: _parseInt(json['beforeFlight'] ?? json['before_flight']),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at']) ??
                DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.tryParse(json['updatedAt'] ?? json['updated_at'])
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt();
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static String _parseSelfCompany(dynamic value) {
    if (value == null) return 'Unknown';
    if (value is String) return value;
    if (value is Map) return value['name'] ?? value['value'] ?? 'Unknown';
    return value.toString();
  }

  static String _parseContractDuration(dynamic value) {
    if (value == null) return '2 Years';
    if (value is String) return value;
    if (value is Map) return value['name'] ?? value['value'] ?? '2 Years';
    return value.toString();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static List<PaymentStepProps> _parsePaymentSteps(
    dynamic value, {
    bool isBn = false,
  }) {
    if (value == null) {
      return [];
    }
    if (value is List) {
      final parsed = value
          .whereType<Map>()
          .map(
            (e) => PaymentStepProps.fromJson(
              Map<String, dynamic>.from(e),
              isBn: isBn,
            ),
          )
          .toList();
      debugPrint('[WorkPermitDetails] Parsed paymentSteps: ${parsed.map((s) => '${s.name}:${s.amount}').toList()}');
      return parsed;
    }
    if (value is Map) {
      final nested = value['results'] ?? value['items'] ?? value['data'];
      if (nested is List) {
        return _parsePaymentSteps(nested, isBn: isBn);
      }
    }
    return [];
  }
}
