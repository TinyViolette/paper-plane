import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/blossom/blossom_cubit.dart';
import 'package:paperplane/cubit/blossom/blossom_state.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

class BlossomOverlay extends StatefulWidget {
  final MapController mapController;

  const BlossomOverlay({super.key, required this.mapController});

  @override
  State<BlossomOverlay> createState() => BlossomOverlayState();
}

class BlossomOverlayState extends State<BlossomOverlay> {
  bool _isBlossomMode = false;
  Timer? _blossomTimer;
  DateTime _lastBlossomTime = DateTime.fromMillisecondsSinceEpoch(0);
  Offset _lastPlaneOffset = Offset.zero;

  bool get isBlossomMode => _isBlossomMode;

  void toggleBlossomMode() {
    if (_isBlossomMode) {
      stopBlossomMode();
    } else {
      startBlossomMode();
    }
  }

  void startBlossomMode() {
    setState(() => _isBlossomMode = true);
    _blossomTimer?.cancel();
    _blossomTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _checkAndPlantBlossom();
    });
  }

  void stopBlossomMode() {
    setState(() => _isBlossomMode = false);
    _blossomTimer?.cancel();
    _blossomTimer = null;
  }

  void _checkAndPlantBlossom() {
    if (!_isBlossomMode) return;

    final zoom = widget.mapController.camera.zoom;
    if (zoom <= MapConstants.blossomMinZoom ||
        zoom >= MapConstants.blossomMaxZoom) {
      stopBlossomMode();
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastBlossomTime) < MapConstants.blossomInterval) return;

    final planeState = context.read<Cubit<PlaneState>>().state;
    if (planeState.planeOffset == _lastPlaneOffset) return;

    _plantBlossom(planeState.planeOffset);
    _lastPlaneOffset = planeState.planeOffset;
    _lastBlossomTime = now;
  }

  void _plantBlossom(Offset planeOffset) {
    final random = Random();
    final center = widget.mapController.camera.center;
    final zoom = widget.mapController.camera.zoom;

    // 隨機偏移（均勻分布在圓形區域內）
    final angle = random.nextDouble() * 2 * pi;
    final radius =
        random.nextDouble() * MapConstants.blossomRandomRadius;
    final dx = radius * cos(angle);
    final dy = radius * sin(angle);

    // 換算成地圖座標
    final position = _offsetToLatLng(Offset(dx, dy), center, zoom);

    // 隨機縮放 (0.5~1.5)
    final scale = MapConstants.blossomScaleMin +
        random.nextDouble() *
            (MapConstants.blossomScaleMax - MapConstants.blossomScaleMin);

    // 隨機旋轉 (0~360)
    final rotation = random.nextDouble() * 360;

    final blossom = BlossomData(
      position: position,
      scale: scale,
      rotation: rotation,
      timestamp: DateTime.now(),
    );

    context.read<BlossomCubit>().addBlossom(blossom);
  }

  LatLng _offsetToLatLng(Offset pixelOffset, LatLng reference, double zoom) {
    final metersPerPixel =
        156543.03392 * cos(reference.latitude * pi / 180) / pow(2, zoom);

    final dxMeters = pixelOffset.dx * metersPerPixel;
    final dyMeters = pixelOffset.dy * metersPerPixel;

    final lat = reference.latitude - (dyMeters / 111320);
    final lng = reference.longitude +
        (dxMeters / (111320 * cos(reference.latitude * pi / 180)));

    return LatLng(lat, lng);
  }

  @override
  void dispose() {
    _blossomTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
