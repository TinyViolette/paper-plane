import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';
import 'package:paperplane/cubit/zoom/zoom_cubit.dart';

class ZoomControls extends StatefulWidget {
  final VoidCallback? onZoomButtonStart;
  final VoidCallback? onZoomButtonEnd;

  const ZoomControls({
    super.key,
    this.onZoomButtonStart,
    this.onZoomButtonEnd,
  });

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
              widget.onZoomButtonStart?.call();
            },
            onLongPressEnd: (_) {
              _stopRepeat();
              widget.onZoomButtonEnd?.call();
            },
            onLongPressCancel: () {
              _stopRepeat();
              widget.onZoomButtonEnd?.call();
            },
            child: IconButton(
              onPressed: cubit.zoomOut,
              icon: Transform.rotate(
                angle: pi / 2,
                child: const Icon(Icons.arrow_circle_left, size: 36),
              ),
            ),
          ),
          BlocBuilder<Cubit<PlaneState>, PlaneState>(
            buildWhen: (prev, curr) => prev.isLanded != curr.isLanded,
            builder: (context, planeState) {
              final isLanded = planeState.isLanded;
              return IgnorePointer(
                ignoring: isLanded,
                child: Opacity(
                  opacity: isLanded ? 0.3 : 1.0,
                  child: GestureDetector(
                    onTap: cubit.zoomIn,
                    onLongPressStart: (_) {
                      _startRepeat(cubit.zoomIn);
                      widget.onZoomButtonStart?.call();
                    },
                    onLongPressEnd: (_) {
                      _stopRepeat();
                      widget.onZoomButtonEnd?.call();
                    },
                    onLongPressCancel: () {
                      _stopRepeat();
                      widget.onZoomButtonEnd?.call();
                    },
                    child: IconButton(
                      onPressed: cubit.zoomIn,
                      icon: Transform.rotate(
                        angle: pi / 2,
                        child: const Icon(Icons.arrow_circle_right, size: 36),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
