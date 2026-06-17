import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_cubit.dart';
import 'package:paperplane/cubit/function_switcher/function_switcher_state.dart';

class FunctionSwitcher extends StatelessWidget {
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;

  const FunctionSwitcher({
    super.key,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
  });

  static const List<IconData> _icons = [
    Icons.add_location_alt,
    Icons.casino,
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 16,
      child: BlocBuilder<FunctionSwitcherCubit, FunctionSwitcherState>(
        builder: (context, state) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < 0) {
                  onSwipeLeft();
                } else if (details.primaryVelocity! > 0) {
                  onSwipeRight();
                }
              }
            },
            onTap: onTap,
            child: Container(
              width: 120,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_icons.length, (index) {
                  final isSelected = state.selectedIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      _icons[index],
                      size: isSelected ? 36 : 24,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}
