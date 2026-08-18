import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

/// A ticking mm:ss pill showing time elapsed since [since]. Ticks locally
/// off a 1s `Timer` — spec §7 "no per-second updates pushed to it" is about
/// the ambient/native surface, but the same reasoning applies here: nothing
/// external drives this, it just reads the clock.
///
/// Styled after screens.html's `.pill` on the session header: accent-bg
/// background, accent-ink mono text.
class ElapsedPill extends StatefulWidget {
  const ElapsedPill({super.key, required this.since});

  final DateTime since;

  @override
  State<ElapsedPill> createState() => _ElapsedPillState();
}

class _ElapsedPillState extends State<ElapsedPill> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = DateTime.now().difference(widget.since);
    final text = '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: monoStyle(fontSize: 12, color: AppColors.accentInk)),
    );
  }
}
