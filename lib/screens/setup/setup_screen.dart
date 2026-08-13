import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/session_provider.dart';
import '../../theme/palette.dart';
import '../../theme/app_theme.dart';
import '../../widgets/broadcast/masthead.dart';
import '../../widgets/broadcast/section_band.dart';
import '../../widgets/broadcast/ruled_list.dart';

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
    final mode = ref.read(pendingGameModeProvider);
    ref.read(sessionProvider.notifier).startNewSession(names, mode);
    context.go('/table');
  }

  String get _modeLabel {
    final mode = ref.watch(pendingGameModeProvider);
    return mode.name[0].toUpperCase() + mode.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.canvas,
      appBar: AppMasthead(
        sectionTitle: 'Setup Sesi',
        showBack: true,
        onBack: () => context.go('/landing'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Masukkan nama pemain', style: context.title),
                    const SizedBox(height: 4),
                    Text(
                      '3–5 pemain • Mode $_modeLabel • Mulai dari 200 Followers',
                      style: context.bodySoft.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    const SectionBand(label: 'Daftar pemain'),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      RuledPanel(
                        children: _controllers.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final ctrl = entry.value;
                          return RuledRow(
                            padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  color: p.surface2,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${idx + 1}',
                                    style: context.mono(
                                      fontSize: 14,
                                      color: p.brand,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: ctrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: context.body,
                                    decoration: InputDecoration(
                                      hintText: 'Nama Pemain ${idx + 1}',
                                      isDense: true,
                                      filled: false,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Nama tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (_controllers.length > _minPlayers)
                                  IconButton(
                                    onPressed: () => _removePlayer(idx),
                                    icon: Icon(Icons.close,
                                        size: 18, color: p.crimson),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      if (_controllers.length < _maxPlayers)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _addPlayer,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('TAMBAH PEMAIN'),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _start,
                          child: _loading
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: p.bandInk,
                                  ),
                                )
                              : const Text('MULAI PERMAINAN'),
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
