import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:paperplane/constants/map_constants.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_cubit.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_state.dart';

class FunctionSwitcher extends StatefulWidget {
  final MapController mapController;
  final bool isBlossomMode;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FunctionSwitcher({
    super.key,
    required this.mapController,
    required this.isBlossomMode,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<FunctionSwitcher> createState() => _FunctionSwitcherState();
}

class _FunctionSwitcherState extends State<FunctionSwitcher>
    with SingleTickerProviderStateMixin {
  int _slideDirection = 0;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FunctionSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlossomMode && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isBlossomMode && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onSwipeLeft() {
    setState(() => _slideDirection = -1);
    widget.onSwipeLeft();
  }

  void _onSwipeRight() {
    setState(() => _slideDirection = 1);
    widget.onSwipeRight();
  }

  static const double _disabledAlpha = 0.5;

  Widget _buildIcon(int index, bool isEnabled) {
    final color = isEnabled
        ? Colors.white
        : Colors.white.withValues(alpha: _disabledAlpha);
    final key = ValueKey<int>(index);

    switch (index) {
      case 0:
        return Image.asset(
          'assets/images/blossom.png',
          key: key,
          width: 40,
          height: 40,
          color: color,
        );
      case 1:
        return Image.asset(
          'assets/images/bomb.png',
          key: key,
          width: 40,
          height: 40,
          color: color,
        );
      case 2:
        return Icon(Icons.add_location_alt, key: key, size: 30, color: color);
      case 3:
        return Icon(Icons.casino, key: key, size: 30, color: color);
      default:
        return const SizedBox.shrink();
    }
  }

  bool _isFunctionEnabled(int index, double zoom) {
    switch (index) {
      case 0:
        return zoom > MapConstants.blossomMinZoom &&
            zoom < MapConstants.blossomMaxZoom;
      case 1:
        return zoom >= MapConstants.bombMinZoom &&
            zoom <= MapConstants.bombMaxZoom;
      case 2:
        return zoom >= MapConstants.maxZoom;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 16,
      child: StreamBuilder<MapEvent>(
        stream: widget.mapController.mapEventStream,
        builder: (context, _) {
          final zoom = widget.mapController.camera.zoom;
          return BlocBuilder<FunctionSwitcherCubit, FunctionSwitcherState>(
            builder: (context, state) {
              final isEnabled = _isFunctionEnabled(state.selectedIndex, zoom);
              final isBlossomSelected = state.selectedIndex == 0;
              return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < 0) {
                      _onSwipeLeft();
                    } else if (details.primaryVelocity! > 0) {
                      _onSwipeRight();
                    }
                  }
                },
                onTap: isEnabled ? widget.onTap : null,
                onLongPress: isBlossomSelected ? widget.onLongPress : null,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final opacity = widget.isBlossomMode
                        ? _pulseAnimation.value
                        : 1.0;
                    return Opacity(
                      opacity: opacity,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (child, animation) {
                          final offset = _slideDirection >= 0
                              ? const Offset(1.0, 0.0)
                              : const Offset(-1.0, 0.0);
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: offset,
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                        child: _buildIcon(state.selectedIndex, isEnabled),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
