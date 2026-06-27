import 'package:flutter_test/flutter_test.dart';
import 'package:bideshgami_merchant/features/search/models/work_permit_details.dart';

void main() {
  group('WorkPermitDetails payment parsing', () {
    test('builds fallback payment steps from API price fields when paymentSteps is empty', () {
      final details = WorkPermitDetails.fromJson({
        'isBn': true,
        'paymentSteps': [],
        'advancePrice': 67500,
        'afterVisa': 150000,
        'beforeFlight': 150000,
      });

      expect(details.paymentSteps, hasLength(3));
      expect(details.paymentSteps[0].name, 'অগ্রিম');
      expect(details.paymentSteps[1].name, 'ভিসার পর');
      expect(details.paymentSteps[2].name, 'ফ্লাইটের আগে');
      expect(details.paymentSteps[0].amount, 67500);
      expect(details.paymentSteps[1].amount, 150000);
      expect(details.paymentSteps[2].amount, 150000);
    });
  });
}
