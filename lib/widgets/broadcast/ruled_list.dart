import 'package:flutter/material.dart';
import '../../theme/palette.dart';

/// A single bordered panel whose children are separated by hairline rules —
/// "score board as ruled rows", never a stack of separate rounded cards.
class RuledPanel extends StatelessWidget {
  final List<Widget> children;
  final Color? borderColor;
  final Color? background;

  const RuledPanel({
    super.key,
    required this.children,
    this.borderColor,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: background ?? p.canvas,
        border: Border.all(color: borderColor ?? p.line),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: p.line),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One padded row inside a [RuledPanel].
class RuledRow extends StatelessWidget {
  final Widget child;
  final Color? background;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const RuledRow({
    super.key,
    required this.child,
    this.background,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      color: background ?? Colors.transparent,
      padding: padding,
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
