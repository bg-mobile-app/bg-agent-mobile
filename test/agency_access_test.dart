import 'package:flutter_test/flutter_test.dart';
import 'package:bideshgami_merchant/common/services/agency_access.dart';

void main() {
  group('AgencyAccess - Customer Check', () {
    test('allows customer account roles', () {
      expect(AgencyAccess.isCustomerAccount({'role': 'CUSTOMER'}), isTrue);
      expect(
        AgencyAccess.isCustomerAccount({
          'user': {'role': 'CUSTOMER'},
        }),
        isTrue,
      );
    });

    test('blocks other roles from customer check', () {
      expect(AgencyAccess.isCustomerAccount({'role': 'AGENT'}), isFalse);
      expect(AgencyAccess.isCustomerAccount({'role': 'AGENCY'}), isFalse);
      expect(AgencyAccess.isCustomerAccount({'role': 'AGENCY_ADMIN'}), isFalse);
    });
  });
}
