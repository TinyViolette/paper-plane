import 'package:flutter_test/flutter_test.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/utils/rotation_utils.dart';

/// 旋轉邏輯純函數單元測試
///
/// 測試從 PlaneCubit 抽取出來的純函數：
/// - computePlaneRotation：根據搖桿偏移計算飛機旋轉角度和翻轉狀態
/// - clampToRadius：將偏移向量夾制到指定半徑內
///
/// 這些測試同時具有回歸測試的性質，保護核心行為不被意外改壞。
void main() {
  // 使用 MapConstants 中的常數作為測試參數，確保與實際運行一致
  const pitchUp = MapConstants.planePitchUp;
  const pitchDown = MapConstants.planePitchDown;
  const deadZone = MapConstants.planeRotationDeadZone;
  const flipThreshold = MapConstants.planeFlipThreshold;

  group('computePlaneRotation', () {
    // ========================================
    // 死區測試
    // ========================================
    group('死區行為', () {
      test('搖桿在正中心（0,0）應回傳 (0, false)', () {
        // 搖桿完全未移動時，不應有任何旋轉或翻轉
        final (rotation, flipped) = computePlaneRotation(
          joystickOffset: Offset.zero,
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(rotation, 0);
        expect(flipped, false);
      });

      test('搖桿在死區內（微小偏移）應回傳 (0, false)', () {
        // 手指剛觸碰搖桿時的微小偏移不應觸發旋轉
        final (rotation, flipped) = computePlaneRotation(
          joystickOffset: const Offset(0.01, 0.01),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(rotation, 0);
        expect(flipped, false);
      });

      test('搖桿在死區邊界（剛好在內）應回傳 (0, false)', () {
        // 偏移量剛好小於死區半徑，應仍被視為死區內
        final justInside = deadZone * 0.9;
        final (rotation, flipped) = computePlaneRotation(
          joystickOffset: Offset(justInside, 0),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(rotation, 0);
        expect(flipped, false);
      });

      test('搖桿在死區邊界（剛好在外）應有旋轉', () {
        // 偏移量剛好大於死區半徑，應開始計算旋轉
        final justOutside = deadZone * 1.1;
        final (rotation, _) = computePlaneRotation(
          joystickOffset: Offset(0, justOutside),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        // 有微小偏移應產生非零旋轉
        expect(rotation, isNot(0));
      });
    });

    // ========================================
    // 旋轉角度測試
    // ========================================
    group('旋轉角度對應', () {
      test('搖桿拉到最上（dy=-1）應回傳 pitchUp', () {
        // 搖桿完全往上推時，應達到 pitchUp 角度
        final (rotation, _) = computePlaneRotation(
          joystickOffset: const Offset(0, -1),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(rotation, closeTo(pitchUp, 0.01));
      });

      test('搖桿推到最下（dy=+1）應回傳 pitchDown', () {
        // 搖桿完全往下推時，應達到 pitchDown 角度
        final (rotation, _) = computePlaneRotation(
          joystickOffset: const Offset(0, 1),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(rotation, closeTo(pitchDown, 0.01));
      });

      test('搖桿在垂直中間（dy=0）應為 pitchUp 和 pitchDown 的平均值', () {
        // 搖桿在垂直中心時，旋轉角度應為仰角和俯角的中間值
        // 使用較大的偏移避免死區影響，dy=0.5 → t = (-0.5+1)/2 = 0.25
        final (rotation, _) = computePlaneRotation(
          joystickOffset: const Offset(0, 0.5),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        final expected = pitchDown + (pitchUp - pitchDown) * 0.25;
        expect(rotation, closeTo(expected, 0.01));
      });

      test('搖桿在 1/4 處應線性插值', () {
        // dy = -0.5 時，t = (-(-0.5) + 1) / 2 = 0.75
        // rotation = pitchDown + (pitchUp - pitchDown) * 0.75
        final (rotation, _) = computePlaneRotation(
          joystickOffset: const Offset(0, -0.5),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        final expected = pitchDown + (pitchUp - pitchDown) * 0.75;
        expect(rotation, closeTo(expected, 0.01));
      });

      test('搖桿在垂直中間（dy=0）應為 pitchUp 和 pitchDown 的內插值', () {
        // 搖桿在垂直中心時，t = 0.5 → rotation = (pitchUp + pitchDown) / 2
        // 使用較大的偏移避免死區影響，dy=0.5 → t = (-0.5+1)/2 = 0.25
        final (rotation, _) = computePlaneRotation(
          joystickOffset: const Offset(0, 0.5),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        final expected = pitchDown + (pitchUp - pitchDown) * 0.25;
        expect(rotation, closeTo(expected, 0.01));
      });
    });

    // ========================================
    // 水平翻轉測試
    // ========================================
    group('水平翻轉行為', () {
      test('搖桿往右超過門檻應不翻轉', () {
        // 搖桿明確往右推時，飛機應保持朝右（不翻轉）
        final (_, flipped) = computePlaneRotation(
          joystickOffset: const Offset(0.5, 0),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(flipped, false);
      });

      test('搖桿往左超過門檻應翻轉', () {
        // 搖桿明確往左推時，飛機應翻轉為朝左
        final (_, flipped) = computePlaneRotation(
          joystickOffset: const Offset(-0.5, 0),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(flipped, true);
      });

      test('搖桿水平偏移在門檻內應保留當前翻轉狀態（不翻轉）', () {
        // 微小水平偏移不應改變翻轉方向
        // 模擬飛機原本朝右，搖桿微偏左但仍低於門檻
        final (_, flipped) = computePlaneRotation(
          joystickOffset: const Offset(-0.1, 0.5),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        // 門檻內應保留 currentFlipped（false = 朝右）
        expect(flipped, false);
      });

      test('搖桿水平偏移在門檻內應保留當前翻轉狀態（翻轉）', () {
        // 模擬飛機原本朝左，搖桿微偏右但仍低於門檻
        final (_, flipped) = computePlaneRotation(
          joystickOffset: const Offset(0.1, 0.5),
          currentFlipped: true,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        // 門檻內應保留 currentFlipped（true = 朝左）
        expect(flipped, true);
      });

      test('搖桿從左往右穿越門檻應切換翻轉狀態', () {
        // 模擬搖桿從左側移動到右側，穿越門檻時翻轉應切換
        // 第一步：左側超過門檻 → 翻轉
        final (_, flipped1) = computePlaneRotation(
          joystickOffset: const Offset(-0.5, 0),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(flipped1, true);

        // 第二步：回到門檻內 → 保留翻轉
        final (_, flipped2) = computePlaneRotation(
          joystickOffset: const Offset(-0.1, 0),
          currentFlipped: true,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(flipped2, true);

        // 第三步：右側超過門檻 → 取消翻轉
        final (_, flipped3) = computePlaneRotation(
          joystickOffset: const Offset(0.5, 0),
          currentFlipped: true,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(flipped3, false);
      });
    });

    // ========================================
    // 綜合情境測試（回歸測試）
    // ========================================
    group('回歸：實際搖桿操作情境', () {
      test('右上推（dx>0, dy<0）：不翻轉、朝 pitchUp 方向', () {
        // 搖桿往右上方推，飛機應朝 pitchUp 方向旋轉
        final (rotation, flipped) = computePlaneRotation(
          joystickOffset: const Offset(0.8, -0.8),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(flipped, false);
        // dy=-0.8 → t = (0.8+1)/2 = 0.9 → 接近 pitchUp
        expect(rotation, closeTo(pitchDown + (pitchUp - pitchDown) * 0.9, 0.01));
      });

      test('左下推（dx<0, dy>0）：翻轉、朝 pitchDown 方向', () {
        // 搖桿往左下方推，飛機應翻轉朝 pitchDown 方向旋轉
        final (rotation, flipped) = computePlaneRotation(
          joystickOffset: const Offset(-0.8, 0.8),
          currentFlipped: false,
          pitchUp: pitchUp,
          pitchDown: pitchDown,
          deadZone: deadZone,
          flipThreshold: flipThreshold,
        );
        expect(flipped, true);
        // dy=0.8 → t = (-0.8+1)/2 = 0.1 → 接近 pitchDown
        expect(rotation, closeTo(pitchDown + (pitchUp - pitchDown) * 0.1, 0.01));
      });

      test('放開搖桿回中：保留放開前的翻轉方向', () {
        // 模擬放開搖桿的動畫過程：offset 從 (-0.5, 0) 逐漸回到 (0, 0)
        // 在回到死區之前，翻轉應保留為 true
        final offsets = [
          const Offset(-0.5, 0),
          const Offset(-0.3, 0),
          const Offset(-0.15, 0), // 接近門檻但仍在門檻外
          const Offset(-0.05, 0), // 進入門檻內
        ];

        bool currentFlipped = false;
        for (final offset in offsets) {
          final (_, flipped) = computePlaneRotation(
            joystickOffset: offset,
            currentFlipped: currentFlipped,
            pitchUp: pitchUp,
            pitchDown: pitchDown,
            deadZone: deadZone,
            flipThreshold: flipThreshold,
          );
          currentFlipped = flipped;
        }

        // 最終 offset=(-0.05) 在門檻內，應保留之前的翻轉狀態
        expect(currentFlipped, true);
      });
    });
  });

  // ========================================
  // clampToRadius 測試
  // ========================================
  group('clampToRadius', () {
    test('半徑內的偏移應保持不變', () {
      // 偏移長度（5）小於半徑（10），應回傳原值
      const offset = Offset(3, 4); // 距離 = 5
      final result = clampToRadius(offset, 10);
      expect(result.dx, closeTo(3, 1e-10));
      expect(result.dy, closeTo(4, 1e-10));
    });

    test('剛好在半徑上的偏移應保持不變', () {
      // 偏移長度（5）剛好等於半徑（5），應回傳原值
      const offset = Offset(3, 4); // 距離 = 5
      final result = clampToRadius(offset, 5);
      expect(result.dx, closeTo(3, 1e-10));
      expect(result.dy, closeTo(4, 1e-10));
    });

    test('超出半徑的偏移應被夾制到半徑邊界', () {
      // 偏移長度（10）超過半徑（5），應等比縮放到半徑邊界
      const offset = Offset(6, 8); // 距離 = 10
      final result = clampToRadius(offset, 5);
      // 縮放比例 = 5/10 = 0.5 → (3, 4)
      expect(result.dx, closeTo(3, 1e-10));
      expect(result.dy, closeTo(4, 1e-10));
    });

    test('零向量應回傳零向量', () {
      // 零向量不需要夾制
      final result = clampToRadius(Offset.zero, 5);
      expect(result, Offset.zero);
    });
  });
}
