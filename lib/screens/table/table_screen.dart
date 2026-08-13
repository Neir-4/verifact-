import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';
import '../../widgets/broadcast/masthead.dart';
import '../../widgets/broadcast/section_band.dart';
import '../../widgets/broadcast/chamfered_panel.dart';
import '../../widgets/broadcast/toggle_chip.dart';

class TableScreen extends ConsumerStatefulWidget {
  const TableScreen({super.key});

  @override
  ConsumerState<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends ConsumerState<TableScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final session = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);
    final turn = session.currentTurn;
    final uploader = session.currentUploader;

    return Scaffold(
      backgroundColor: p.canvas,
      appBar: AppMasthead(
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GILIRAN ${session.turnCount + 1}',
              style: context.mono(fontSize: 11, color: p.accent),
            ),
            IconButton(
              icon: Icon(Icons.menu, color: p.accent, size: 20),
              onPressed: () => context.go('/landing'),
              tooltip: 'Menu — permainan tetap tersimpan',
            ),
            IconButton(
              icon: Icon(Icons.flag_outlined, color: p.crimsonAccent, size: 20),
              onPressed: _confirmEndGame,
              tooltip: 'Selesaikan Permainan',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Live turn panel — the current player, at display scale ──────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ChamferedPanel(
                  color: p.band,
                  borderColor: p.brand,
                  borderWidth: 2,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        color: p.accent.withValues(alpha: 0.18),
                        alignment: Alignment.center,
                        child: Text(
                          uploader.name.isNotEmpty
                              ? uploader.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: p.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UPLOADER GILIRAN INI',
                                style: context.eyebrowOnBand),
                            const SizedBox(height: 2),
                            Text(
                              uploader.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: p.bandInk,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (uploader.shadowbanned)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'SHADOWBANNED — POIN ÷2',
                                  style: context.mono(
                                    fontSize: 11,
                                    color: p.crimsonAccent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (turn.phase == TurnPhase.upload)
              SliverToBoxAdapter(child: _buildClaimPhase(context, session, notifier)),
            if (turn.phase == TurnPhase.scanning)
              SliverToBoxAdapter(child: _buildScanPhase(context)),

            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }

  // ── Claim + optional Repost/Report bonus bet — one page, one player ─────

  Widget _buildClaimPhase(
      BuildContext context, GameSession session, SessionNotifier notifier) {
    final p = context.palette;
    final turn = session.currentTurn;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionBand(label: 'Langkah 1 — Klaim Uploader'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ToggleChip(
                  label: 'Fakta',
                  selected: turn.uploaderClaim == UploaderClaim.fact,
                  color: p.brand,
                  onTap: () => notifier.setUploaderClaim(UploaderClaim.fact),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ToggleChip(
                  label: 'Hoaks',
                  selected: turn.uploaderClaim == UploaderClaim.hoax,
                  color: p.crimson,
                  onTap: () => notifier.setUploaderClaim(UploaderClaim.hoax),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          const SectionBand(label: 'Tambah Kartu — Repost / Report (opsional)'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ToggleChip(
                  label: 'Repost',
                  icon: Icons.repeat,
                  color: p.success,
                  selected: turn.uploaderReaction == EchoChoice.repost,
                  onTap: () =>
                      notifier.toggleUploaderReaction(EchoChoice.repost),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ToggleChip(
                  label: 'Report',
                  icon: Icons.flag,
                  color: p.crimson,
                  selected: turn.uploaderReaction == EchoChoice.report,
                  onTap: () =>
                      notifier.toggleUploaderReaction(EchoChoice.report),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: turn.uploaderClaim != null
                  ? () => notifier.advanceToScanning()
                  : null,
              icon: const Icon(Icons.qr_code_scanner, size: 19),
              label: const Text('LANJUT — SCAN KARTU'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmSkipTurn,
              icon: const Icon(Icons.redo, size: 18),
              label: const Text('LEWATI GILIRAN'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Scan Phase ────────────────────────────────────────────────────────────

  Widget _buildScanPhase(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SectionBand(label: 'Langkah 2 — Cek Fakta'),
          const SizedBox(height: 16),
          ChamferedPanel(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner, size: 56, color: p.brand),
                const SizedBox(height: 16),
                Text(
                  'Scan QR di balik $kCardsPerTurn kartu untuk\nmengungkap kebenaran',
                  textAlign: TextAlign.center,
                  style: context.bodySoft.copyWith(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/scan'),
                    icon: const Icon(Icons.camera_alt, size: 19),
                    label: const Text('BUKA KAMERA'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSkipTurn() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lewati Giliran Ini?'),
        content: const Text(
          'Klaim dan taruhan giliran ini tidak akan dinilai. Giliran langsung pindah ke pemain berikutnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sessionProvider.notifier).skipTurn();
            },
            child: const Text('Lewati'),
          ),
        ],
      ),
    );
  }

  void _confirmEndGame() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesaikan Permainan?'),
        content: const Text(
          'Pastikan deck sudah habis dan ada pemain yang tangannya kosong. Ini tidak bisa di-undo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.palette.crimson,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sessionProvider.notifier).endGame();
              context.go('/end');
            },
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }
}
