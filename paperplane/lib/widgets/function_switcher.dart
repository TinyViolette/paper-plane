import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_cubit.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_state.dart';
import 'package:paperplane/cubit/plane/plane_state.dart';

class FunctionSwitcher extends StatefulWidget {
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;

  const FunctionSwitcher({
    super.key,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
  });

  @override
  State<FunctionSwitcher> createState() => _FunctionSwitcherState();
}

class _FunctionSwitcherState extends State<FunctionSwitcher> {
  static const List<IconData> _icons = [
    Icons.add_location_alt,
    Icons.casino,
  ];

  int _slideDirection = 0;

  void _onSwipeLeft() {
    setState(() => _slideDirection = -1);
    widget.onSwipeLeft();
  }

  void _onSwipeRight() {
    setState(() => _slideDirection = 1);
    widget.onSwipeRight();
  }

  static const double _disabledAlpha = 0.5;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 16,
      child: BlocBuilder<Cubit<PlaneState>, PlaneState>(
        builder: (context, planeState) {
          return BlocBuilder<FunctionSwitcherCubit, FunctionSwitcherState>(
            builder: (context, state) {
              final isMarkEnabled =
                  state.selectedIndex != 0 || planeState.isLanded;
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
                onTap: isMarkEnabled ? widget.onTap : null,
                child: Container(
                  width: 40,
                  height: 40,
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
                      child: Icon(
                        _icons[state.selectedIndex],
                        key: ValueKey<int>(state.selectedIndex),
                        size: 20,
                        color: isMarkEnabled
                            ? Colors.white
                            : Colors.white.withValues(alpha: _disabledAlpha),
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
