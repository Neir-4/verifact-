import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/session_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final List<TextEditingController> _controllers = [];
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  static const _minPlayers = 3;
  static const _maxPlayers = 5;

  @override
  void initState() {
    super.initState();
    // Start with 3 empty name fields
    for (int i = 0; i < _minPlayers; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    if (_controllers.length >= _maxPlayers) return;
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removePlayer(int index) {
    if (_controllers.length <= _minPlayers) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  void _start() {
    if (!_formKey.currentState!.validate()) return;
    final names = _controllers.map((c) => c.text.trim()).toList();
    setState(() => _loading = true);
    ref.read(sessionProvider.notifier).startNewSession(names);
    context.go('/table');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080516),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo / Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF162D93),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.wifi_tethering,
                              color: Color(0xFFABD2FB), size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VERIFACT',
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFDF9F1),
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              'COMPANION APP',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFABD2FB),
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Setup Card
                    Text(
                      'SETUP SESI',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFABD2FB),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan nama pemain',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFDF9F1),
                      ),
                    ),
                    Text(
                      '3–5 pemain • Mulai dari 200 Followers',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ..._controllers.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final ctrl = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              // Player number badge
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1953),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFABD2FB),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: ctrl,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFDF9F1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Nama Pemain ${idx + 1}',
                                    hintStyle: const TextStyle(
                                        color: Colors.white30),
                                    filled: true,
                                    fillColor: const Color(0xFF1A1953),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF162D93), width: 2),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Nama tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (_controllers.length > _minPlayers) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _removePlayer(idx),
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      // Add player button
                      if (_controllers.length < _maxPlayers)
                        TextButton.icon(
                          onPressed: _addPlayer,
                          icon: const Icon(Icons.add,
                              color: Color(0xFFABD2FB)),
                          label: Text(
                            'Tambah Pemain',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFABD2FB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Start button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _start,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF162D93),
                            foregroundColor: const Color(0xFFFDF9F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : Text(
                                  'MULAI PERMAINAN',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
