import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080516),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // App Logo
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1953),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF162D93),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF162D93).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.wifi_tethering,
                            color: Color(0xFFABD2FB),
                            size: 72,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          'VERIFACT',
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFDF9F1),
                            letterSpacing: 2,
                          ),
                        ),
                        // Subtitle
                        Text(
                          'COMPANION WASIT DIGITAL',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFABD2FB),
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Description Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1953),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            'VERIFACT adalah aplikasi pendamping untuk permainan kartu fisik bertema literasi media sosial. Aplikasi ini berfungsi sebagai wasit digital untuk memindai kode QR kartu, melacak jumlah Followers, dan mengelola reputasi Jejak Digital pemain secara otomatis.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFFFDF9F1).withValues(alpha: 0.8),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 48),
                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => context.go('/setup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF162D93),
                              foregroundColor: const Color(0xFFFDF9F1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'MULAI BERMAIN',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => context.go('/rulebook'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFABD2FB),
                              side: const BorderSide(
                                color: Color(0xFF162D93),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'RULEBOOK PERMAINAN',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
