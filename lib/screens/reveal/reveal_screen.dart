import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../widgets/card_reveal_panel.dart';

class RevealScreen extends ConsumerWidget {
  const RevealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final turn = session.currentTurn;
    final cards = turn.scannedCards;
    final claim = turn.uploaderClaim;

    return Scaffold(
      backgroundColor: const Color(0xFF080516),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1A1953),
        title: Text(
          'KEBENARAN TERUNGKAP',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFDF9F1),
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary banner
            if (cards.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: turn.uploaderIsHonest
                      ? Colors.green.shade900.withValues(alpha: 0.4)
                      : Colors.red.shade900.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: turn.uploaderIsHonest
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      turn.uploaderIsHonest ? Icons.verified : Icons.gpp_bad,
                      color: turn.uploaderIsHonest
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      size: 36,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            turn.uploaderIsHonest
                                ? 'UPLOADER JUJUR!'
                                : 'UPLOADER TERTANGKAP!',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: turn.uploaderIsHonest
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Klaim: ${claim == UploaderClaim.fact ? "FAKTA" : "HOAKS"}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Cards list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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

            // Continue to scoring
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).advanceToScoring();
                    context.go('/scoring');
                  },
                  icon: const Icon(Icons.calculate_outlined),
                  label: Text(
                    'LIHAT SKOR',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800, letterSpacing: 1.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162D93),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
