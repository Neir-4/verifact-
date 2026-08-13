import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class RulesScreen extends StatefulWidget {
  final bool showBackButton;
  const RulesScreen({super.key, this.showBackButton = false});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  int _expandedIndex = -1;

  final List<_RuleSection> _sections = const [
    _RuleSection(
      icon: Icons.info_outline,
      title: 'Tentang VERIFACT',
      content:
          'VERIFACT adalah permainan kartu bluffing fisik bertema ekosistem media sosial untuk 3–5 pemain. '
          'Aplikasi ini bertindak sebagai wasit digital: memindai kode QR kartu, melacak Followers, dan mengelola reputasi Jejak Digital pemain.',
    ),
    _RuleSection(
      icon: Icons.people_outline,
      title: 'Komponen Permainan',
      content:
          '• 50 Kartu Informasi: 25 Fakta, 25 Hoaks (dilengkapi QR Code di belakang).\n'
          '• Kartu Intervensi Netizen: REPOST (hijau) & REPORT (merah).\n'
          '• Kartu Profil: Pelacak Followers (0-600) dengan klip.\n'
          '• Shadowbanned: Status hukuman jika Followers mencapai 0.\n'
          '• Papan Utama: Tempat menaruh kartu yang sedang diunggah.\n'
          '• Aplikasi VERIFACT: Wasit pemindai QR & pengelola sesi.',
    ),
    _RuleSection(
      icon: Icons.brightness_low_outlined,
      title: 'Persiapan Bermain (Setup)',
      content:
          '1. Setiap pemain mengambil 1 Kartu Profil, set Followers ke 200 (modal awal).\n'
          '2. Tulis nama akun/persona pada Kartu Profil.\n'
          '3. Ambil sepasang Kartu Intervensi (REPOST & REPORT).\n'
          '4. Kocok 50 Kartu Informasi, bagikan 5 kartu tertutup ke tiap pemain. Sisanya menjadi Deck.\n'
          '5. Letakkan HP dengan aplikasi VERIFACT di tengah meja.',
    ),
    _RuleSection(
      icon: Icons.play_circle_outline,
      title: 'Alur Giliran',
      content:
          '• Langkah 1: Unggah\n'
          '  Uploader menaruh 1-2 kartu tertutup di meja & mengklaim statusnya (Fakta/Hoaks).\n\n'
          '• Langkah 2: Repost / Report\n'
          '  Pemain lain memilih sikap secara rahasia: REPOST (setuju klaim) atau REPORT (melaporkan klaim salah).\n\n'
          '• Langkah 3: Cek Fakta\n'
          '  Pindai kode QR semua kartu di aplikasi. Jika semua kartu cocok dengan klaim, Uploader jujur. Jika ada 1 saja meleset, klaim dianggap bohong.\n\n'
          '• Langkah 4: Ambil Kartu\n'
          '  Uploader menarik kartu baru dari Deck hingga berjumlah 5 di tangan. Giliran berputar.',
    ),
    _RuleSection(
      icon: Icons.calculate_outlined,
      title: 'Perolehan Poin (Followers)',
      content:
          'UPLOADER JUJUR (Klaim cocok dengan kartu):\n'
          '• Uploader:\n'
          '  - Jika dilaporkan (minimal 1 Report): +20 / kartu\n'
          '  - Jika tidak dilaporkan (0 Report): +10 / kartu\n'
          '• Pemain Lain:\n'
          '  - Repost (Setuju): +10 | Report (Laporkan): -10\n\n'
          'UPLOADER BOHONG (Klaim tidak cocok):\n'
          '• Uploader:\n'
          '  - Jika dilaporkan (minimal 1 Report): -30 / kartu\n'
          '  - Jika tidak dilaporkan (0 Report): +20 / kartu\n'
          '• Pemain Lain:\n'
          '  - Report (Laporkan): +10 | Repost (Setuju): -10',
    ),
    _RuleSection(
      icon: Icons.visibility_off_outlined,
      title: 'Status Shadowbanned',
      content:
          '• Terjadi jika Followers pemain turun hingga 0.\n'
          '• Pemain tetap dapat bermain normal.\n'
          '• Efek: Semua penambahan Followers dari kemenangan klaim dipotong setengah (dibulatkan ke bawah).\n'
          '• Status hilang otomatis setelah Followers mencapai ≥50 kembali.',
    ),
    _RuleSection(
      icon: Icons.flag_outlined,
      title: 'Akhir Permainan & Pemenang',
      content:
          '• Permainan berakhir jika Deck habis DAN salah satu pemain kehabisan kartu di tangan.\n'
          '• Pahlawan Literasi: Pemain dengan Jejak Digital terbersih (lebih banyak kartu jujur/kredibel vs bohong/pelanggaran).\n'
          '• Raja Buzzer / Penguasa Algoritma: Pemain dengan Jejak Digital pelanggaran terbanyak.\n'
          '• Jika terjadi seri pada Jejak Digital, pemenang ditentukan dari jumlah Followers terbanyak.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080516),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showBackButton) ...[
                      IconButton(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFABD2FB)),
                        onPressed: () => context.go('/landing'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'PANDUAN',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFABD2FB),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cara Bermain',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFDF9F1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Semua aturan VERIFACT dalam genggaman',
                      style:
                          TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final section = _sections[i];
                  final isExpanded = _expandedIndex == i;
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? const Color(0xFF1A1953)
                          : const Color(0xFF100D2B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isExpanded
                            ? const Color(0xFF162D93)
                            : Colors.white12,
                        width: isExpanded ? 1.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? -1 : i;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(section.icon,
                                    color: const Color(0xFFABD2FB), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    section.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFDF9F1),
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white38,
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(48, 0, 14, 14),
                              child: Text(
                                section.content,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.65,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _sections.length,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
}

class _RuleSection {
  final IconData icon;
  final String title;
  final String content;

  const _RuleSection({
    required this.icon,
    required this.title,
    required this.content,
  });
}
