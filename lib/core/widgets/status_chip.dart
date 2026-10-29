import 'package:flutter/material.dart';

import '../theme.dart';

enum ChipTone { neutral, good, warn, bad }

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.tone = ChipTone.neutral});

  final String label;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      ChipTone.good => (AppColors.tealBg, AppColors.teal),
      ChipTone.warn => (AppColors.amberBg, AppColors.amber),
      ChipTone.bad => (AppColors.redBg, AppColors.red),
      ChipTone.neutral => (const Color(0xFFE8ECF1), AppColors.mute),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
