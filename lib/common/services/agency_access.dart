class AgencyAccess {
  AgencyAccess._();

  static const accessDeniedMessage =
      'Only agency accounts can log in to this app.';

  static bool isAgencyAccount(Object? authPayload) {
    final role = roleFrom(authPayload);
    if (role == null) return false;

    final normalizedRole = _normalizeRole(role);
    return normalizedRole == 'AGENCY' ||
        normalizedRole == 'AGENCY_ADMIN' ||
        normalizedRole == 'AGENCY_OWNER' ||
        normalizedRole == 'AGENCY_STAFF' ||
        normalizedRole == 'RECRUITING_AGENCY' ||
        normalizedRole == 'RECRUITING_AGENCY_ADMIN' ||
        normalizedRole == 'RECRUITING_AGENCY_OWNER' ||
        normalizedRole == 'RECRUITING_AGENCY_STAFF';
  }

  static String? roleFrom(Object? authPayload) {
    if (authPayload is! Map) return null;

    for (final key in const [
      'role',
      'userRole',
      'user_role',
      'accountType',
      'account_type',
      'type',
    ]) {
      final value = authPayload[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }

    for (final key in const ['user', 'data', 'profile', 'account']) {
      final role = roleFrom(authPayload[key]);
      if (role != null) return role;
    }

    return null;
  }

  static String _normalizeRole(String role) {
    return role.trim().toUpperCase().replaceAll(RegExp(r'[\s-]+'), '_');
  }
}
