import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperplane/cubit/joystick/joystick_cubit.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';
import 'package:paperplane/widgets/joystick_overlay.dart';

import '../helpers/fake_plane_cubit.dart';

/// JoystickOverlay UI 測試
///
/// 驗證搖桿的渲染和 landed 狀態下的視覺行為。
/// 由於 JoystickOverlay 使用 TickerProviderStateMixin 並呼叫 attachTicker，
/// 拖曳手勢的測試成本較高，此處僅驗證基本渲染和停用狀態。
void main() {
  group('JoystickOverlay', () {
    // ========================================
    // 基本渲染
    // ========================================
    testWidgets('應渲染 CustomPaint 搖桿', (tester) async {
      // JoystickOverlay 應包含 CustomPaint widget 繪製搖桿
      final joystickCubit = JoystickCubit();
      final planeCubit = FakePlaneCubit();

      await tester.pumpWidget(MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<JoystickCubit>.value(value: joystickCubit),
            BlocProvider<Cubit<PlaneState>>.value(value: planeCubit),
          ],
          child: const Stack(children: [JoystickOverlay()]),
        ),
      ));

      expect(find.byType(CustomPaint), findsWidgets);
      joystickCubit.close();
      planeCubit.close();
    });

    // ========================================
    // landed 狀態
    // ========================================
    testWidgets('landed 時搖桿透明度應降低', (tester) async {
      // 當飛機已降落（isLanded=true），搖桿的 Opacity 應降至 0.05
      final joystickCubit = JoystickCubit();
      final planeCubit = FakePlaneCubit();
      planeCubit.emitState(isLanded: true);

      await tester.pumpWidget(MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<JoystickCubit>.value(value: joystickCubit),
            BlocProvider<Cubit<PlaneState>>.value(value: planeCubit),
          ],
          child: const Stack(children: [JoystickOverlay()]),
        ),
      ));

      // 找到 Opacity widget 並驗證透明度接近 0.05
      final opacities = tester.widgetList<Opacity>(find.byType(Opacity));
      final hasLowOpacity =
          opacities.any((o) => (o.opacity - 0.05).abs() < 0.01);
      expect(hasLowOpacity, true);
      joystickCubit.close();
      planeCubit.close();
    });
  });
}
