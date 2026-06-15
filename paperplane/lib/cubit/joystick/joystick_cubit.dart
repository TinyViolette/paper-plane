import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/cubit/joystick/joystick_state.dart';

/// 搖桿狀態管理 Cubit。
///
/// 只負責狀態邏輯（位置追蹤、狀態轉換），不持有 AnimationController。
/// 動畫執行由 [JoystickOverlay] widget 負責。
class JoystickCubit extends Cubit<JoystickState> {
  double _x = 0;
  double _y = 0;

  /// 動畫目標位置，由 widget 讀取後驅動動畫。
  Offset _targetOffset = Offset.zero;
  Offset get targetOffset => _targetOffset;

  double get currentX => _x;
  double get currentY => _y;

  JoystickCubit() : super(const JoystickIdle(Offset.zero));

  /// 拖曳更新：直接設定位置，emit [JoystickDragging]。
  void updateDrag(Offset normalizedOffset) {
    _x = normalizedOffset.dx.clamp(-1.0, 1.0);
    _y = normalizedOffset.dy.clamp(-1.0, 1.0);
    emit(JoystickDragging(Offset(_x, _y)));
  }

  /// 結束拖曳：觸發回中動畫。
  /// emit [JoystickAnimating]，widget 偵測後啟動動畫回到 [_targetOffset]。
  void endDrag() {
    _targetOffset = Offset.zero;
    emit(JoystickAnimating(Offset(_x, _y)));
  }

  /// 外部觸發回中（例如地圖事件）。
  void returnToCenter() {
    _targetOffset = Offset.zero;
    emit(JoystickAnimating(Offset(_x, _y)));
  }

  /// 按鈕觸發向上移動。
  void moveUp() {
    _targetOffset = Offset(_x, -1.0);
    emit(JoystickAnimating(Offset(_x, _y)));
  }

  /// 按鈕觸發向下移動。
  void moveDown() {
    _targetOffset = Offset(_x, 1.0);
    emit(JoystickAnimating(Offset(_x, _y)));
  }

  /// 由 widget 動畫驅動的位置更新（每幀呼叫）。
  void animateToPosition(double x, double y) {
    _x = x;
    _y = y;
    emit(JoystickAnimating(Offset(_x, _y)));
  }

  /// 由 widget 在動畫完成時呼叫，轉換為 Idle 狀態。
  void emitIdle() {
    _x = _targetOffset.dx;
    _y = _targetOffset.dy;
    emit(JoystickIdle(Offset(_x, _y)));
  }
}
