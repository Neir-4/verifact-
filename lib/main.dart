import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/session_provider.dart';
import 'services/persistence_service.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load persistence before starting app
  final persistence = await PersistenceService.create();

  runApp(
    ProviderScope(
      child: CaughtApp(persistence: persistence),
    ),
  );
}

class CaughtApp extends ConsumerStatefulWidget {
  final PersistenceService persistence;
  const CaughtApp({super.key, required this.persistence});

  @override
  ConsumerState<CaughtApp> createState() => _CaughtAppState();
}

class _CaughtAppState extends ConsumerState<CaughtApp> {
  @override
  void initState() {
    super.initState();
    // Initialize session with persistence after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).init(widget.persistence);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'CAUGHT!',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF162D93);
    const bgColor = Color(0xFF080516);
    const surfaceColor = Color(0xFF1A1953);
    const onSurface = Color(0xFFFDF9F1);

    final base = GoogleFonts.outfitTextTheme();

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        onSurface: onSurface,
      ),
      textTheme: base.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryColor.withValues(alpha: 0.6),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFFABD2FB));
          }
          return const IconThemeData(color: Colors.white38);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: TextStyle(color: onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }
}
