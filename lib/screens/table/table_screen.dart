import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../widgets/countdown_timer.dart';

class TableScreen extends ConsumerStatefulWidget {
  const TableScreen({super.key});

  @override
  ConsumerState<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends ConsumerState<TableScreen> {
  String? _selectedAccuserId;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);
    final turn = session.currentTurn;
    final uploader = session.currentUploader;

    return Scaffold(
      backgroundColor: const Color(0xFF080516),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1953),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF162D93), width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_tethering,
                        color: Color(0xFFABD2FB), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'CAUGHT!',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFDF9F1),
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    // Turn counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Giliran ${session.turnCount + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // End game button
                    IconButton(
                      icon: const Icon(Icons.flag_outlined,
                          color: Colors.red),
                      onPressed: _confirmEndGame,
                      tooltip: 'Selesaikan Permainan',
                    ),
                  ],
                ),
              ),
            ),

            // ── Uploader Banner ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF162D93), Color(0xFF1A1953)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF162D93).withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFABD2FB).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        uploader.name.isNotEmpty
                            ? uploader.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFABD2FB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UPLOADER GILIRAN INI',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFABD2FB),
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            uploader.name,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFDF9F1),
                            ),
                          ),
                          if (uploader.shadowbanned)
                            const Text(
                              '⚠ SHADOWBANNED — poin ÷2',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Phase: Upload ─────────────────────────────────────────────
            if (turn.phase == TurnPhase.upload)
              SliverToBoxAdapter(
                child: _buildUploadPhase(session, notifier),
              ),

            // ── Phase: Fact-Check ─────────────────────────────────────────
            if (turn.phase == TurnPhase.factCheck)
              SliverToBoxAdapter(
                child: _buildFactCheckPhase(session, notifier),
              ),

            // ── Phase: Echo Chamber ───────────────────────────────────────
            if (turn.phase == TurnPhase.echoChamber)
              SliverToBoxAdapter(
                child: _buildEchoChamberPhase(session, notifier),
              ),

            // ── Phase: Ready to scan ──────────────────────────────────────
            if (turn.phase == TurnPhase.scanning)
              SliverToBoxAdapter(
                child: _buildScanPhase(context),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }

  // ── Upload Phase ──────────────────────────────────────────────────────────

  Widget _buildUploadPhase(GameSession session, SessionNotifier notifier) {
    final turn = session.currentTurn;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('LANGKAH 1 — KLAIM UPLOADER'),
          const SizedBox(height: 12),
          // Claim buttons
          Row(
            children: [
              Expanded(
                child: _claimButton(
                  label: '📋 FAKTA',
                  selected: turn.uploaderClaim == UploaderClaim.fact,
                  color: const Color(0xFF162D93),
                  onTap: () =>
                      notifier.setUploaderClaim(UploaderClaim.fact),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _claimButton(
                  label: '❌ HOAKS',
                  selected: turn.uploaderClaim == UploaderClaim.hoax,
                  color: const Color(0xFFC0392B),
                  onTap: () =>
                      notifier.setUploaderClaim(UploaderClaim.hoax),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Card count
          _sectionLabel('JUMLAH KARTU DIUNGGAH'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _countButton(
                  count: 1,
                  selected: turn.cardCount == 1,
                  onTap: () => notifier.setCardCount(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _countButton(
                  count: 2,
                  selected: turn.cardCount == 2,
                  onTap: () => notifier.setCardCount(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Proceed button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: turn.uploaderClaim != null
                  ? () => notifier.advanceToFactCheck()
                  : null,
              icon: const Icon(Icons.timer_outlined),
              label: Text(
                'MULAI FACT-CHECK TIMER',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800, letterSpacing: 1),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Fact-Check Phase ──────────────────────────────────────────────────────

  Widget _buildFactCheckPhase(GameSession session, SessionNotifier notifier) {
    final otherPlayers = session.players
        .where((p) => p.id != session.currentUploader.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('LANGKAH 2 — FACT-CHECK!'),
          const SizedBox(height: 8),
          const Text(
            'Pemain lain punya 5 detik. Ketuk meja dan bilang "Fact-Check!" untuk curiga.',
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          Center(
            child: CountdownTimer(
              key: const ValueKey('factcheck_timer'),
              seconds: 5,
              onExpire: () {
                if (mounted) notifier.skipFactCheck();
              },
            ),
          ),
          const SizedBox(height: 28),
          _sectionLabel('SIAPA PENUDUH? (jika ada)'),
          const SizedBox(height: 12),
          ...otherPlayers.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: _selectedAccuserId == p.id
                      ? Colors.orange.shade900.withValues(alpha: 0.3)
                      : const Color(0xFF1A1953),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF162D93),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFABD2FB),
                      ),
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(
                        color: Color(0xFFFDF9F1),
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: _selectedAccuserId == p.id
                      ? const Icon(Icons.check_circle,
                          color: Colors.orange)
                      : const Icon(Icons.radio_button_unchecked,
                          color: Colors.white30),
                  onTap: () {
                    setState(() {
                      _selectedAccuserId =
                          _selectedAccuserId == p.id ? null : p.id;
                    });
                  },
                ),
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => notifier.skipFactCheck(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white60,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Tidak ada Fact-Check'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedAccuserId != null
                      ? () {
                          notifier.callFactCheck(_selectedAccuserId!);
                          setState(() => _selectedAccuserId = null);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'FACT-CHECK!',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Echo Chamber Phase ────────────────────────────────────────────────────

  Widget _buildEchoChamberPhase(
      GameSession session, SessionNotifier notifier) {
    final uploader = session.currentUploader;
    final accuserId = session.currentTurn.accuserId;
    final echoPlayers = session.players
        .where((p) => p.id != uploader.id && p.id != accuserId)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('LANGKAH 3 — ECHO CHAMBER'),
          const SizedBox(height: 8),
          const Text(
            'Pemain lain pilih sikap: Repost (bela Uploader) atau Report (bela Penuduh)',
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (echoPlayers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1953),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Tidak ada pemain lain yang bisa ikut Echo Chamber.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ...echoPlayers.map((p) {
            final choice = session.currentTurn.echoChoices[p.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1953),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF162D93),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFABD2FB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.name,
                        style: const TextStyle(
                            color: Color(0xFFFDF9F1),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Repost button
                    _echoButton(
                      label: 'REPOST',
                      icon: Icons.repeat,
                      color: Colors.green.shade700,
                      selected: choice == EchoChoice.repost,
                      onTap: () => notifier.setEchoChoice(
                          p.id, EchoChoice.repost),
                    ),
                    const SizedBox(width: 8),
                    // Report button
                    _echoButton(
                      label: 'REPORT',
                      icon: Icons.flag,
                      color: Colors.red.shade700,
                      selected: choice == EchoChoice.report,
                      onTap: () => notifier.setEchoChoice(
                          p.id, EchoChoice.report),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => notifier.advanceToScanning(),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(
                'LANJUT — SCAN KARTU',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800, letterSpacing: 1),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Scan Phase ────────────────────────────────────────────────────────────

  Widget _buildScanPhase(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _sectionLabel('LANGKAH 4 — CEK FAKTA'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1953),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_scanner,
                    size: 60, color: Color(0xFFABD2FB)),
                const SizedBox(height: 16),
                const Text(
                  'Scan QR di balik kartu untuk\nmengungkap kebenaran',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/scan'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      'BUKA KAMERA',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFABD2FB),
          letterSpacing: 2.5,
        ),
      );

  Widget _claimButton({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : color,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _countButton({
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF162D93)
              : const Color(0xFF1A1953),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFFABD2FB)
                : Colors.white24,
          ),
        ),
        child: Center(
          child: Text(
            '$count Kartu',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: selected
                  ? const Color(0xFFFDF9F1)
                  : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _echoButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmEndGame() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1953),
        title: const Text(
          'Selesaikan Permainan?',
          style: TextStyle(color: Color(0xFFFDF9F1)),
        ),
        content: const Text(
          'Pastikan deck sudah habis dan ada pemain yang tangannya kosong. Ini tidak bisa di-undo.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sessionProvider.notifier).endGame();
              context.go('/end');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }
}
