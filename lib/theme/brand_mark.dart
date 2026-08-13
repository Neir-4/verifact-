import 'package:flutter/material.dart';

/// Three signal bars — the VERIFACT mark. Broadcast levels, not a logo-in-a-box.
class BrandMark extends StatelessWidget {
  final double size;
  final Color color;

  const BrandMark({super.key, this.size = 22, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BrandMarkPainter(color: color),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  final Color color;
  const _BrandMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    final paint = Paint()..color = color;

    void bar(double y, double w, double opacity) {
      paint.color = color.withValues(alpha: opacity);
      canvas.drawRect(
        Rect.fromLTWH(2 * unit, y * unit, w * unit, 4.4 * unit),
        paint,
      );
    }

    bar(4, 20, 1.0);
    bar(10.2, 13, 0.45);
    bar(16.4, 17, 0.75);
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Faint diagonal hatch texture for navy bands — "hatched navy" per brand.
class HatchPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double spacing;

  const HatchPainter({
    required this.color,
    this.opacity = 0.05,
    this.spacing = 9,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1;

    final diag = size.width + size.height;
    for (double x = -size.height; x < diag; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HatchPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.spacing != spacing;
}

/// A navy band container with subtle hatch texture behind its child.
class HatchedBand extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final Border? border;

  const HatchedBand({
    super.key,
    required this.child,
    required this.color,
    this.padding = EdgeInsets.zero,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, border: border),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: HatchPainter(color: Colors.white, opacity: 0.04),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
