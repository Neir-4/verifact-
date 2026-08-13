import 'package:flutter/material.dart';
import '../../theme/palette.dart';

/// A panel with chamfered (cut, not rounded) corners and a hairline border —
/// the HUD-panel unit of the broadcast system. Never nest these.
class ChamferedPanel extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final double chamfer;

  const ChamferedPanel({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.all(16),
    this.chamfer = 10,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: ShapeDecoration(
        color: color ?? p.surface,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(chamfer)),
          side: BorderSide(
            color: borderColor ?? p.line,
            width: borderWidth,
          ),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
