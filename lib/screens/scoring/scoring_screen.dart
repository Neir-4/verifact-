import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/player_model.dart';
import '../../providers/session_provider.dart';
import '../../services/score_calculator.dart';

class ScoringScreen extends ConsumerStatefulWidget {
  const ScoringScreen({super.key});

  @override
  ConsumerState<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends ConsumerState<ScoringScreen> {
  late TurnScoreResult _result;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    _result = ref.read(sessionProvider.notifier).computeScores();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080516),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1A1953),
        title: Text(
          'SKOR GILIRAN INI',
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
            // Verdict header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1953),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart,
                      color: Color(0xFFABD2FB)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _result.factCheckWasCalled
                          ? (_result.uploaderWasHonest
                              ? 'Laporan salah! Uploader terbukti Jujur → Uploader mendapat poin tambahan, pelapor kehilangan poin.'
                              : 'Laporan benar! Uploader TERTANGKAP bohong → Pelapor mendapat poin, uploader terkena penalti.')
                          : (_result.uploaderWasHonest
                              ? 'Lolos tanpa Report! Uploader jujur.'
                              : 'Lolos tanpa Report! Bluff Uploader berhasil.'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Score breakdown
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _result.results.length,
                itemBuilder: (ctx, i) {
                  final score = _result.results[i];
                  final player = session.players.firstWhere(
                      (p) => p.id == score.playerId,
                      orElse: () => Player(
                          id: '', name: 'Unknown', followers: 0));
                  final delta = score.followerDelta;
                  final isUploader =
                      score.playerId == session.currentUploader.id;

                  return _ScoreRow(
                    player: player,
                    delta: delta,
                    isUploader: isUploader,
                    shadowbannedAfter: score.shadowbannedAfter,
                    wasHalved: score.wasHalved,
                    credibleDelta: score.credibleDelta,
                    violationDelta: score.violationDelta,
                  );
                },
              ),
            ),
            // Next turn button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _applied
                      ? null
                      : () {
                          setState(() => _applied = true);
                          ref
                              .read(sessionProvider.notifier)
                              .applyScoresAndNextTurn(_result);
                          context.go('/table');
                        },
                  icon: const Icon(Icons.skip_next),
                  label: Text(
                    'GILIRAN BERIKUTNYA',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800, letterSpacing: 1.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162D93),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
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

class _ScoreRow extends StatelessWidget {
  final Player player;
  final int delta;
  final bool isUploader;
  final bool shadowbannedAfter;
  final bool wasHalved;
  final int credibleDelta;
  final int violationDelta;

  const _ScoreRow({
    required this.player,
    required this.delta,
    required this.isUploader,
    required this.shadowbannedAfter,
    required this.wasHalved,
    required this.credibleDelta,
    required this.violationDelta,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = delta > 0;
    final isZero = delta == 0;
    final deltaColor = isZero
        ? Colors.white38
        : isPositive
            ? Colors.green.shade400
            : Colors.red.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1953),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF162D93),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFABD2FB)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: Color(0xFFFDF9F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (isUploader) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF162D93).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                              color: const Color(0xFF162D93)),
                        ),
                        child: const Text(
                          'UPLOADER',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFABD2FB),
                              letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${player.followers} Followers${shadowbannedAfter ? " • 🔇 SHADOWBANNED" : ""}',
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
                if (wasHalved)
                  const Text(
                    '⚠ Poin gain dibagi 2 (shadowban)',
                    style: TextStyle(
                        fontSize: 11, color: Colors.deepPurpleAccent),
                  ),
                // Jejak Digital updates
                if (credibleDelta > 0 || violationDelta > 0)
                  Row(
                    children: [
                      if (credibleDelta > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 12, color: Colors.green.shade400),
                            const SizedBox(width: 2),
                            Text(
                              '+$credibleDelta Jejak Jujur',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.green.shade400),
                            ),
                          ],
                        ),
                      if (violationDelta > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (credibleDelta > 0) const SizedBox(width: 8),
                            Icon(Icons.cancel_outlined,
                                size: 12, color: Colors.red.shade400),
                            const SizedBox(width: 2),
                            Text(
                              '+$violationDelta Jejak Bohong',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.red.shade400),
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          ),
          // Delta display
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isZero
                    ? '±0'
                    : (isPositive ? '+$delta' : '$delta'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: deltaColor,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Followers',
                style: TextStyle(
                  fontSize: 10,
                  color: deltaColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
