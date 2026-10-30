import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/workspace.dart';
import 'workspace_providers.dart';

ChipTone _tone(MilestoneStatus s) => switch (s) {
      MilestoneStatus.notSubmitted => ChipTone.neutral,
      MilestoneStatus.submitted => ChipTone.warn,
      MilestoneStatus.changesRequested => ChipTone.bad,
      MilestoneStatus.approved => ChipTone.good,
    };

class MilestonesTab extends ConsumerWidget {
  const MilestonesTab({super.key, required this.projectId, required this.role});

  final String projectId;
  final WorkspaceRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = ref.watch(milestonesProvider(projectId));
    final isClient = role == WorkspaceRole.client;
    final isTeam = role == WorkspaceRole.team;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: isClient
          ? FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => AddMilestoneSheet(projectId: projectId),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add milestone'),
            )
          : null,
      body: milestones.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(milestonesProvider),
            child: const Text('Could not load milestones. Tap to retry.'),
          ),
        ),
        data: (list) => list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                      isClient
                          ? 'No milestones yet. Add one with clear completion criteria.'
                          : 'The client has not added milestones yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.mute)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final m = list[i];
                  final canSubmit = isTeam &&
                      (m.status == MilestoneStatus.notSubmitted ||
                          m.status == MilestoneStatus.changesRequested);
                  final canReview =
                      isClient && m.status == MilestoneStatus.submitted;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                              child: Text(m.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15))),
                          StatusChip(m.status.label, tone: _tone(m.status)),
                        ]),
                        const SizedBox(height: 2),
                        Text('Due ${DateFormat('d MMM yyyy').format(m.dueDate)}',
                            style: const TextStyle(
                                color: AppColors.mute, fontSize: 12)),
                        const SizedBox(height: 8),
                        for (final c in m.checklist)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(children: [
                              Icon(
                                  c.done
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 18,
                                  color: c.done
                                      ? AppColors.teal
                                      : AppColors.mute),
                              const SizedBox(width: 8),
                              Expanded(child: Text(c.text)),
                            ]),
                          ),
                        if (m.submissionLink.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SelectableText('Submission: ${m.submissionLink}',
                              style: const TextStyle(
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w600)),
                        ],
                        if (m.feedback.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Feedback: ${m.feedback}'),
                          ),
                        ],
                        if (canSubmit || canReview) ...[
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              builder: (_) => canSubmit
                                  ? SubmitSheet(milestone: m)
                                  : ReviewSheet(milestone: m),
                            ),
                            child: Text(canSubmit ? 'Submit work' : 'Review'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

EdgeInsets _sheetPadding(BuildContext context) => EdgeInsets.fromLTRB(
    20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom);

/// Team: paste a link to the finished work.
class SubmitSheet extends ConsumerStatefulWidget {
  const SubmitSheet({super.key, required this.milestone});

  final Milestone milestone;

  @override
  ConsumerState<SubmitSheet> createState() => _SubmitSheetState();
}

class _SubmitSheetState extends ConsumerState<SubmitSheet> {
  final _link = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_link.text.trim().length < 4) {
      setState(() => _error = 'Paste a link to your work.');
      return;
    }
    await ref
        .read(workspaceActionsProvider)
        .submitMilestone(widget.milestone.id, _link.text.trim());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _sheetPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Submit: ${widget.milestone.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Share a Drive, GitHub or Figma link.',
              style: TextStyle(color: AppColors.mute)),
          const SizedBox(height: 12),
          TextField(
            controller: _link,
            keyboardType: TextInputType.url,
            decoration:
                InputDecoration(labelText: 'Link to your work', errorText: _error),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('Submit for review')),
        ],
      ),
    );
  }
}

/// Client: tick the checklist, write feedback, approve or request changes.
class ReviewSheet extends ConsumerStatefulWidget {
  const ReviewSheet({super.key, required this.milestone});

  final Milestone milestone;

  @override
  ConsumerState<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<ReviewSheet> {
  late List<ChecklistItem> _items = [...widget.milestone.checklist];
  final _feedback = TextEditingController();

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _finish(bool approved) async {
    await ref.read(workspaceActionsProvider).reviewMilestone(
        widget.milestone.id, _items, _feedback.text.trim(), approved);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final allDone = _items.every((c) => c.done);
    return SingleChildScrollView(
      padding: _sheetPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review: ${widget.milestone.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          if (widget.milestone.submissionLink.isNotEmpty) ...[
            const SizedBox(height: 6),
            SelectableText(widget.milestone.submissionLink,
                style: const TextStyle(color: AppColors.teal)),
          ],
          const SizedBox(height: 10),
          for (var i = 0; i < _items.length; i++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _items[i].done,
              title: Text(_items[i].text),
              onChanged: (v) => setState(
                  () => _items[i] = _items[i].copyWith(done: v ?? false)),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedback,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'Feedback for the team', alignLabelWithHint: true),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: allDone ? () => _finish(true) : null,
            child: const Text('Approve milestone'),
          ),
          if (!allDone)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Tick every item to approve.',
                  style: TextStyle(color: AppColors.mute, fontSize: 12)),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _finish(false),
            child: const Text('Request changes'),
          ),
        ],
      ),
    );
  }
}

/// Client: define a milestone and its completion criteria.
class AddMilestoneSheet extends ConsumerStatefulWidget {
  const AddMilestoneSheet({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<AddMilestoneSheet> createState() => _AddMilestoneSheetState();
}

class _AddMilestoneSheetState extends ConsumerState<AddMilestoneSheet> {
  final _title = TextEditingController();
  final _criteria = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 14));
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _criteria.dispose();
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

  Future<void> _save() async {
    final items = _criteria.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => ChecklistItem(s))
        .toList();
    if (_title.text.trim().isEmpty || items.isEmpty) {
      setState(() => _error = 'Add a title and at least one criterion.');
      return;
    }
    await ref.read(workspaceActionsProvider).addMilestone(Milestone(
          id: 'm${DateTime.now().millisecondsSinceEpoch}',
          projectId: widget.projectId,
          title: _title.text.trim(),
          dueDate: _due,
          checklist: items,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _sheetPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New milestone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(
            controller: _criteria,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Completion criteria',
              helperText: 'One per line',
              alignLabelWithHint: true,
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text('Due ${DateFormat('d MMM yyyy').format(_due)}'),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Add milestone')),
        ],
      ),
    );
  }
}
