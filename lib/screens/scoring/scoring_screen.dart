import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/player_model.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../services/score_calculator.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';
import '../../widgets/broadcast/masthead.dart';
import '../../widgets/broadcast/chamfered_panel.dart';
import '../../widgets/broadcast/ruled_list.dart';

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

  String _verdictText() {
    final blendLabel = _result.blendIsFact ? 'Fakta' : 'Hoaks';
    final claimLine = _result.uploaderWasHonest
        ? 'Klaim BENAR — racikan ini $blendLabel, sesuai klaim Uploader.'
        : 'Klaim MELESET — racikan ini ternyata $blendLabel.';

    final reaction = _result.reactionPlayed;
    if (reaction == null) {
      return '$claimLine Tidak pasang taruhan Repost/Report.';
    }

    final betCorrect =
        reaction == EchoChoice.repost ? _result.blendIsFact : !_result.blendIsFact;
    final betLabel = reaction == EchoChoice.repost ? 'Repost' : 'Report';

    return '$claimLine Taruhan $betLabel ${betCorrect ? "BENAR" : "SALAH"} — poin ${betCorrect ? "bertambah" : "berkurang"}.';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: p.canvas,
      appBar: const AppMasthead(sectionTitle: 'Skor Giliran Ini'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ChamferedPanel(
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: p.brand),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _verdictText(),
                        style: context.bodySoft.copyWith(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  RuledPanel(
                    children: _result.results.map((score) {
                      final player = session.players.firstWhere(
                          (pl) => pl.id == score.playerId,
                          orElse: () =>
                              Player(id: '', name: 'Unknown', followers: 0));
                      final isUploader =
                          score.playerId == session.currentUploader.id;
                      return _ScoreRow(
                        player: player,
                        delta: score.followerDelta,
                        isUploader: isUploader,
                        shadowbannedAfter: score.shadowbannedAfter,
                        wasHalved: score.wasHalved,
                        credibleDelta: score.credibleDelta,
                        violationDelta: score.violationDelta,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
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
                  icon: const Icon(Icons.skip_next, size: 19),
                  label: const Text('GILIRAN BERIKUTNYA'),
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
    final p = context.palette;
    final isPositive = delta > 0;
    final isZero = delta == 0;
    final deltaColor = isZero ? p.inkSoft : (isPositive ? p.success : p.crimson);

    return RuledRow(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            color: p.brand.withValues(alpha: 0.14),
            alignment: Alignment.center,
            child: Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900, color: p.brand),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name,
                        overflow: TextOverflow.ellipsis,
                        style: context.body.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (isUploader) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: p.brand.withValues(alpha: 0.14),
                        child: Text(
                          'UPLOADER',
                          style: context.mono(fontSize: 9, color: p.brand),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${player.followers} Followers${shadowbannedAfter ? " • SHADOWBANNED" : ""}',
                  style: context.bodySoft.copyWith(fontSize: 12),
                ),
                if (wasHalved)
                  Text(
                    'Poin gain dibagi 2 (shadowban)',
                    style: context.mono(fontSize: 11, color: p.warning),
                  ),
                if (credibleDelta > 0 || violationDelta > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        if (credibleDelta > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 12, color: p.success),
                              const SizedBox(width: 2),
                              Text(
                                '+$credibleDelta Jejak Jujur',
                                style: TextStyle(fontSize: 11, color: p.success),
                              ),
                            ],
                          ),
                        if (violationDelta > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (credibleDelta > 0) const SizedBox(width: 8),
                              Icon(Icons.cancel_outlined,
                                  size: 12, color: p.crimson),
                              const SizedBox(width: 2),
                              Text(
                                '+$violationDelta Jejak Bohong',
                                style: TextStyle(fontSize: 11, color: p.crimson),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isZero ? '±0' : (isPositive ? '+$delta' : '$delta'),
                style: context.mono(fontSize: 22, color: deltaColor),
              ),
              Text(
                'Followers',
                style: TextStyle(
                    fontSize: 10, color: deltaColor.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
