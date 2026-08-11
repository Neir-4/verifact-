import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/session_provider.dart';
import '../../providers/card_database_provider.dart';

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
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
        continue;
      }

      _processedIds.add(cardId);
      ref.read(sessionProvider.notifier).addScannedCard(card);

      final session = ref.read(sessionProvider);
      final needed = session.currentTurn.cardCount;
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
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final turn = session.currentTurn;
    final scanned = turn.scannedCards.length;
    final needed = turn.cardCount;

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
          // Viewfinder overlay
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFABD2FB),
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Bottom info
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF080516).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF162D93)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Scan QR di balik kartu',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(needed, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < scanned
                              ? Colors.green.shade400
                              : Colors.white24,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$scanned dari $needed kartu',
                    style: const TextStyle(
                      color: Color(0xFFABD2FB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Manual entry fallback
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showManualEntry(context),
                    icon: const Icon(Icons.keyboard, color: Color(0xFFABD2FB)),
                    label: const Text(
                      'Masukkan ID Manual',
                      style: TextStyle(color: Color(0xFFABD2FB)),
                    ),
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
        backgroundColor: const Color(0xFF1A1953),
        title: const Text('Masukkan ID Kartu',
            style: TextStyle(color: Color(0xFFFDF9F1))),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Color(0xFFFDF9F1)),
          decoration: const InputDecoration(
            hintText: 'contoh: S01',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: Colors.white60)),
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
