import 'dart:ui';

/// 計算飛機的旋轉角度和翻轉狀態。
///
/// 根據搖桿的螢幕座標偏移，計算飛機應有的旋轉角度和是否水平翻轉。
///
/// - [joystickOffset]：搖桿的歸一化偏移（-1~1），螢座標（y 向下為正）
/// - [currentFlipped]：當前的翻轉狀態，用於在門檻內保留上次方向
/// - [pitchUp]：搖桿拉到最上時的旋轉角度（單位：度，Flutter 正值=順時針）
/// - [pitchDown]：搖桿推到最下時的旋轉角度（單位：度）
/// - [deadZone]：搖桿中心死區半徑，避免微小偏移觸發旋轉
/// - [flipThreshold]：水平翻轉門檻（|dx|），避免微小偏移觸發翻轉
///
/// 回傳 record：`(旋轉角度, 是否水平翻轉)`
(double, bool) computePlaneRotation({
  required Offset joystickOffset,
  required bool currentFlipped,
  required double pitchUp,
  required double pitchDown,
  required double deadZone,
  required double flipThreshold,
}) {
  // 搖桿在死區內（手指剛觸碰或微小抖動），不旋轉、不翻轉
  if (joystickOffset.distance < deadZone) {
    return (0, false);
  }

  // 將螢幕 y 軸翻轉為數學座標（y 向上為正）
  final dy = -joystickOffset.dy;

  // 線性插值：dy=-1（最上）→ pitchUp，dy=+1（最下）→ pitchDown
  final t = (dy + 1) / 2;
  final rotation = pitchDown + (pitchUp - pitchDown) * t;

  // 水平翻轉：只有搖桿水平偏移超過門檻時才更新，否則保留上次狀態
  final shouldFlip = joystickOffset.dx.abs() >= flipThreshold
      ? joystickOffset.dx < 0
      : currentFlipped;

  return (rotation, shouldFlip);
}

/// 將偏移向量夾制到指定半徑內。
///
/// 若 [offset] 的長度不超過 [radius]，回傳原值；否則等比縮放到半徑邊界。
Offset clampToRadius(Offset offset, double radius) {
  if (offset.distance <= radius) return offset;
  return offset * (radius / offset.distance);
}
