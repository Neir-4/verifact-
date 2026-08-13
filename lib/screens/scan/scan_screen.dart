import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../providers/card_database_provider.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final Set<String> _processedIds = {};
  bool _scanning = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!_scanning) return;
    final p = context.palette;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;

      final cardId = raw.trim().toUpperCase();
      if (_processedIds.contains(cardId)) continue;

      final repo = ref.read(cardRepositoryProvider).valueOrNull;
      final card = repo?.findById(cardId);

      if (card == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kartu "$cardId" tidak ditemukan'),
            backgroundColor: p.crimson,
            duration: const Duration(seconds: 2),
          ),
        );
        continue;
      }

      _processedIds.add(cardId);
      ref.read(sessionProvider.notifier).addScannedCard(card);

      final session = ref.read(sessionProvider);
      const needed = kCardsPerTurn;
      final scanned = session.currentTurn.scannedCards.length;

      if (scanned >= needed) {
        setState(() => _scanning = false);
        _controller.stop();
        ref.read(sessionProvider.notifier).advanceToReveal();
        context.go('/reveal');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✓ ${card.id} discan. Scan ${needed - scanned} kartu lagi.'),
            backgroundColor: p.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final session = ref.watch(sessionProvider);
    final turn = session.currentTurn;
    final scanned = turn.scannedCards.length;
    const needed = kCardsPerTurn;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Scan Kartu ($scanned/$needed)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          // HUD corner-bracket viewfinder
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: _ViewfinderBrackets(color: p.accent),
            ),
          ),
          // Bottom info
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.bandDeep.withValues(alpha: 0.92),
                border: Border.all(color: p.brand),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scan QR di balik kartu',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(needed, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        color: i < scanned ? p.success : Colors.white24,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$scanned dari $needed kartu',
                    style: context.mono(fontSize: 13, color: p.accent),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showManualEntry(context),
                    icon: Icon(Icons.keyboard, color: p.accent, size: 18),
                    label: Text('Masukkan ID Manual',
                        style: TextStyle(color: p.accent)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntry(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Masukkan ID Kartu'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'contoh: S01'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleBarcode(
                BarcodeCapture(
                  barcodes: [
                    Barcode(
                      rawValue: controller.text.trim().toUpperCase(),
                      format: BarcodeFormat.qrCode,
                    ),
                  ],
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderBrackets extends StatelessWidget {
  final Color color;
  const _ViewfinderBrackets({required this.color});

  @override
  Widget build(BuildContext context) {
    const len = 28.0;
    const thick = 3.0;
    Widget corner({required bool right, required bool bottom}) {
      return Positioned(
        left: right ? null : 0,
        right: right ? 0 : null,
        top: bottom ? null : 0,
        bottom: bottom ? 0 : null,
        child: SizedBox(
          width: len,
          height: len,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: bottom ? null : 0,
                bottom: bottom ? 0 : null,
                child: Container(height: thick, color: color),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: right ? null : 0,
                right: right ? 0 : null,
                child: Container(width: thick, color: color),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        corner(right: false, bottom: false),
        corner(right: true, bottom: false),
        corner(right: false, bottom: true),
        corner(right: true, bottom: true),
      ],
    );
  }
}
