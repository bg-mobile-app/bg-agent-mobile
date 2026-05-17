class AgencyDashboardStats {
  const AgencyDashboardStats({
    required this.myBookings,
    required this.agencyBookings,
    required this.expiryReminders,
  });

  factory AgencyDashboardStats.fromJson(Map<String, dynamic> json) {
    return AgencyDashboardStats(
      myBookings: MyBookingStats.fromJson(_asMap(json['myBookings'])),
      agencyBookings: AgencyBookingStats.fromJson(_asMap(json['agencyBookings'])),
      expiryReminders: ExpiryReminderStats.fromJson(_asMap(json['expiryReminders'])),
    );
  }

  factory AgencyDashboardStats.empty() {
    return AgencyDashboardStats(
      myBookings: MyBookingStats.empty(),
      agencyBookings: AgencyBookingStats.empty(),
      expiryReminders: ExpiryReminderStats.empty(),
    );
  }

  final MyBookingStats myBookings;
  final AgencyBookingStats agencyBookings;
  final ExpiryReminderStats expiryReminders;
}

class MyBookingStats {
  const MyBookingStats({
    required this.total,
    required this.successFlight,
    required this.rejectFlight,
    required this.processing,
    required this.returnProcessing,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.commissionAmount,
  });

  factory MyBookingStats.fromJson(Map<String, dynamic> json) {
    return MyBookingStats(
      total: _asInt(json['total']),
      successFlight: _asInt(json['successFlight']),
      rejectFlight: _asInt(json['rejectFlight']),
      processing: _asInt(json['processing']),
      returnProcessing: _asInt(json['returnProcessing']),
      totalAmount: _asInt(json['totalAmount']),
      paidAmount: _asInt(json['paidAmount']),
      dueAmount: _asInt(json['dueAmount']),
      commissionAmount: _asInt(json['commissionAmount']),
    );
  }

  factory MyBookingStats.empty() => const MyBookingStats(
        total: 0,
        successFlight: 0,
        rejectFlight: 0,
        processing: 0,
        returnProcessing: 0,
        totalAmount: 0,
        paidAmount: 0,
        dueAmount: 0,
        commissionAmount: 0,
      );

  final int total;
  final int successFlight;
  final int rejectFlight;
  final int processing;
  final int returnProcessing;
  final int totalAmount;
  final int paidAmount;
  final int dueAmount;
  final int commissionAmount;
}

class AgencyBookingStats {
  const AgencyBookingStats({
    required this.total,
    required this.appliedCustomer,
    required this.bgCollectPp,
    required this.bgSentPp,
    required this.aRecievePp,
    required this.underProcessing,
    required this.visaApproved,
    required this.bmetDone,
    required this.ticketDone,
    required this.ppSentToBg,
    required this.bgReceivedPp,
    required this.readyForFlight,
    required this.successFlight,
    required this.returnRequest,
    required this.returnAccepted,
    required this.returnPpSentToBg,
    required this.bgCollectReturnPp,
    required this.bgHandoverPpToCustomer,
    required this.rejectFlight,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.commissionAmount,
  });

  factory AgencyBookingStats.fromJson(Map<String, dynamic> json) {
    return AgencyBookingStats(
      total: _asInt(json['total']),
      appliedCustomer: _asInt(json['appliedCustomer']),
      bgCollectPp: _asInt(json['bgCollectPp']),
      bgSentPp: _asInt(json['bgSentPp']),
      aRecievePp: _asInt(json['aRecievePp']),
      underProcessing: _asInt(json['underProcessing']),
      visaApproved: _asInt(json['visaApproved']),
      bmetDone: _asInt(json['bmetDone']),
      ticketDone: _asInt(json['ticketDone']),
      ppSentToBg: _asInt(json['ppSentToBg']),
      bgReceivedPp: _asInt(json['bgReceivedPp']),
      readyForFlight: _asInt(json['readyForFlight']),
      successFlight: _asInt(json['successFlight']),
      returnRequest: _asInt(json['returnRequest']),
      returnAccepted: _asInt(json['returnAccepted']),
      returnPpSentToBg: _asInt(json['returnPpSentToBg']),
      bgCollectReturnPp: _asInt(json['bgCollectReturnPp']),
      bgHandoverPpToCustomer: _asInt(json['bgHandoverPpToCustomer']),
      rejectFlight: _asInt(json['rejectFlight']),
      totalAmount: _asInt(json['totalAmount']),
      paidAmount: _asInt(json['paidAmount']),
      dueAmount: _asInt(json['dueAmount']),
      commissionAmount: _asInt(json['commissionAmount']),
    );
  }

  factory AgencyBookingStats.empty() => const AgencyBookingStats(
        total: 0,
        appliedCustomer: 0,
        bgCollectPp: 0,
        bgSentPp: 0,
        aRecievePp: 0,
        underProcessing: 0,
        visaApproved: 0,
        bmetDone: 0,
        ticketDone: 0,
        ppSentToBg: 0,
        bgReceivedPp: 0,
        readyForFlight: 0,
        successFlight: 0,
        returnRequest: 0,
        returnAccepted: 0,
        returnPpSentToBg: 0,
        bgCollectReturnPp: 0,
        bgHandoverPpToCustomer: 0,
        rejectFlight: 0,
        totalAmount: 0,
        paidAmount: 0,
        dueAmount: 0,
        commissionAmount: 0,
      );

  final int total;
  final int appliedCustomer;
  final int bgCollectPp;
  final int bgSentPp;
  final int aRecievePp;
  final int underProcessing;
  final int visaApproved;
  final int bmetDone;
  final int ticketDone;
  final int ppSentToBg;
  final int bgReceivedPp;
  final int readyForFlight;
  final int successFlight;
  final int returnRequest;
  final int returnAccepted;
  final int returnPpSentToBg;
  final int bgCollectReturnPp;
  final int bgHandoverPpToCustomer;
  final int rejectFlight;
  final int totalAmount;
  final int paidAmount;
  final int dueAmount;
  final int commissionAmount;
}

class ExpiryReminderStats {
  const ExpiryReminderStats({required this.days3, required this.days10});

  factory ExpiryReminderStats.fromJson(Map<String, dynamic> json) {
    return ExpiryReminderStats(
      days3: ExpiryReminderGroup.fromJson(_asMap(json['days3'])),
      days10: ExpiryReminderGroup.fromJson(_asMap(json['days10'])),
    );
  }

  factory ExpiryReminderStats.empty() {
    return ExpiryReminderStats(
      days3: ExpiryReminderGroup.empty(),
      days10: ExpiryReminderGroup.empty(),
    );
  }

  final ExpiryReminderGroup days3;
  final ExpiryReminderGroup days10;
}

class ExpiryReminderGroup {
  const ExpiryReminderGroup({
    required this.medical,
    required this.police,
    required this.visa,
    required this.total,
  });

  factory ExpiryReminderGroup.fromJson(Map<String, dynamic> json) {
    return ExpiryReminderGroup(
      medical: _asInt(json['medical']),
      police: _asInt(json['police']),
      visa: _asInt(json['visa']),
      total: _asInt(json['total']),
    );
  }

  factory ExpiryReminderGroup.empty() => const ExpiryReminderGroup(
        medical: 0,
        police: 0,
        visa: 0,
        total: 0,
      );

  final int medical;
  final int police;
  final int visa;
  final int total;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.replaceAll(',', '')) ?? 0;
  return 0;
}
