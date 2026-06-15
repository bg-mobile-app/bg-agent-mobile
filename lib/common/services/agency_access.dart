class AgencyAccess {
  AgencyAccess._();

  static const accessDeniedMessage =
      'Only agency or agency staff accounts can log in to this app.';

  static const Set<String> _agencyRoles = {
    'AGENCY',
    'AGENCY_ADMIN',
    'AGENCY_OWNER',
    'AGENCY_STAFF',
    'RECRUITING_AGENCY',
    'RECRUITING_AGENCY_ADMIN',
    'RECRUITING_AGENCY_OWNER',
    'RECRUITING_AGENCY_STAFF',
  };

  static const Set<String> _agencyStaffRoles = {
    'AGENCY_STAFF',
    'RECRUITING_AGENCY_STAFF',
  };

  static bool isAgencyAccount(Object? authPayload) {
    final role = roleFrom(authPayload);
    if (role == null) return false;

    return _agencyRoles.contains(_normalizeRole(role));
  }

  static bool isAgencyStaffAccount(Object? authPayload) {
    final role = roleFrom(authPayload);
    if (role == null) return false;

    return _agencyStaffRoles.contains(_normalizeRole(role));
  }

  static bool hasPermission(Object? authPayload, String permission) {
    final normalizedPermission = _normalizeRole(permission);
    return permissionsFrom(authPayload).contains(normalizedPermission);
  }

  static Set<String> permissionsFrom(Object? authPayload) {
    if (authPayload is! Map) return const {};

    final permissions = authPayload['permissions'];
    if (permissions is List) {
      return permissions
          .whereType<String>()
          .map(_normalizeRole)
          .where((permission) => permission.isNotEmpty)
          .toSet();
    }

    for (final key in const ['user', 'data', 'profile', 'account']) {
      final nestedPermissions = permissionsFrom(authPayload[key]);
      if (nestedPermissions.isNotEmpty) return nestedPermissions;
    }

    return const {};
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
