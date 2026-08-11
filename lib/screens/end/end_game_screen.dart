import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/session_provider.dart';
import '../../services/score_calculator.dart';
import '../../widgets/follower_progress_bar.dart';

class EndGameScreen extends ConsumerWidget {
  const EndGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final sorted = ScoreCalculator.sortByFollowers(session.players);
    final winners = ScoreCalculator.getWinners(session.players);
    final winner = sorted.isNotEmpty ? sorted.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFF080516),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Victory Banner ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF162D93),
                      Color(0xFF1A1953),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFABD2FB).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: Color(0xFFFFD700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PERMAINAN SELESAI!',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFABD2FB),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      winner?.name ?? '—',
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFDF9F1),
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'MENANG!',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFABD2FB),
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Podium Labels ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'HASIL AKHIR',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFABD2FB),
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),

            // ── Final Scoreboard ─────────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final player = sorted[i];
                  final isWinner = winners.any((w) => w.id == player.id);
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? const Color(0xFF162D93).withValues(alpha: 0.3)
                          : const Color(0xFF1A1953),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isWinner
                            ? const Color(0xFFABD2FB).withValues(alpha: 0.5)
                            : Colors.white12,
                        width: isWinner ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Rank
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _rankColor(i),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _rankEmoji(i),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFFDF9F1),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${player.followers} Followers',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(Icons.check_circle_outline,
                                          size: 12,
                                          color: Colors.green.shade400),
                                      Text(
                                        ' ${player.credibleCount}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green.shade400),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(Icons.cancel_outlined,
                                          size: 12,
                                          color: Colors.red.shade400),
                                      Text(
                                        ' ${player.violationCount}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red.shade400),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Followers badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF162D93),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${player.followers}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFABD2FB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FollowerProgressBar(followers: player.followers),
                      ],
                    ),
                  );
                },
                childCount: sorted.length,
              ),
            ),

            // ── Play Again ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(sessionProvider.notifier).newGame();
                          context.go('/setup');
                        },
                        icon: const Icon(Icons.replay),
                        label: Text(
                          'MAIN LAGI',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800, letterSpacing: 2),
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rankColor(int i) {
    switch (i) {
      case 0:
        return const Color(0xFFFFD700).withValues(alpha: 0.25);
      case 1:
        return Colors.grey.shade700.withValues(alpha: 0.3);
      case 2:
        return Colors.brown.shade700.withValues(alpha: 0.3);
      default:
        return Colors.white10;
    }
  }

  String _rankEmoji(int i) {
    switch (i) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '${i + 1}';
    }
  }
}
