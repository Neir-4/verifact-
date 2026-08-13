import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/session_provider.dart';
import '../../services/persistence_service.dart';
import '../../theme/palette.dart';
import '../../theme/brand_mark.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markScale;
  late final Animation<double> _markFade;
  late final Animation<double> _wordFade;
  late final Animation<double> _tagFade;
  late final Animation<double> _ruleWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _markScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );
    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _wordFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.62, curve: Curves.easeOut),
    );
    _tagFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.46, 0.76, curve: Curves.easeOut),
    );
    _ruleWidth = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.58, 1.0, curve: Curves.easeOutCubic),
    );

    _boot();
  }

  Future<void> _boot() async {
    final results = await Future.wait([
      PersistenceService.create(),
      Future.delayed(const Duration(milliseconds: 1300)),
    ]);
    final persistence = results[0] as PersistenceService;
    ref.read(sessionProvider.notifier).init(persistence);

    if (!mounted) return;
    final session = ref.read(sessionProvider);
    context.go(session.isStarted ? '/table' : '/landing');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = AppPalette.dark;
    return Scaffold(
      backgroundColor: bg.bandDeep,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: HatchPainter(color: bg.bandInk, opacity: 0.035),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: _markFade.value,
                      child: Transform.scale(
                        scale: 0.6 + (0.4 * _markScale.value),
                        child: BrandMark(size: 56, color: bg.accent),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: _wordFade.value,
                      child: Text(
                        'VERIFACT',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: bg.bandInk,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: _tagFade.value,
                      child: Text(
                        'COMPANION WASIT DIGITAL',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: bg.accent,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.center,
                        widthFactor: _ruleWidth.value,
                        child: Container(
                          width: 120,
                          height: 2,
                          color: bg.brand,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
