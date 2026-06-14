import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';

class ZoomControls extends StatefulWidget {
  final MapController mapController;
  final VoidCallback? onLongPressUpStart;
  final VoidCallback? onLongPressDownStart;
  final VoidCallback? onLongPressEnd;

  const ZoomControls({
    super.key,
    required this.mapController,
    this.onLongPressUpStart,
    this.onLongPressDownStart,
    this.onLongPressEnd,
  });

  @override
  State<ZoomControls> createState() => _ZoomControlsState();
}

class _ZoomControlsState extends State<ZoomControls> {
  Timer? _repeatTimer;

  double get _currentZoom => widget.mapController.camera.zoom;

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
            onTap: () => _zoom(-MapConstants.zoomStep),
            onLongPressStart: (_) {
              _startRepeat(-MapConstants.zoomStep);
              widget.onLongPressUpStart?.call();
            },
            onLongPressEnd: (_) {
              _stopRepeat();
              widget.onLongPressEnd?.call();
            },
            onLongPressCancel: () {
              _stopRepeat();
              widget.onLongPressEnd?.call();
            },
            child: IconButton(
              onPressed: () => _zoom(-MapConstants.zoomStep),
              icon: Transform.rotate(
                angle: pi / 2,
                child: const Icon(Icons.arrow_circle_left, size: 36),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _zoom(MapConstants.zoomStep),
            onLongPressStart: (_) {
              _startRepeat(MapConstants.zoomStep);
              widget.onLongPressDownStart?.call();
            },
            onLongPressEnd: (_) {
              _stopRepeat();
              widget.onLongPressEnd?.call();
            },
            onLongPressCancel: () {
              _stopRepeat();
              widget.onLongPressEnd?.call();
            },
            child: IconButton(
              onPressed: () => _zoom(MapConstants.zoomStep),
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
