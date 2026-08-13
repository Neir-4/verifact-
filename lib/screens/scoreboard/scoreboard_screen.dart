import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/session_provider.dart';
import '../../services/score_calculator.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';
import '../../widgets/broadcast/masthead.dart';
import '../../widgets/broadcast/section_band.dart';
import '../../widgets/broadcast/ruled_list.dart';
import '../../widgets/player_card_widget.dart';

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final session = ref.watch(sessionProvider);
    final sorted = ScoreCalculator.sortByFollowers(session.players);
    final uploader = session.currentUploader;

    return Scaffold(
      backgroundColor: p.canvas,
      appBar: const AppMasthead(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text('Live Followers', style: context.title),
            const SizedBox(height: 4),
            Text(
              '${session.players.length} pemain • Giliran ${session.turnCount + 1}',
              style: context.bodySoft.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 18),
            const SectionBand(label: 'Papan skor'),
            const SizedBox(height: 14),
            RuledPanel(
              children: sorted.asMap().entries.map((entry) {
                final i = entry.key;
                final player = entry.value;
                return RuledRow(
                  padding: const EdgeInsets.all(14),
                  background: player.id == uploader.id
                      ? p.brand.withValues(alpha: 0.06)
                      : null,
                  child: PlayerCardWidget(
                    player: player,
                    rank: i + 1,
                    isUploader: player.id == uploader.id,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const SectionBand(label: 'Jejak digital'),
            const SizedBox(height: 10),
            Text(
              'Jejak Digital mencerminkan kejujuran pemain sepanjang permainan. '
              'Pemenang ditentukan dari siapa yang memiliki Jejak Digital paling bersih.',
              style: context.bodySoft.copyWith(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.surface,
                border: Border(left: BorderSide(color: p.warning, width: 3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility_off, color: p.warning, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Shadowbanned: Saat Followers = 0, semua gain dibagi 2 sampai mencapai 50.',
                      style: context.bodySoft.copyWith(fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
