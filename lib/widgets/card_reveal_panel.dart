import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/card_model.dart';
import '../theme/palette.dart';
import '../theme/app_theme.dart';

class CardRevealPanel extends StatelessWidget {
  final GameCard card;
  final bool? isMatch; // null = no claim context
  final bool expanded;

  const CardRevealPanel({
    super.key,
    required this.card,
    this.isMatch,
    this.expanded = false,
  });

  Color _statusColor(BuildContext context, CardStatus status) {
    final p = context.palette;
    switch (status) {
      case CardStatus.fact:
        return p.brand;
      case CardStatus.hoax:
        return p.crimson;
      case CardStatus.opinion:
        return p.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final statusColor = _statusColor(context, card.status);

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: statusColor, width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header band: card ID + status + match badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: statusColor.withValues(alpha: 0.14),
            child: Row(
              children: [
                Text(card.id, style: context.mono(fontSize: 11, color: statusColor)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  color: statusColor,
                  child: Text(
                    card.status.displayName,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: p.bandInk,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const Spacer(),
                if (isMatch != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    color: isMatch! ? p.success : p.crimson,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isMatch! ? Icons.check : Icons.close, size: 13, color: p.bandInk),
                        const SizedBox(width: 4),
                        Text(
                          isMatch! ? 'Cocok' : 'Tidak Cocok',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: p.bandInk),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text(
              card.platform,
              style: context.mono(fontSize: 11, color: statusColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(
              card.headline,
              style: context.body.copyWith(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.canvas,
                border: Border(left: BorderSide(color: statusColor, width: 3)),
              ),
              child: Text(
                '"${card.originalStatement}"',
                style: context.bodySoft.copyWith(fontSize: 13, fontStyle: FontStyle.italic, height: 1.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(
              card.articleBody,
              style: context.body.copyWith(fontSize: 14, height: 1.7),
            ),
          ),
          if (card.sources.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
              child: Text('SUMBER', style: context.label.copyWith(fontSize: 10, letterSpacing: 1.8)),
            ),
            ...card.sources.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final source = entry.value;
              return InkWell(
                onTap: () async {
                  final uri = Uri.parse(source.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$idx. ', style: context.mono(fontSize: 13, color: p.brand)),
                      Expanded(
                        child: Text(
                          source.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: p.brand,
                            decoration: TextDecoration.underline,
                            decorationColor: p.brand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
