import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

/// 測試用的 PlaneCubit 替代品。
///
/// 直接 emit 指定的 PlaneState，不依賴 MapController / JoystickCubit / Timer。
/// 用於 widget 測試中隔離 PlaneOverlay / ZoomControls / JoystickOverlay 的依賴。
class FakePlaneCubit extends Cubit<PlaneState> {
  FakePlaneCubit()
      : super(
          PlaneState(
            planeOffset: Offset.zero,
            floatAmplitude: 0,
            floatHalfPeriod: Duration.zero,
          ),
        );

  /// 發出新的 PlaneState，僅更新指定欄位，其餘保留當前值。
  void emitState({
    Offset? planeOffset,
    bool? isFlipped,
    double? planeRotation,
    bool? isLanded,
  }) {
    emit(PlaneState(
      planeOffset: planeOffset ?? state.planeOffset,
      floatAmplitude: state.floatAmplitude,
      floatHalfPeriod: state.floatHalfPeriod,
      isLanded: isLanded ?? state.isLanded,
      planeRotation: planeRotation ?? state.planeRotation,
      isFlipped: isFlipped ?? state.isFlipped,
    ));
  }
}
