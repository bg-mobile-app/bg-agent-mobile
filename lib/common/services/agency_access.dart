class AgencyAccess {
  AgencyAccess._();

  static const accessDeniedMessage =
      'Only agent accounts can log in to this app.';

  static const customerAccessDeniedMessage =
      'Only customer accounts can log in to this app.';

  static const Set<String> _agentRoles = {
    'AGENT',
  };

  static const Set<String> _agentStaffRoles = {
    // If agent staff exists in the future, add here
  };

  static bool isCustomerAccount(Object? authPayload) {
    final role = roleFrom(authPayload);
    if (role == null) return false;

    return _normalizeRole(role) == 'CUSTOMER';
  }

  static bool isAgencyAccount(Object? authPayload) {
    final role = roleFrom(authPayload);
    if (role == null) return false;

    return _agentRoles.contains(_normalizeRole(role));
  }

  static bool isAgencyStaffAccount(Object? authPayload) {
    final role = roleFrom(authPayload);
    if (role == null) return false;

    return _agentStaffRoles.contains(_normalizeRole(role));
  }

  static bool hasPermission(Object? authPayload, String permission) {
    final normalizedPermission = _normalizeRole(permission);
    return permissionsFrom(authPayload).contains(normalizedPermission);
  }

  static bool isRouteAllowed(String route, Object? authPayload) {
    // If not staff, allow everything
    if (!isAgencyStaffAccount(authPayload)) {
      return true;
    }

    // General routes allowed for everyone
    if (route == '/profile' ||
        route == '/dashboard/customer/profile' ||
        route == '/dashboard/customer/profile/edit' ||
        route == '/dashboard/customer/change-password' ||
        route == '/dashboard/notifications' ||
        route == '/dashboard/terms-and-conditions' ||
        route == '/logout') {
      return true;
    }

    // Dashboard overview itself - staff doesn't see general Dashboard overview
    if (route == '/dashboard/agency' || route == '/dashboard/agent' || route == '/dashboard/customer') {
      return false;
    }

    final permissions = permissionsFrom(authPayload);

    if (route.startsWith('/dashboard/ads/create') || route.startsWith('/dashboard/ads/edit/')) {
      return permissions.contains('ADS_CREATE');
    }
    if (route == '/dashboard/ads/my') {
      return permissions.contains('ADS_LIST');
    }
    if (route.startsWith('/dashboard/receive-booking/')) {
      return permissions.contains('BOOKING_LIST');
    }
    if (route.startsWith('/dashboard/passport-return/')) {
      return permissions.contains('RETURN_LIST');
    }
    if (route.startsWith('/dashboard/booking/my')) {
      return permissions.contains('OUR_BOOKING');
    }
    if (route == '/dashboard/booking/appointment') {
      return permissions.contains('APPOINTMENT_LIST');
    }
    if (route.startsWith('/dashboard/user/')) {
      return permissions.contains('USER');
    }
    if (route.startsWith('/dashboard/reminder/')) {
      return permissions.contains('REMINDER_LIST');
    }
    if (route == '/dashboard/customer/check-status') {
      return permissions.contains('CHECK_STATUS');
    }
    if (route == '/dashboard/my-payments') {
      return permissions.contains('PAYMENT_LIST');
    }
    if (route.startsWith('/dashboard/receive-payment/')) {
      return permissions.contains('RECEIVE_PAYMENT_LIST');
    }
    if (route.startsWith('/dashboard/refund-payment/')) {
      return permissions.contains('REFUND_PAYMENT');
    }

    return false;
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
