import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/workspace.dart';
import 'workspace_providers.dart';

ChipTone _statusTone(TaskStatus s) => switch (s) {
      TaskStatus.todo => ChipTone.neutral,
      TaskStatus.doing => ChipTone.warn,
      TaskStatus.done => ChipTone.good,
    };

ChipTone _priorityTone(TaskPriority p) => switch (p) {
      TaskPriority.high => ChipTone.bad,
      TaskPriority.medium => ChipTone.warn,
      TaskPriority.low => ChipTone.neutral,
    };

class TasksTab extends ConsumerWidget {
  const TasksTab({super.key, required this.projectId, required this.role});

  final String projectId;
  final WorkspaceRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider(projectId));
    final canEdit = role == WorkspaceRole.team;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => AddTaskSheet(projectId: projectId),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add task'),
            )
          : null,
      body: tasks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(tasksProvider),
            child: const Text('Could not load tasks. Tap to retry.'),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                    canEdit
                        ? 'No tasks yet. Tap Add task to plan the work.'
                        : 'The team has not added tasks yet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.mute)),
              ),
            );
          }
          const order = {
            TaskStatus.doing: 0,
            TaskStatus.todo: 1,
            TaskStatus.done: 2,
          };
          final sorted = [...list]
            ..sort((a, b) => order[a.status]!.compareTo(order[b.status]!));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final t = sorted[i];
              final chip = StatusChip(t.status.label, tone: _statusTone(t.status));
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: t.status == TaskStatus.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              )),
                          const SizedBox(height: 2),
                          Text(
                              '${t.assignee} · Due ${DateFormat('d MMM').format(t.dueDate)}',
                              style: const TextStyle(
                                  color: AppColors.mute, fontSize: 12)),
                          const SizedBox(height: 6),
                          StatusChip('${t.priority.label} priority',
                              tone: _priorityTone(t.priority)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    canEdit
                        ? PopupMenuButton<TaskStatus>(
                            tooltip: 'Change status',
                            onSelected: (s) => ref
                                .read(workspaceActionsProvider)
                                .setTaskStatus(t.id, s),
                            itemBuilder: (_) => [
                              for (final s in TaskStatus.values)
                                PopupMenuItem(value: s, child: Text(s.label)),
                            ],
                            child: chip,
                          )
                        : chip,
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _title = TextEditingController();
  String? _assignee;
  TaskPriority _priority = TaskPriority.medium;
  DateTime _due = DateTime.now().add(const Duration(days: 7));
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _due = d);
  }

  Future<void> _save(List<String> members) async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give the task a title.');
      return;
    }
    final assignee = _assignee ?? (members.isNotEmpty ? members.first : 'Unassigned');
    await ref.read(workspaceActionsProvider).addTask(WorkTask(
          id: 'k${DateTime.now().millisecondsSinceEpoch}',
          projectId: widget.projectId,
          title: _title.text.trim(),
          assignee: assignee,
          dueDate: _due,
          priority: _priority,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final members =
        ref.watch(workspaceMembersProvider(widget.projectId)).value ?? <String>[];
    final selected = _assignee ?? (members.isNotEmpty ? members.first : null);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New task',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
              controller: _title,
              decoration: InputDecoration(
                  labelText: 'Task title', errorText: _error)),
          const SizedBox(height: 14),
          const Text('Assign to', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final m in members)
              ChoiceChip(
                label: Text(m),
                selected: selected == m,
                onSelected: (_) => setState(() => _assignee = m),
              ),
          ]),
          const SizedBox(height: 14),
          const Text('Priority', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: [
            for (final p in TaskPriority.values)
              ChoiceChip(
                label: Text(p.label),
                selected: _priority == p,
                onSelected: (_) => setState(() => _priority = p),
              ),
          ]),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text('Due ${DateFormat('d MMM yyyy').format(_due)}'),
          ),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: () => _save(members), child: const Text('Add task')),
        ],
      ),
    );
  }
}
