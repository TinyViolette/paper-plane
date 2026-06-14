import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/main.dart';

void main() {
  testWidgets('App loads map page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
