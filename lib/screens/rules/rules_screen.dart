import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/session_model.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';
import '../../widgets/broadcast/masthead.dart';
import '../../widgets/broadcast/ruled_list.dart';

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
          'Aplikasi ini bertindak sebagai wasit digital: memindai kode QR kartu, melacak Followers, dan mengelola reputasi Jejak Digital pemain.\n\n'
          'Dua mode: Classic (menang duluan kalau Jejak Jujur capai $kClassicWinThreshold) atau Handless (main sampai kartu habis, Followers tertinggi menang). Dipilih sebelum Setup.',
    ),
    _RuleSection(
      icon: Icons.people_outline,
      title: 'Komponen Permainan',
      content:
          '• 48 Kartu Informasi: 24 Fakta, 24 Hoaks (dilengkapi QR Code di belakang).\n'
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
          '3. Ambil sepasang Kartu Intervensi (REPOST & REPORT) — dipakai hanya saat giliran sendiri.\n'
          '4. Kocok 48 Kartu Informasi, bagikan 5 kartu tertutup ke tiap pemain. Sisanya menjadi Deck.\n'
          '5. Letakkan HP dengan aplikasi VERIFACT di tengah meja.',
    ),
    _RuleSection(
      icon: Icons.play_circle_outline,
      title: 'Alur Giliran',
      content:
          '• Langkah 1: Unggah & Taruhan\n'
          '  Uploader menaruh 2 kartu tertutup di meja & mengklaim statusnya (Fakta/Hoaks). Di halaman yang sama, Uploader BOLEH (tidak wajib) menambahkan taruhan Kartu Intervensi milik sendiri: Repost atau Report — anggap seperti "tambah kartu" untuk taruhan ekstra.\n\n'
          '• Langkah 2: Cek Fakta atau Lewati\n'
          '  Pindai kode QR ke-2 kartu di aplikasi. Jika keduanya Fakta, racikan ini Fakta. Jika salah satu saja Hoaks, seluruh racikan dianggap Hoaks — dan jika klaim Uploader tidak cocok dengan hasil ini, Uploader dianggap bohong. Tombol LEWATI GILIRAN tersedia kalau giliran ini tidak jadi di-scan — tidak ada poin yang berubah, giliran langsung pindah.\n\n'
          '• Langkah 3: Ambil Kartu\n'
          '  Uploader menarik kartu baru dari Deck hingga berjumlah 5 di tangan. Giliran berputar.',
    ),
    _RuleSection(
      icon: Icons.calculate_outlined,
      title: 'Perolehan Poin (Followers)',
      content:
          'KLAIM UPLOADER (dasar, wajib):\n'
          '• Klaim cocok dengan racikan asli (jujur): +10 / kartu\n'
          '• Klaim tidak cocok (bohong): -20 / kartu\n\n'
          'TARUHAN REPOST / REPORT (opsional, milik Uploader sendiri — dinilai dari racikan ASLI, bukan dari klaim):\n'
          '• Repost, racikan ternyata Fakta: +15 (amplifikasi benar)\n'
          '• Repost, racikan ternyata Hoaks: -20 (ikut menyebarkan hoaks)\n'
          '• Report, racikan ternyata Hoaks: +30 (berhasil menangkap hoaks)\n'
          '• Report, racikan ternyata Fakta: -30 (salah lapor, membungkam fakta)\n\n'
          'Tidak pasang taruhan sama sekali = 0 poin tambahan, tanpa risiko. Total poin Uploader = Klaim + Taruhan (kalau ada).',
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
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.canvas,
      appBar: AppMasthead(
        sectionTitle: 'Panduan',
        showBack: widget.showBackButton,
        onBack: widget.showBackButton ? () => context.go('/landing') : null,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cara Bermain', style: context.title),
                    const SizedBox(height: 4),
                    Text(
                      'Semua aturan VERIFACT dalam genggaman',
                      style: context.bodySoft.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: RuledPanel(
                  children: _sections.asMap().entries.map((entry) {
                    final i = entry.key;
                    final section = entry.value;
                    final isExpanded = _expandedIndex == i;
                    return RuledRow(
                      padding: EdgeInsets.zero,
                      background: isExpanded ? p.surface : null,
                      onTap: () {
                        setState(() => _expandedIndex = isExpanded ? -1 : i);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(section.icon, color: p.brand, size: 21),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    section.title,
                                    style: context.body
                                        .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: p.inkSoft,
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(47, 0, 14, 16),
                              child: Text(
                                section.content,
                                style: context.bodySoft.copyWith(fontSize: 13.5, height: 1.65),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
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
