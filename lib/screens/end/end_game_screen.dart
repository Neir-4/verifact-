import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/session_provider.dart';
import '../../services/score_calculator.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/brand_mark.dart';
import '../../widgets/broadcast/chamfered_panel.dart';
import '../../widgets/broadcast/section_band.dart';
import '../../widgets/broadcast/ruled_list.dart';
import '../../widgets/follower_progress_bar.dart';

class EndGameScreen extends ConsumerWidget {
  const EndGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final session = ref.watch(sessionProvider);
    final sorted = ScoreCalculator.sortByFollowers(session.players);
    final winners = ScoreCalculator.getWinners(session.players, session.gameMode);
    final winner = winners.isNotEmpty ? winners.first : null;

    return Scaffold(
      backgroundColor: p.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            ChamferedPanel(
              color: p.band,
              borderColor: p.brand,
              borderWidth: 2,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  BrandMark(size: 30, color: p.accent),
                  const SizedBox(height: 14),
                  Text('PERMAINAN SELESAI!', style: context.eyebrowOnBand),
                  const SizedBox(height: 10),
                  Text(
                    winner?.name ?? '—',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: p.bandInk,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MENANG — MODE ${session.gameMode.name.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.accent,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionBand(label: 'Hasil akhir'),
            const SizedBox(height: 14),
            RuledPanel(
              children: sorted.asMap().entries.map((entry) {
                final i = entry.key;
                final player = entry.value;
                final isWinner = winners.any((w) => w.id == player.id);
                return RuledRow(
                  padding: const EdgeInsets.all(14),
                  background: isWinner ? p.brand.withValues(alpha: 0.07) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_rankLabel(i), style: context.mono(fontSize: 15, color: p.brand)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player.name,
                                  style: context.body.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    Text('${player.followers} Followers',
                                        style: context.bodySoft.copyWith(fontSize: 12)),
                                    const SizedBox(width: 10),
                                    Icon(Icons.check_circle_outline, size: 12, color: p.success),
                                    Text(' ${player.credibleCount}',
                                        style: context.mono(fontSize: 11, color: p.success)),
                                    const SizedBox(width: 6),
                                    Icon(Icons.cancel_outlined, size: 12, color: p.crimson),
                                    Text(' ${player.violationCount}',
                                        style: context.mono(fontSize: 11, color: p.crimson)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            color: p.brand.withValues(alpha: 0.12),
                            child: Text('${player.followers}', style: context.mono(fontSize: 18, color: p.brand)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FollowerProgressBar(followers: player.followers),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(sessionProvider.notifier).newGame();
                  context.go('/landing');
                },
                icon: const Icon(Icons.replay, size: 19),
                label: const Text('MAIN LAGI'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rankLabel(int i) {
    switch (i) {
      case 0:
        return '01';
      case 1:
        return '02';
      case 2:
        return '03';
      default:
        return '${i + 1}'.padLeft(2, '0');
    }
  }
}
