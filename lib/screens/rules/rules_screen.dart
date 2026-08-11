import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  int _expandedIndex = -1;

  final List<_RuleSection> _sections = const [
    _RuleSection(
      icon: Icons.info_outline,
      title: 'Tentang CAUGHT!',
      content:
          'CAUGHT! adalah permainan kartu fisik bertema literasi media sosial untuk 3–5 pemain. '
          'Aplikasi ini berfungsi sebagai wasit digital: scan QR di kartu, hitung skor otomatis, dan lacak profil tiap pemain.',
    ),
    _RuleSection(
      icon: Icons.people_outline,
      title: 'Komponen & Peran',
      content:
          '• 50 Kartu Konten (S01–S48) berisi berita Fakta, Hoaks, atau Opini\n'
          '• Setiap pemain mulai dengan 200 Followers\n'
          '• Uploader: memainkan kartu & mengklaim statusnya\n'
          '• Penuduh: menyerukan "Fact-Check!" dalam 5 detik\n'
          '• Echo Chamber: pemain lain pilih Repost atau Report',
    ),
    _RuleSection(
      icon: Icons.play_circle_outline,
      title: 'Alur Giliran',
      content:
          '1. Uploader pilih klaim (Fakta/Hoaks) dan jumlah kartu (1–2)\n'
          '2. Kartu ditaruh tertutup di meja\n'
          '3. Timer 5 detik: Pemain lain bisa menyerukan "Fact-Check!"\n'
          '4. Jika ada Fact-Check: pilih Penuduh, lalu Echo Chamber\n'
          '5. Scan QR kartu untuk mengungkap kebenaran\n'
          '6. Hitung skor otomatis\n'
          '7. Giliran berpindah ke kiri',
    ),
    _RuleSection(
      icon: Icons.calculate_outlined,
      title: 'Tabel Poin',
      content:
          'LOLOS (tidak ada Fact-Check):\n'
          '• Uploader jujur (klaim cocok): +10/kartu\n'
          '• Uploader bluff berhasil: +20/kartu\n\n'
          'DITANTANG (ada Fact-Check):\n'
          '• Uploader jujur: Uploader +20/kartu; Penuduh -10/kartu\n'
          '  - Repost: +10 | Report: -10\n'
          '• Uploader TERTANGKAP: Uploader -30/kartu; Penuduh +30/kartu +5\n'
          '  - Repost: -10 | Report: +10',
    ),
    _RuleSection(
      icon: Icons.visibility_off_outlined,
      title: 'Shadowban',
      content:
          'Jika Followers mencapai 0, pemain masuk status SHADOWBANNED:\n'
          '• Semua poin gain dibagi 2 (dibulatkan ke bawah)\n'
          '• Status hilang otomatis saat Followers kembali ke ≥50\n'
          '• Poin negatif tetap berlaku penuh',
    ),
    _RuleSection(
      icon: Icons.history_edu_outlined,
      title: 'Jejak Digital',
      content:
          'Setiap kartu yang dimainkan Uploader dicatat di Jejak Digital:\n'
          '• Kartu jujur → Jejak Jujur (✓)\n'
          '• Kartu bohong → Jejak Bohong (✗)\n\n'
          'Pemenang akhir ditentukan dari yang memiliki Jejak Digital paling bersih (lebih banyak ✓ vs ✗)',
    ),
    _RuleSection(
      icon: Icons.flag_outlined,
      title: 'Kondisi Menang',
      content:
          'Permainan berakhir saat:\n'
          '• Deck habis, ATAU\n'
          '• Satu pemain tangannya kosong\n\n'
          'Pemenang = pemain dengan Jejak Digital paling bersih.\n'
          'Seri diselesaikan dengan Followers terbanyak.',
    ),
    _RuleSection(
      icon: Icons.qr_code_outlined,
      title: 'Cara Scan Kartu',
      content:
          '1. Buka tab "Permainan"\n'
          '2. Setelah Echo Chamber, ketuk "BUKA KAMERA"\n'
          '3. Arahkan kamera ke QR code di balik kartu\n'
          '4. Scan semua kartu sesuai jumlah yang dimainkan\n'
          '5. Artikel & sumber akan muncul otomatis\n\n'
          'QR code berisi ID kartu (contoh: S01). Jika kamera bermasalah, gunakan entri manual.',
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
                      'Semua aturan CAUGHT! dalam genggaman',
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
