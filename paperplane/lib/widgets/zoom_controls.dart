import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/zoom/zoom_cubit.dart';

class ZoomControls extends StatefulWidget {
  const ZoomControls({super.key});

  @override
  State<ZoomControls> createState() => _ZoomControlsState();
}

class _ZoomControlsState extends State<ZoomControls> {
  Timer? _repeatTimer;

  void _startRepeat(VoidCallback action) {
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(MapConstants.zoomRepeatDuration, (_) {
      action();
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
    final cubit = context.read<ZoomCubit>();

    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: cubit.zoomOut,
            onLongPressStart: (_) {
              _startRepeat(cubit.zoomOut);
            },
            onLongPressEnd: (_) => _stopRepeat(),
            onLongPressCancel: _stopRepeat,
            child: IconButton(
              onPressed: cubit.zoomOut,
              icon: Transform.rotate(
                angle: pi / 2,
                child: const Icon(Icons.arrow_circle_left, size: 36),
              ),
            ),
          ),
          GestureDetector(
            onTap: cubit.zoomIn,
            onLongPressStart: (_) {
              _startRepeat(cubit.zoomIn);
            },
            onLongPressEnd: (_) => _stopRepeat(),
            onLongPressCancel: _stopRepeat,
            child: IconButton(
              onPressed: cubit.zoomIn,
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
