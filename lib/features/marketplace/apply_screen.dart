import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/application.dart';
import '../../models/team.dart';
import '../applications/application_providers.dart';
import '../auth/auth_provider.dart';
import '../teams/team_providers.dart';
import 'providers.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  const ApplyScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _proposal = TextEditingController();
  String? _teamId; // null means applying on your own
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _proposal.dispose();
    super.dispose();
  }

  Future<void> _submit(List<Team> teams) async {
    if (_proposal.text.trim().length < 20) {
      setState(() => _error = 'Write at least a couple of sentences.');
      return;
    }
    final user = ref.read(authProvider);
    if (user == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final project =
          await ref.read(projectRepoProvider).getProject(widget.projectId);
      if (project == null) throw Exception('Project not found.');
      Team? team;
      for (final t in teams) {
        if (t.id == _teamId) team = t;
      }
      await ref.read(applicationActionsProvider).apply(Application(
            id: 'a${DateTime.now().millisecondsSinceEpoch}',
            projectId: project.id,
            projectTitle: project.title,
            clientId: project.clientId,
            applicantId: user.id,
            applicantName: user.name,
            teamId: team?.id ?? '',
            teamName: team?.name ?? '',
            proposal: _proposal.text.trim(),
            createdAt: DateTime.now(),
          ));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Application sent.')));
      context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final teams = (ref.watch(myTeamsProvider).value ?? <Team>[])
        .where((t) => user != null && t.leadId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Tell the client why you are a good fit.',
              style: TextStyle(color: AppColors.mute)),
          const SizedBox(height: 16),
          const Text('Apply as', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Myself'),
                selected: _teamId == null,
                onSelected: (_) => setState(() => _teamId = null),
              ),
              for (final t in teams)
                ChoiceChip(
                  label: Text(t.name),
                  selected: _teamId == t.id,
                  onSelected: (_) => setState(() => _teamId = t.id),
                ),
            ],
          ),
          if (teams.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                  'Create a team in the Teams tab to apply together. Only a team lead can apply for the team.',
                  style: TextStyle(color: AppColors.mute, fontSize: 12)),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _proposal,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
                labelText: 'Your proposal', alignLabelWithHint: true),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.red)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : () => _submit(teams),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send application'),
          ),
        ],
      ),
    );
  }
}
