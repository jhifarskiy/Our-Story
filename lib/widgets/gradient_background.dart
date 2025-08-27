import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      const Color(0xFF2C1810), // Темно-коричневый
      const Color(0xFF6B4E3D), // Коричневый
      const Color(0xFF8B6F47), // Светло-коричневый
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? defaultColors,
        ),
      ),
      child: child,
    );
  }
}
