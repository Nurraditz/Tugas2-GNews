import 'package:flutter_test/flutter_test.dart';

import 'package:tugas2_gnews/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Berita Perfilman'), findsOneWidget);
  });
}
