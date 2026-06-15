import 'package:flutter_test/flutter_test.dart';

import 'package:bg_demo_mobile/common/services/agency_access.dart';

void main() {
  group('AgencyAccess', () {
    test('allows agency account roles', () {
      expect(AgencyAccess.isAgencyAccount({'role': 'AGENCY'}), isTrue);
      expect(AgencyAccess.isAgencyAccount({'role': 'AGENCY_ADMIN'}), isTrue);
      expect(
        AgencyAccess.isAgencyAccount({
          'user': {'role': 'RECRUITING_AGENCY'},
        }),
        isTrue,
      );
    });

    test('allows agency staff to sign in and reads permissions', () {
      final staffPayload = {
        'status': 'VERIFIED',
        'role': 'AGENCY_STAFF',
        'email': 'staff.member@example.com',
        'userCode': 'AS-12345',
        'phone': '123-456-7890',
        'image': '/path/to/profile/image.png',
        'permissions': ['BOOKING_LIST', 'BOOKING_DETAILS', 'MY_PAYMENT'],
      };

      expect(AgencyAccess.isAgencyAccount(staffPayload), isTrue);
      expect(AgencyAccess.isAgencyStaffAccount(staffPayload), isTrue);
      expect(AgencyAccess.hasPermission(staffPayload, 'BOOKING_LIST'), isTrue);
      expect(
        AgencyAccess.hasPermission(staffPayload, 'booking-details'),
        isTrue,
      );
      expect(AgencyAccess.hasPermission(staffPayload, 'MANAGE_USER'), isFalse);
    });

    test('blocks customer and agent roles', () {
      expect(AgencyAccess.isAgencyAccount({'role': 'CUSTOMER'}), isFalse);
      expect(AgencyAccess.isAgencyAccount({'role': 'AGENT'}), isFalse);
      expect(
        AgencyAccess.isAgencyAccount({
          'user': {'role': 'AGENT'},
        }),
        isFalse,
      );
    });

    test('blocks missing or unknown roles', () {
      expect(AgencyAccess.isAgencyAccount({'username': 'agency'}), isFalse);
      expect(AgencyAccess.isAgencyAccount({'role': 'STAFF'}), isFalse);
    });
  });
}
