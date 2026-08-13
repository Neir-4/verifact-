import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/app_theme.dart';

class CountdownTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onExpire;
  final VoidCallback? onTick;

  const CountdownTimer({
    super.key,
    this.seconds = 5,
    required this.onExpire,
    this.onTick,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      widget.onTick?.call();
      if (_remaining <= 0) {
        t.cancel();
        widget.onExpire();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isUrgent = _remaining <= 2;
    final color = isUrgent ? p.crimson : p.accent;
    final progress = _remaining / widget.seconds;

    return AnimatedBuilder(
      animation: isUrgent ? _pulse : const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Transform.scale(
          scale: isUrgent ? _pulse.value : 1.0,
          child: SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 6,
                    backgroundColor: p.line,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '$_remaining',
                  style: context.mono(fontSize: 36, color: color, letterSpacing: -2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
