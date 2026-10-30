import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/application.dart';
import '../../models/project.dart';
import '../../models/review.dart';
import '../activity/activity_providers.dart';
import '../applications/application_providers.dart';
import '../auth/auth_provider.dart';
import '../marketplace/providers.dart';
import 'workspace_providers.dart';

const _gold = Color(0xFFE0A526);

/// After a project is closed, the client rates the team and the team
/// rates the client. One review per person.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _comment = TextEditingController();
  int _rating = 0;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit(Project project, WorkspaceRole role, String toLabel) async {
    final user = ref.read(authProvider);
    if (user == null) return;
    if (_rating == 0) {
      setState(() => _error = 'Pick a star rating.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(reviewActionsProvider).submit(Review(
            id: 'r${DateTime.now().millisecondsSinceEpoch}',
            projectId: project.id,
            projectTitle: project.title,
            fromId: user.id,
            fromName: user.name,
            fromRole: role == WorkspaceRole.client ? 'Client' : 'Team',
            toLabel: toLabel,
            rating: _rating,
            comment: _comment.text.trim(),
            createdAt: DateTime.now(),
          ));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review submitted.')));
      context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not submit. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _message(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mute)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectByIdProvider(widget.projectId)).value;
    final role = ref.watch(workspaceRoleProvider(widget.projectId)).value;
    final apps = ref.watch(projectApplicationsProvider(widget.projectId)).value ??
        <Application>[];
    final mine = ref.watch(myReviewProvider(widget.projectId)).value;

    Widget body;
    if (project == null || role == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (project.status != ProjectStatus.closed) {
      body = _message('Reviews open once the client closes the project.');
    } else if (role == WorkspaceRole.viewer) {
      body = _message('Only people who worked on this project can review it.');
    } else if (mine != null) {
      body = _message('You already rated this project ${mine.rating}/5. Thank you!');
    } else {
      var toLabel = project.clientName;
      if (role == WorkspaceRole.client) {
        for (final a in apps) {
          if (a.status == ApplicationStatus.accepted) toLabel = a.displayName;
        }
      }
      body = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Rate $toLabel',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(project.title, style: const TextStyle(color: AppColors.mute)),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: '$i stars',
                  iconSize: 36,
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(i <= _rating ? Icons.star : Icons.star_border,
                      color: _gold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _comment,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
                labelText: 'Written feedback (optional)',
                alignLabelWithHint: true),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.red)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : () => _submit(project, role, toLabel),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit review'),
          ),
        ],
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('Review')), body: body);
  }
}
