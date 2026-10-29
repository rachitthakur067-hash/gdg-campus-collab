import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/application.dart';
import '../../models/team.dart';
import '../applications/applicant_card.dart';
import '../applications/application_providers.dart';
import '../auth/auth_provider.dart';
import 'team_providers.dart';

class TeamProfileScreen extends ConsumerWidget {
  const TeamProfileScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamByIdProvider(teamId));
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: team.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Could not load this team.')),
        data: (t) =>
            t == null ? const Center(child: Text('Team not found.')) : _Body(team: t),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.team});

  final Team team;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  final _email = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    try {
      await ref
          .read(teamActionsProvider)
          .addMemberByEmail(widget.team.id, email);
      _email.clear();
      if (mounted) setState(() => _error = null);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.team;
    final user = ref.watch(authProvider);
    final isLead = user != null && user.id == t.leadId;
    final apps = (ref.watch(myApplicationsProvider).value ?? <Application>[])
        .where((a) => a.teamId == t.id)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(t.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        if (t.description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(t.description),
        ],
        if (t.skills.isNotEmpty) ...[
          _title('Skills'),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final s in t.skills) StatusChip(s),
          ]),
        ],
        if (t.previousWork.isNotEmpty) ...[
          _title('Previous work'),
          Text(t.previousWork),
        ],
        _title('Members (${t.members.length})'),
        for (final m in t.members)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.tealBg,
                  child: Text(m.name.isEmpty ? '?' : m.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.teal, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(m.email,
                          style: const TextStyle(
                              color: AppColors.mute, fontSize: 12)),
                    ],
                  ),
                ),
                StatusChip(m.roleLabel,
                    tone: m.isLead ? ChipTone.good : ChipTone.neutral),
                if (isLead && !m.isLead)
                  IconButton(
                    tooltip: 'Remove member',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => ref
                        .read(teamActionsProvider)
                        .removeMember(t.id, m.email),
                  ),
              ],
            ),
          ),
        if (isLead) ...[
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Add a member by email',
                    errorText: _error,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(72, 52)),
                  onPressed: _add,
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
        _title('Project participation'),
        if (apps.isEmpty)
          const Text('This team has not applied to any project yet.',
              style: TextStyle(color: AppColors.mute))
        else
          for (final a in apps)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      child: Text(a.projectTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  StatusChip(a.status.label, tone: applicationTone(a.status)),
                ],
              ),
            ),
      ],
    );
  }
}
