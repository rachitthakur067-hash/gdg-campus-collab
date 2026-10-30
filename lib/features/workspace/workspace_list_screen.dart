import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/app_user.dart';
import '../../models/project.dart';
import '../auth/auth_provider.dart';
import 'workspace_providers.dart';

/// Tab for students and clients: every project that has an active workspace.
class WorkspaceListScreen extends ConsumerWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClient = ref.watch(authProvider)?.role == UserRole.client;
    final list = ref.watch(myWorkspacesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Workspace')),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(myWorkspacesProvider),
            child: const Text('Could not load workspaces. Tap to retry.'),
          ),
        ),
        data: (projects) => projects.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                      isClient
                          ? 'Accept an applicant and the project workspace opens here.'
                          : 'Once a client accepts your team, your project workspace appears here.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.mute)),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(myWorkspacesProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: projects.length,
                  itemBuilder: (_, i) {
                    final p = projects[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push('/workspace/${p.id}'),
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
                              Row(children: [
                                Expanded(
                                    child: Text(p.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15))),
                                StatusChip(p.status.label,
                                    tone: p.status == ProjectStatus.closed
                                        ? ChipTone.neutral
                                        : ChipTone.good),
                              ]),
                              const SizedBox(height: 2),
                              Text(
                                  '${p.clientName} · Due ${DateFormat('d MMM yyyy').format(p.deadline)}',
                                  style: const TextStyle(
                                      color: AppColors.mute, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
