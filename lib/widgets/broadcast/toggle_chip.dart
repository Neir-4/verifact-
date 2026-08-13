import 'package:flutter/material.dart';
import '../../theme/palette.dart';

/// A sharp-edged selectable toggle — replaces the rounded-pill selector.
class ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  const ToggleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(
            color: selected ? color : p.lineStrong,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: selected ? p.bandInk : color),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: selected ? p.bandInk : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
