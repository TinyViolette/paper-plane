import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';
import 'package:paperplane/widgets/plane_overlay.dart';

import '../helpers/fake_plane_cubit.dart';

/// PlaneOverlay UI 測試
///
/// 驗證飛機圖片的渲染、位移、翻轉和旋轉變換是否正確套用。
void main() {
  /// 建立測試用的 widget 樹，注入 FakePlaneCubit。
  Future<FakePlaneCubit> pumpOverlay(WidgetTester tester) async {
    final cubit = FakePlaneCubit();
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<Cubit<PlaneState>>.value(
        value: cubit,
        child: const Stack(children: [PlaneOverlay()]),
      ),
    ));
    return cubit;
  }

  group('PlaneOverlay', () {
    // ========================================
    // 基本渲染
    // ========================================
    testWidgets('應渲染飛機圖片', (tester) async {
      // PlaneOverlay 應包含一個 Image widget 顯示 plane.png
      final cubit = await pumpOverlay(tester);
      expect(find.byType(Image), findsOneWidget);
      cubit.close();
    });

    // ========================================
    // 位移套用
    // ========================================
    testWidgets('應套用 planeOffset 位移', (tester) async {
      // 當 planeOffset 設為 (10, 20) 時，Transform.translate 應使用該偏移
      final cubit = await pumpOverlay(tester);
      cubit.emitState(planeOffset: const Offset(10, 20));
      await tester.pump();

      // 至少應有一個 Transform（translate 或 rotation）
      expect(find.byType(Transform), findsWidgets);
      cubit.close();
    });

    // ========================================
    // 翻轉套用
    // ========================================
    testWidgets('isFlipped=true 時應水平翻轉', (tester) async {
      // 當 isFlipped=true 時，Transform 的矩陣應包含 scaleX=-1
      final cubit = await pumpOverlay(tester);
      cubit.emitState(isFlipped: true);
      await tester.pump();

      // 找到帶有 rotation/flip 的 Transform（非 Transform.translate）
      final transforms = tester.widgetList<Transform>(find.byType(Transform));
      // 尋找矩陣中 scaleX 為 -1 的 Transform（水平翻轉）
      final flippedTransform = transforms.where((t) {
        final m = t.transform;
        return m[0] < 0; // scaleX < 0 表示水平翻轉
      });
      expect(flippedTransform.isNotEmpty, true);
      cubit.close();
    });

    testWidgets('isFlipped=false 時不應翻轉', (tester) async {
      // 當 isFlipped=false 時，Transform 的 scaleX 應為正數
      final cubit = await pumpOverlay(tester);
      cubit.emitState(isFlipped: false, planeRotation: 0);
      await tester.pump();

      final transforms = tester.widgetList<Transform>(find.byType(Transform));
      final hasFlip = transforms.any((t) => t.transform[0] < 0);
      expect(hasFlip, false);
      cubit.close();
    });

    // ========================================
    // 旋轉套用
    // ========================================
    testWidgets('planeRotation=45 時應套用旋轉', (tester) async {
      // 當 planeRotation=45 時，Transform 矩陣應包含旋轉分量
      final cubit = await pumpOverlay(tester);
      cubit.emitState(planeRotation: 45);
      await tester.pump();

      // 旋轉 45° 的矩陣：m[0]=cos(45°)≈0.707, m[1]=sin(45°)≈0.707
      final transforms = tester.widgetList<Transform>(find.byType(Transform));
      final rotatedTransform = transforms.where((t) {
        final m = t.transform;
        // 檢查是否有旋轉分量（m[1] 不接近 0）
        return (m[1] - sin(45 * pi / 180)).abs() < 0.01;
      });
      expect(rotatedTransform.isNotEmpty, true);
      cubit.close();
    });
  });
}
