import 'package:flutter_test/flutter_test.dart';
import 'package:bideshgami_merchant/app.dart';

void main() {
  testWidgets('App home renders expected content', (WidgetTester tester) async {
    await tester.pumpWidget(const BideshgamiApp());

    expect(find.text('Bideshgami'), findsWidgets);
  });
}
