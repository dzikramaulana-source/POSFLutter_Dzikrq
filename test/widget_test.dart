import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_sop/main.dart';

void main() {
  testWidgets('App membuka layar login', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PosApp());
    await tester.pumpAndSettle();

    // Layar login menampilkan judul dan field username/password
    expect(find.text('POS Kasir'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
