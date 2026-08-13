import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/app_theme.dart';

/// A tri-zone follower progress bar.
/// 0–100 = crimson, 100–400 = warning, 400–600 = success
class FollowerProgressBar extends StatelessWidget {
  final int followers;
  final double height;

  const FollowerProgressBar({
    super.key,
    required this.followers,
    this.height = 8,
  });

  static const _max = 600.0;

  Color _colorFor(BuildContext context, int followers) {
    final p = context.palette;
    if (followers <= 100) return p.crimson;
    if (followers <= 400) return p.warning;
    return p.success;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final progress = (followers / _max).clamp(0.0, 1.0);
    final color = _colorFor(context, followers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(flex: 100, child: Container(color: p.crimson.withValues(alpha: 0.18))),
                  Expanded(flex: 300, child: Container(color: p.warning.withValues(alpha: 0.18))),
                  Expanded(flex: 200, child: Container(color: p.success.withValues(alpha: 0.18))),
                ],
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(color: color),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 100,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(width: 1, color: p.canvas),
                    ),
                  ),
                  Expanded(
                    flex: 300,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(width: 1, color: p.canvas),
                    ),
                  ),
                  const Expanded(flex: 200, child: SizedBox.shrink()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$followers', style: context.mono(fontSize: 11, color: color)),
            Text('600', style: context.mono(fontSize: 10, color: p.inkSoft)),
          ],
        ),
      ],
    );
  }
}
