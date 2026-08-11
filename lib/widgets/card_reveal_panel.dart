import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/card_model.dart';

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

  Color _statusColor(CardStatus status) {
    switch (status) {
      case CardStatus.fact:
        return const Color(0xFF162D93);
      case CardStatus.hoax:
        return const Color(0xFFC0392B);
      case CardStatus.opinion:
        return const Color(0xFFF39C12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1953),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _statusColor(card.status).withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: card ID + status + match badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusColor(card.status).withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                // Card ID pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    card.id,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFABD2FB),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(card.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    card.status.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                // Match badge
                if (isMatch != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isMatch! ? Colors.green.shade700 : Colors.red.shade800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMatch! ? Icons.check : Icons.close,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMatch! ? 'Cocok' : 'Tidak Cocok',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Platform
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              card.platform,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFABD2FB),
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Headline
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              card.headline,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFDF9F1),
                height: 1.3,
              ),
            ),
          ),
          // Original statement
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: _statusColor(card.status).withValues(alpha: 0.7),
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                '"${card.originalStatement}"',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ),
          // Article body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              card.articleBody,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFFDF9F1),
                height: 1.7,
              ),
            ),
          ),
          // Sources
          if (card.sources.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                'SUMBER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFABD2FB),
                  letterSpacing: 1.8,
                ),
              ),
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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$idx. ',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFABD2FB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          source.label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFABD2FB),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFABD2FB),
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
