import 'package:flutter/material.dart';

import '../../core/theme.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(hint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mute)),
        ),
      ),
    );
  }
}
