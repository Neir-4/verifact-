import 'package:flutter/material.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';

/// A labelled strip that heads a module — every module gets a band,
/// not a floating headline.
class SectionBand extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const SectionBand({super.key, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.lineStrong, width: 2)),
      ),
      child: Row(
        children: [
          Container(width: 7, height: 7, color: p.brand),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: context.label,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
