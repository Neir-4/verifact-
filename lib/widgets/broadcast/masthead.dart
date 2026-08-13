import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/palette.dart';
import '../../theme/brand_mark.dart';

/// The navy masthead: brand mark + wordmark, always present, optionally
/// showing a back arrow and the current section instead.
class AppMasthead extends StatelessWidget implements PreferredSizeWidget {
  final String? sectionTitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppMasthead({
    super.key,
    this.sectionTitle,
    this.showBack = false,
    this.onBack,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;
    return HatchedBand(
      color: p.band,
      border: Border(bottom: BorderSide(color: p.brand, width: 2)),
      padding: EdgeInsets.fromLTRB(16, topInset, 16, 0),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            if (showBack)
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.arrow_back, color: p.accent, size: 20),
              )
            else ...[
              BrandMark(size: 20, color: p.accent),
              const SizedBox(width: 10),
            ],
            Text(
              'VERIFACT',
              style: GoogleFonts.libreFranklin(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: p.bandInk,
                letterSpacing: 1,
              ),
            ),
            if (sectionTitle != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 1,
                  height: 16,
                  color: p.bandInk.withValues(alpha: 0.25),
                ),
              ),
              Expanded(
                child: Text(
                  sectionTitle!.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.libreFranklin(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.accent,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
