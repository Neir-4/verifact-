import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/session_provider.dart';
import '../../services/score_calculator.dart';
import '../../widgets/player_card_widget.dart';

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final sorted = ScoreCalculator.sortByFollowers(session.players);
    final uploader = session.currentUploader;

    return Scaffold(
      backgroundColor: const Color(0xFF080516),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAPAN SKOR',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFABD2FB),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live Followers',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFDF9F1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.players.length} pemain • Giliran ${session.turnCount + 1}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final player = sorted[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PlayerCardWidget(
                      player: player,
                      rank: i + 1,
                      isUploader: player.id == uploader.id,
                    ),
                  );
                },
                childCount: sorted.length,
              ),
            ),
            // Legend
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'JEJAK DIGITAL',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFABD2FB),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jejak Digital mencerminkan kejujuran pemain sepanjang permainan. '
                      'Pemenang ditentukan dari siapa yang memiliki Jejak Digital paling bersih.',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Shadowban explanation
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade900.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.deepPurple.shade400
                                .withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.visibility_off,
                              color: Colors.deepPurple.shade300, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Shadowbanned: Saat Followers = 0, semua gain dibagi 2 sampai mencapai 50.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.deepPurple.shade200,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
