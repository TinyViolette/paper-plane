import 'package:flutter_test/flutter_test.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/zoom/zoom_cubit.dart';
import 'package:paperplane/cubit/zoom/zoom_state.dart';

/// ZoomCubit 單元測試
///
/// ZoomCubit 是純邏輯的 Cubit，無外部依賴，負責管理地圖縮放等級。
/// 測試涵蓋：初始狀態、zoomIn/zoomOut 邏輯、上下界夾取。
void main() {
  group('ZoomCubit', () {
    // ========================================
    // 初始狀態測試
    // ========================================
    test('初始狀態應為 MapConstants.initialZoom', () {
      // ZoomCubit 建立時應以 initialZoom 作為初始縮放值
      final cubit = ZoomCubit();
      expect(cubit.state.zoom, MapConstants.initialZoom);
      expect(cubit.state, isA<ZoomUpdated>());
      cubit.close();
    });

    // ========================================
    // zoomIn 測試
    // ========================================
    test('zoomIn 應將 zoom 增加 zoomStep', () {
      // 從非最大值開始測試，避免被 maxZoom 夾取
      // 需要先 zoomOut 幾步，讓 zoom 有空間增加
      final cubit = ZoomCubit();
      cubit.zoomOut();
      cubit.zoomOut();
      final beforeZoom = cubit.state.zoom;

      cubit.zoomIn();

      expect(cubit.state.zoom, beforeZoom + MapConstants.zoomStep);
      cubit.close();
    });

    test('連續 zoomIn 應累加 zoomStep', () {
      // 從較低的 zoom 開始，避免到達上界
      final cubit = ZoomCubit();
      for (var i = 0; i < 5; i++) {
        cubit.zoomOut();
      }
      final beforeZoom = cubit.state.zoom;

      cubit.zoomIn();
      cubit.zoomIn();
      cubit.zoomIn();

      expect(
        cubit.state.zoom,
        closeTo(beforeZoom + MapConstants.zoomStep * 3, 1e-10),
      );
      cubit.close();
    });

    // ========================================
    // zoomOut 測試
    // ========================================
    test('zoomOut 應將 zoom 減少 zoomStep', () {
      // 每次 zoomOut 應將縮放值減少一個固定步進量
      final cubit = ZoomCubit();

      cubit.zoomOut();

      expect(
        cubit.state.zoom,
        MapConstants.initialZoom - MapConstants.zoomStep,
      );
      cubit.close();
    });

    // ========================================
    // 上界夾取測試
    // ========================================
    test('zoomIn 不應超過 maxZoom', () {
      // 當 zoom 已接近上界時，zoomIn 不應讓 zoom 超過 maxZoom
      final cubit = ZoomCubit();

      // 手動設定 zoom 接近上界（模擬多次 zoomIn 後的狀態）
      // 直接用 zoomIn 反覆呼叫直到到達上界
      final stepsToMax =
          ((MapConstants.maxZoom - MapConstants.initialZoom) /
                  MapConstants.zoomStep)
              .ceil();
      for (var i = 0; i < stepsToMax + 10; i++) {
        cubit.zoomIn();
      }

      // zoom 應被夾取在 maxZoom
      expect(cubit.state.zoom, MapConstants.maxZoom);
      cubit.close();
    });

    // ========================================
    // 下界夾取測試
    // ========================================
    test('zoomOut 不應低於 minZoom', () {
      // 當 zoom 已接近下界時，zoomOut 不應讓 zoom 低於 minZoom
      final cubit = ZoomCubit();

      // 手動 zoomOut 直到到達下界
      final stepsToMin =
          ((MapConstants.initialZoom - MapConstants.minZoom) /
                  MapConstants.zoomStep)
              .ceil();
      for (var i = 0; i < stepsToMin + 10; i++) {
        cubit.zoomOut();
      }

      // zoom 應被夾取在 minZoom
      expect(cubit.state.zoom, MapConstants.minZoom);
      cubit.close();
    });
  });
}
