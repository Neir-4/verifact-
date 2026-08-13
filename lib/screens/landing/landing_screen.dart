import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/brand_mark.dart';
import '../../widgets/broadcast/chamfered_panel.dart';
import '../../widgets/broadcast/section_band.dart';
import '../../widgets/broadcast/toggle_chip.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final session = ref.watch(sessionProvider);
    final selectedMode = ref.watch(pendingGameModeProvider);

    return Scaffold(
      backgroundColor: p.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Masthead ─────────────────────────────────────────────────
              HatchedBand(
                color: p.bandDeep,
                border: Border(bottom: BorderSide(color: p.brand, width: 2)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  children: [
                    BrandMark(size: 44, color: p.accent),
                    const SizedBox(height: 18),
                    Text(
                      'VERIFACT',
                      style: context.displayLg.copyWith(
                        color: p.bandInk,
                        fontSize: 40,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'COMPANION WASIT DIGITAL',
                      style: context.eyebrowOnBand,
                    ),
                  ],
                ),
              ),
              // ── Body ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (session.isResumable) ...[
                      const SectionBand(label: 'Permainan tersimpan'),
                      const SizedBox(height: 14),
                      ChamferedPanel(
                        color: p.band,
                        borderColor: p.brand,
                        child: Row(
                          children: [
                            Icon(Icons.history, color: p.accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${session.players.length} pemain • Giliran ${session.turnCount + 1}',
                                style: TextStyle(
                                  color: p.bandInk,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/table'),
                              child: const Text('LANJUTKAN'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const SectionBand(label: 'Pilih mode'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ToggleChip(
                            label: 'Classic',
                            selected: selectedMode == GameMode.classic,
                            color: p.brand,
                            onTap: () => ref
                                .read(pendingGameModeProvider.notifier)
                                .state = GameMode.classic,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ToggleChip(
                            label: 'Handless',
                            selected: selectedMode == GameMode.handless,
                            color: p.brand,
                            onTap: () => ref
                                .read(pendingGameModeProvider.notifier)
                                .state = GameMode.handless,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () =>
                          _handleMulaiBermain(context, ref, session),
                      child: const Text('MULAI BERMAIN'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/rulebook'),
                      child: const Text('RULEBOOK PERMAINAN'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMulaiBermain(
      BuildContext context, WidgetRef ref, GameSession session) {
    if (!session.isResumable) {
      context.go('/setup');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mulai Permainan Baru?'),
        content: const Text(
          'Permainan sebelumnya belum selesai dan akan dihapus. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sessionProvider.notifier).newGame();
              context.go('/setup');
            },
            child: const Text('Mulai Baru'),
          ),
        ],
      ),
    );
  }
}
