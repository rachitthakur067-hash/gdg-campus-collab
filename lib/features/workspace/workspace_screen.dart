import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/project.dart';
import '../../models/workspace.dart';
import 'discussion_tab.dart';
import 'milestones_tab.dart';
import 'tasks_tab.dart';
import 'workspace_providers.dart';

/// The project dashboard: summary on top, then Tasks / Milestones / Discussion.
class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectByIdProviderForWorkspace(projectId));
    return project.when(
      loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Could not load this workspace.'))),
      data: (p) => p == null
          ? Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Project not found.')))
          : _Workspace(project: p),
    );
  }
}

class _Workspace extends ConsumerWidget {
  const _Workspace({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role =
        ref.watch(workspaceRoleProvider(project.id)).value ?? WorkspaceRole.viewer;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Milestones'),
              Tab(text: 'Discussion'),
            ],
          ),
        ),
        body: Column(
          children: [
            _Summary(project: project),
            Expanded(
              child: TabBarView(
                children: [
                  TasksTab(projectId: project.id, role: role),
                  MilestonesTab(projectId: project.id, role: role),
                  DiscussionTab(projectId: project.id, role: role),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider(project.id)).value ?? <WorkTask>[];
    final ms = ref.watch(milestonesProvider(project.id)).value ?? <Milestone>[];
    final members =
        ref.watch(workspaceMembersProvider(project.id)).value ?? <String>[];
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final approved =
        ms.where((m) => m.status == MilestoneStatus.approved).length;
    final pct = tasks.isEmpty ? 0.0 : done / tasks.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
              const Text('Progress',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${(pct * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.line,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [
            StatusChip('$done/${tasks.length} tasks'),
            StatusChip('$approved/${ms.length} milestones'),
            StatusChip('Due ${DateFormat('d MMM').format(project.deadline)}',
                tone: ChipTone.warn),
          ]),
          if (members.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Team: ${members.join(', ')}',
                style: const TextStyle(color: AppColors.mute, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
