import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;
  final double height;

  const ProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: progressColor.withOpacity(0.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
      ],
    );
  }
}

class CircularProgress extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;
  final double size;
  final double strokeWidth;

  const CircularProgress({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.size = 60.0,
    this.strokeWidth = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: progressColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          if (label != null)
            Text(
              label!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
        ],
      ),
    );
  }
}
