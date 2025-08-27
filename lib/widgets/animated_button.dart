import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final double scaleOnTap;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleOnTap = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleOnTap).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding:
                  widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    Theme.of(context).colorScheme.primary,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (widget.backgroundColor ??
                                Theme.of(context).colorScheme.primary)
                            .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color:
                      widget.foregroundColor ??
                      Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PulsingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Duration pulseDuration;

  const PulsingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.pulseDuration = const Duration(seconds: 2),
  });

  @override
  State<PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor:
                widget.color ?? Theme.of(context).colorScheme.primary,
            child: widget.child,
          ),
        );
      },
    );
  }
}
