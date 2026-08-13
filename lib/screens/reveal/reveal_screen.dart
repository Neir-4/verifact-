import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../theme/palette.dart';
import '../../widgets/broadcast/masthead.dart';
import '../../widgets/card_reveal_panel.dart';

class RevealScreen extends ConsumerWidget {
  const RevealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final session = ref.watch(sessionProvider);
    final turn = session.currentTurn;
    final cards = turn.scannedCards;
    final claim = turn.uploaderClaim;
    final honest = turn.uploaderIsHonest;
    final verdictColor = honest ? p.success : p.crimson;

    return Scaffold(
      backgroundColor: p.canvas,
      appBar: const AppMasthead(sectionTitle: 'Kebenaran Terungkap'),
      body: SafeArea(
        child: Column(
          children: [
            if (cards.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: verdictColor,
                  border: Border(
                    bottom: BorderSide(color: p.line, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      honest ? Icons.verified : Icons.gpp_bad,
                      color: p.bandInk,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            honest ? 'UPLOADER JUJUR!' : 'UPLOADER TERTANGKAP!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: p.bandInk,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Klaim: ${claim == UploaderClaim.fact ? "FAKTA" : "HOAKS"}',
                            style: TextStyle(
                              color: p.bandInk.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cards.length,
                itemBuilder: (ctx, i) {
                  final card = cards[i];
                  bool? isMatch;
                  if (claim != null) {
                    if (claim == UploaderClaim.fact) {
                      isMatch = card.status.label == 'fact';
                    } else {
                      isMatch = card.status.label == 'hoax';
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CardRevealPanel(card: card, isMatch: isMatch),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).advanceToScoring();
                    context.go('/scoring');
                  },
                  icon: const Icon(Icons.calculate_outlined, size: 19),
                  label: const Text('LIHAT SKOR'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
