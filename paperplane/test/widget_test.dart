import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/main.dart';

void main() {
  testWidgets('App loads map page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(FlutterMap), findsOneWidget);

    // 卸載 widget tree 讓 cubits 的 close() 被呼叫，清理 Timer 和 AnimationController
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
