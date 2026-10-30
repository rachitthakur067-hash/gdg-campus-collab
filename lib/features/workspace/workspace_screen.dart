import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/project.dart';
import '../../models/workspace.dart';
import '../activity/activity_providers.dart';
import '../marketplace/providers.dart';
import 'discussion_tab.dart';
import 'history_tab.dart';
import 'milestones_tab.dart';
import 'tasks_tab.dart';
import 'workspace_providers.dart';

/// The project dashboard: summary on top, then Tasks / Milestones /
/// Discussion / History. A closed project becomes read-only.
class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectByIdProvider(projectId));
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
    final closed = project.status == ProjectStatus.closed;
    // After closing, nobody can edit tasks, milestones or messages.
    final tabRole = closed ? WorkspaceRole.viewer : role;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.title),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Milestones'),
              Tab(text: 'Discussion'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: Column(
          children: [
            _Summary(project: project),
            _Actions(project: project, role: role),
            Expanded(
              child: TabBarView(
                children: [
                  TasksTab(projectId: project.id, role: tabRole),
                  MilestonesTab(projectId: project.id, role: tabRole),
                  DiscussionTab(projectId: project.id, role: tabRole),
                  HistoryTab(projectId: project.id),
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

/// Client: close the project. After closing: leave or view your review.
class _Actions extends ConsumerWidget {
  const _Actions({required this.project, required this.role});

  final Project project;
  final WorkspaceRole role;

  Future<void> _confirmClose(BuildContext context, WidgetRef ref) async {
    final ms = ref.read(milestonesProvider(project.id)).value ?? <Milestone>[];
    final allApproved =
        ms.isNotEmpty && ms.every((m) => m.status == MilestoneStatus.approved);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close this project?'),
        content: Text(allApproved
            ? 'All milestones are approved. Closing opens reviews for both sides.'
            : 'Not every milestone is approved yet. You can still close it, but the team will not be able to submit more work.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Close project')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(projectActionsProvider).close(project.id);
    messenger.showSnackBar(
        const SnackBar(content: Text('Project closed. Reviews are open.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (role == WorkspaceRole.client &&
        project.status == ProjectStatus.inProgress) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _confirmClose(context, ref),
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: const Text('Close project'),
          ),
        ),
      );
    }
    if (project.status == ProjectStatus.closed && role != WorkspaceRole.viewer) {
      final mine = ref.watch(myReviewProvider(project.id)).value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Row(
          children: [
            const StatusChip('Project closed'),
            const Spacer(),
            if (mine != null)
              Text('You rated ${mine.rating}/5',
                  style: const TextStyle(fontWeight: FontWeight.w700))
            else
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                onPressed: () => context.push('/workspace/${project.id}/review'),
                child: const Text('Leave a review'),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
