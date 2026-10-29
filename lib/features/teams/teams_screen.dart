import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import 'team_providers.dart';

/// Student tab: the teams I belong to.
class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(myTeamsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My teams')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-team'),
        icon: const Icon(Icons.add),
        label: const Text('New team'),
      ),
      body: teams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(myTeamsProvider),
            child: const Text('Could not load teams. Tap to retry.'),
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                      'No teams yet. Create one and add your friends by email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mute)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final t = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/team/${t.id}'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${t.members.length} members',
                                style: const TextStyle(
                                    color: AppColors.mute, fontSize: 12)),
                            const SizedBox(height: 8),
                            Wrap(spacing: 6, runSpacing: 6, children: [
                              for (final s in t.skills) StatusChip(s),
                            ]),
                          ],
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
