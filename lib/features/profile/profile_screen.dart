import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.tealBg,
              child: Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
              child: Text(user.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800))),
          Center(
              child: Text(user.email,
                  style: const TextStyle(color: AppColors.mute))),
          const SizedBox(height: 8),
          Center(child: StatusChip(user.role.label, tone: ChipTone.good)),
          const SizedBox(height: 24),
          const Text('Skills', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          user.skills.isEmpty
              ? const Text('No skills added yet.',
                  style: TextStyle(color: AppColors.mute))
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final s in user.skills) StatusChip(s)]),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => ref.read(authProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
