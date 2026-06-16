import 'package:flutter/material.dart';

class RandomTeleportButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RandomTeleportButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 16,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.casino, size: 36),
      ),
    );
  }
}
