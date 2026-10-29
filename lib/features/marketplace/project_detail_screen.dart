import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../models/project.dart';
import '../applications/applicant_card.dart';
import '../applications/application_providers.dart';
import '../auth/auth_provider.dart';
import 'providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectByIdProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Project')),
      body: project.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Could not load this project.')),
        data: (p) => p == null
            ? const Center(child: Text('Project not found.'))
            : _Body(project: p),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.project});

  final Project project;

  Widget _section(String title, Widget child) => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            child,
          ],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final p = project;
    final isOwner = user != null && user.id == p.clientId;
    final isStudent = user?.role == UserRole.student;
    final myApps = ref.watch(myApplicationsProvider).value ?? <Application>[];
    final mine = myApps.where((a) => a.projectId == p.id).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(p.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            StatusChip(p.status.label,
                tone: p.status == ProjectStatus.closed
                    ? ChipTone.neutral
                    : ChipTone.good),
          ],
        ),
        const SizedBox(height: 4),
        Text('${p.clientName} · ${p.domain} · Due ${DateFormat('d MMM yyyy').format(p.deadline)}',
            style: const TextStyle(color: AppColors.mute, fontSize: 13)),
        _section('About', Text(p.description)),
        _section(
            'Required skills',
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final s in p.skills) StatusChip(s),
            ])),
        if (p.deliverables.isNotEmpty)
          _section('Expected deliverables', Text(p.deliverables)),
        const SizedBox(height: 24),

        // Student: apply or see status
        if (isStudent && mine.isEmpty && p.status == ProjectStatus.open)
          FilledButton(
            onPressed: () => context.push('/project/${p.id}/apply'),
            child: const Text('Apply to this project'),
          ),
        if (isStudent && mine.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Expanded(
                    child: Text('Your application',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                StatusChip(mine.first.status.label,
                    tone: applicationTone(mine.first.status)),
              ],
            ),
          ),

        // Owner: close + applicants
        if (isOwner) ...[
          if (p.status == ProjectStatus.open)
            OutlinedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(projectActionsProvider).close(p.id);
                messenger.showSnackBar(
                    const SnackBar(content: Text('Project closed.')));
              },
              child: const Text('Close project'),
            ),
          _section(
            'Applicants',
            ref.watch(projectApplicationsProvider(p.id)).when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const Text('Could not load applicants.'),
                  data: (list) => list.isEmpty
                      ? const Text('No applications yet.',
                          style: TextStyle(color: AppColors.mute))
                      : Column(children: [
                          for (final a in list)
                            ApplicantCard(application: a, showProject: false),
                        ]),
                ),
          ),
        ],
      ],
    );
  }
}
