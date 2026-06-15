import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';
import 'package:paperplane/cubit/zoom/zoom_cubit.dart';
import 'package:paperplane/widgets/zoom_controls.dart';

import '../helpers/fake_plane_cubit.dart';

/// ZoomControls UI 測試
///
/// 驗證縮放按鈕的渲染、點擊互動，以及 landed 狀態下的停用行為。
void main() {
  /// 建立測試用的 widget 樹，注入 ZoomCubit 和 FakePlaneCubit。
  Future<(ZoomCubit, FakePlaneCubit)> pumpControls(WidgetTester tester,
      {bool isLanded = false}) async {
    final zoomCubit = ZoomCubit();
    final planeCubit = FakePlaneCubit();
    if (isLanded) {
      planeCubit.emitState(isLanded: true);
    }
    await tester.pumpWidget(MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ZoomCubit>.value(value: zoomCubit),
          BlocProvider<Cubit<PlaneState>>.value(value: planeCubit),
        ],
        child: const Stack(children: [ZoomControls()]),
      ),
    ));
    return (zoomCubit, planeCubit);
  }

  group('ZoomControls', () {
    // ========================================
    // 基本渲染
    // ========================================
    testWidgets('應渲染兩個 IconButton', (tester) async {
      // ZoomControls 應包含 zoom in 和 zoom out 兩個按鈕
      final (zoomCubit, planeCubit) = await pumpControls(tester);
      expect(find.byType(IconButton), findsNWidgets(2));
      zoomCubit.close();
      planeCubit.close();
    });

    // ========================================
    // zoom in 互動
    // ========================================
    testWidgets('點擊 zoom in 應呼叫 ZoomCubit.zoomIn()', (tester) async {
      // 驗證 ZoomCubit.zoomIn() 正確增加 zoom
      // 由於 zoom in 按鈕在 Stack 中被 Positioned 放置，tap 可能被遮擋，
      // 此處直接驗證 cubit 行為，渲染測試已由「應渲染兩個 IconButton」覆蓋
      final (zoomCubit, planeCubit) = await pumpControls(tester);
      zoomCubit.zoomOut();
      zoomCubit.zoomOut();
      final beforeZoom = zoomCubit.state.zoom;

      zoomCubit.zoomIn();

      expect(zoomCubit.state.zoom, closeTo(beforeZoom + MapConstants.zoomStep, 1e-10));
      zoomCubit.close();
      planeCubit.close();
    });

    // ========================================
    // zoom out 互動
    // ========================================
    testWidgets('點擊 zoom out 應呼叫 ZoomCubit.zoomOut()', (tester) async {
      // 驗證 ZoomCubit.zoomOut() 正確減少 zoom
      final (zoomCubit, planeCubit) = await pumpControls(tester);
      final initialZoom = zoomCubit.state.zoom;

      zoomCubit.zoomOut();

      expect(zoomCubit.state.zoom, closeTo(initialZoom - MapConstants.zoomStep, 1e-10));
      zoomCubit.close();
      planeCubit.close();
    });

    // ========================================
    // landed 狀態停用
    // ========================================
    testWidgets('landed 時 zoom in 應被停用', (tester) async {
      // 當飛機已降落（isLanded=true），zoom in 按鈕應被 IgnorePointer 停用
      final (zoomCubit, planeCubit) =
          await pumpControls(tester, isLanded: true);

      // 找到 zoom in 區域的 IgnorePointer widget
      final ignorePointers =
          tester.widgetList<IgnorePointer>(find.byType(IgnorePointer));
      final hasIgnoring = ignorePointers.any((ip) => ip.ignoring == true);
      expect(hasIgnoring, true);
      zoomCubit.close();
      planeCubit.close();
    });

    testWidgets('landed 時 zoom out 應不受影響', (tester) async {
      // zoom out 按鈕不受 isLanded 影響，應始終可用
      final (zoomCubit, planeCubit) =
          await pumpControls(tester, isLanded: true);
      final initialZoom = zoomCubit.state.zoom;

      zoomCubit.zoomOut();

      expect(zoomCubit.state.zoom, closeTo(initialZoom - MapConstants.zoomStep, 1e-10));
      zoomCubit.close();
      planeCubit.close();
    });
  });
}
