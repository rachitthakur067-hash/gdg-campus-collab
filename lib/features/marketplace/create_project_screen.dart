import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/project.dart';
import '../auth/auth_provider.dart';
import 'providers.dart';

const _domains = ['Mobile', 'Web', 'AI', 'Design'];

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _skills = TextEditingController();
  final _deliverables = TextEditingController();
  String _domain = _domains.first;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _skills.dispose();
    _deliverables.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _publish() async {
    final user = ref.read(authProvider);
    if (user == null) return;
    if (_title.text.trim().isEmpty || _description.text.trim().isEmpty) {
      setState(() => _error = 'Add a title and a description.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(projectActionsProvider).create(Project(
            id: 'p${DateTime.now().millisecondsSinceEpoch}',
            title: _title.text.trim(),
            description: _description.text.trim(),
            domain: _domain,
            skills: _skills.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            deadline: _deadline,
            status: ProjectStatus.open,
            clientId: user.id,
            clientName: user.name,
            deliverables: _deliverables.text.trim(),
          ));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Project published.')));
      context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not publish. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New project')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
                labelText: 'Description', alignLabelWithHint: true),
          ),
          const SizedBox(height: 16),
          const Text('Domain', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final d in _domains)
                ChoiceChip(
                  label: Text(d),
                  selected: _domain == d,
                  onSelected: (_) => setState(() => _domain = d),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _skills,
            decoration: const InputDecoration(
                labelText: 'Required skills',
                helperText: 'Separate with commas, e.g. Flutter, Firebase'),
          ),
          const SizedBox(height: 12),
          TextField(
              controller: _deliverables,
              decoration:
                  const InputDecoration(labelText: 'Expected deliverables')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text('Deadline: ${DateFormat('d MMM yyyy').format(_deadline)}'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.red)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _publish,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Publish project'),
          ),
        ],
      ),
    );
  }
}
