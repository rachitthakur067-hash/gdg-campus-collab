import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/team.dart';
import '../auth/auth_provider.dart';
import 'team_providers.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _skills = TextEditingController();
  final _work = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _skills.dispose();
    _work.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final user = ref.read(authProvider);
    if (user == null) return;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give your team a name.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(teamActionsProvider).create(Team(
            id: 't${DateTime.now().millisecondsSinceEpoch}',
            name: _name.text.trim(),
            description: _description.text.trim(),
            skills: _skills.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            previousWork: _work.text.trim(),
            leadId: user.id,
            members: [
              TeamMember(
                  name: user.name,
                  email: user.email,
                  userId: user.id,
                  isLead: true),
            ],
          ));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Team created.')));
      context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not create the team. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New team')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Team name')),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'About your team', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _skills,
            decoration: const InputDecoration(
                labelText: 'Team skills',
                helperText: 'Separate with commas, e.g. Flutter, Figma'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _work,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'Previous work (optional)',
                alignLabelWithHint: true),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.red)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _create,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create team'),
          ),
          const SizedBox(height: 8),
          const Text('You can add members by email after the team is created.',
              style: TextStyle(color: AppColors.mute, fontSize: 12)),
        ],
      ),
    );
  }
}
