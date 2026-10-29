import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/application.dart';
import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import 'applicant_card.dart';
import 'application_providers.dart';

/// Student tab: the status of every application they sent.
class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(myApplicationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My applications')),
      body: apps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(myApplicationsProvider),
            child: const Text('Could not load applications. Tap to retry.'),
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                      'You have not applied yet. Open Browse and apply to a project.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mute)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final a = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/project/${a.projectId}'),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(a.projectTitle,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15)),
                                ),
                                StatusChip(a.status.label,
                                    tone: applicationTone(a.status)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                                'Applied as ${a.displayName} · ${DateFormat('d MMM').format(a.createdAt)}',
                                style: const TextStyle(
                                    color: AppColors.mute, fontSize: 12)),
                            const SizedBox(height: 8),
                            Text(a.proposal,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
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
