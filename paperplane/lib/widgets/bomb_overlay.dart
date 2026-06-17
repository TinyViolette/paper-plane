import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/burn_mark/burn_mark_cubit.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

class BombOverlay extends StatefulWidget {
  final MapController mapController;

  const BombOverlay({super.key, required this.mapController});

  @override
  State<BombOverlay> createState() => BombOverlayState();
}

class BombOverlayState extends State<BombOverlay>
    with TickerProviderStateMixin {
  final List<_BombAnimation> _bombs = [];
  Timer? _cooldownTimer;
  bool _canBomb = true;

  void triggerBomb(Offset planeOffset, LatLng dropPosition) {
    if (!_canBomb) return;
    if (_bombs.length >= 2) return;

    _canBomb = false;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(MapConstants.bombInterval, () {
      if (mounted) {
        setState(() => _canBomb = true);
      }
    });

    final controller = AnimationController(
      duration: MapConstants.bombAnimationDuration,
      vsync: this,
    );

    final animation = Tween<double>(begin: 0, end: MapConstants.bombDropOffset).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    final bomb = _BombAnimation(
      controller: controller,
      animation: animation,
      offset: planeOffset,
      dropPosition: dropPosition,
    );

    setState(() => _bombs.add(bomb));

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.read<BurnMarkCubit>().addBurnMark(dropPosition);
        setState(() => _bombs.remove(bomb));
        bomb.dispose();
      }
    });

    controller.forward();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (final bomb in _bombs) {
      bomb.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Cubit<PlaneState>, PlaneState>(
      buildWhen: (previous, current) =>
          previous.planeOffset != current.planeOffset,
      builder: (context, planeState) {
        return Stack(
          children: _bombs.map((bomb) {
            return AnimatedBuilder(
              animation: bomb.animation,
              builder: (context, child) {
                return Center(
                  child: Transform.translate(
                    offset: Offset(
                      bomb.offset.dx,
                      bomb.offset.dy + bomb.animation.value,
                    ),
                    child: const Text(
                      '💣',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _BombAnimation {
  final AnimationController controller;
  final Animation<double> animation;
  final Offset offset;
  final LatLng dropPosition;

  _BombAnimation({
    required this.controller,
    required this.animation,
    required this.offset,
    required this.dropPosition,
  });

  void dispose() {
    controller.dispose();
  }
}
