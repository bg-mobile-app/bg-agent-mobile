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
