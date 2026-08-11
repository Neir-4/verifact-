import 'package:flutter/material.dart';

/// A tri-zone follower progress bar.
/// 0–100 = red, 100–400 = yellow, 400–600 = green
class FollowerProgressBar extends StatelessWidget {
  final int followers;
  final double height;

  const FollowerProgressBar({
    super.key,
    required this.followers,
    this.height = 10,
  });

  static const _max = 600.0;

  Color _colorForFollowers(int followers) {
    if (followers <= 100) return Colors.red.shade400;
    if (followers <= 400) return Colors.amber.shade600;
    return Colors.green.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (followers / _max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // Background track (tri-color gradient)
                Row(
                  children: [
                    Flexible(
                      flex: 100,
                      child: Container(color: Colors.red.shade900.withValues(alpha: 0.3)),
                    ),
                    Flexible(
                      flex: 300,
                      child: Container(color: Colors.amber.shade900.withValues(alpha: 0.3)),
                    ),
                    Flexible(
                      flex: 200,
                      child: Container(color: Colors.green.shade900.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height / 2),
                      color: _colorForFollowers(followers),
                    ),
                  ),
                ),
                // Zone dividers
                Row(
                  children: [
                    Flexible(
                      flex: 100,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 1,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 300,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 1,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                    const Flexible(flex: 200, child: SizedBox.shrink()),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$followers',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _colorForFollowers(followers),
              ),
            ),
            const Text(
              '600',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
