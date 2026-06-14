import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';

class ZoomControls extends StatefulWidget {
  final MapController mapController;

  const ZoomControls({super.key, required this.mapController});

  @override
  State<ZoomControls> createState() => _ZoomControlsState();
}

class _ZoomControlsState extends State<ZoomControls> {
  Timer? _repeatTimer;

  double get _currentZoom => widget.mapController.camera.zoom;

  bool get _canZoomIn => _currentZoom < MapConstants.maxZoom;

  bool get _canZoomOut => _currentZoom > MapConstants.minZoom;

  void _zoom(double delta) {
    final newZoom = (_currentZoom + delta).clamp(
      MapConstants.minZoom,
      MapConstants.maxZoom,
    );
    widget.mapController.move(widget.mapController.camera.center, newZoom);
  }

  void _startRepeat(double delta) {
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(MapConstants.zoomRepeatDuration, (_) {
      _zoom(delta);
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _canZoomOut ? () => _zoom(-MapConstants.zoomStep) : null,
            onLongPressStart: _canZoomOut
                ? (_) => _startRepeat(-MapConstants.zoomStep)
                : null,
            onLongPressEnd: (_) => _stopRepeat(),
            onLongPressCancel: _stopRepeat,
            child: IconButton(
              onPressed: _canZoomOut
                  ? () => _zoom(-MapConstants.zoomStep)
                  : null,
              icon: Transform.rotate(
                angle: pi / 2,
                child: const Icon(Icons.arrow_circle_left, size: 36),
              ),
            ),
          ),
          GestureDetector(
            onTap: _canZoomIn ? () => _zoom(MapConstants.zoomStep) : null,
            onLongPressStart: _canZoomIn
                ? (_) => _startRepeat(MapConstants.zoomStep)
                : null,
            onLongPressEnd: (_) => _stopRepeat(),
            onLongPressCancel: _stopRepeat,
            child: IconButton(
              onPressed: _canZoomIn
                  ? () => _zoom(MapConstants.zoomStep)
                  : null,
              icon: Transform.rotate(
                angle: pi / 2,
                child: const Icon(Icons.arrow_circle_right, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
