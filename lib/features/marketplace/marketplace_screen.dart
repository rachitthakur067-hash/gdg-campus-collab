import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../auth/auth_provider.dart';
import 'project_card.dart';
import 'providers.dart';

const _domains = ['Mobile', 'Web', 'AI', 'Design'];

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final filter = ref.watch(filterProvider);
    final projects = ref.watch(projectsProvider);
    final isClient = user?.role == UserRole.client;

    return Scaffold(
      appBar: AppBar(title: Text(isClient ? 'My listings' : 'Find a project')),
      floatingActionButton: isClient
          ? FloatingActionButton.extended(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phase 3: create project form'))),
              icon: const Icon(Icons.add),
              label: const Text('New project'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: ref.read(filterProvider.notifier).setQuery,
              decoration: const InputDecoration(
                hintText: 'Search title or skill',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: filter.domain == null,
                  onTap: () => ref.read(filterProvider.notifier).setDomain(null),
                ),
                for (final d in _domains)
                  _FilterChip(
                    label: d,
                    selected: filter.domain == d,
                    onTap: () => ref.read(filterProvider.notifier).setDomain(d),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: projects.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(projectsProvider),
                  child: const Text('Could not load projects. Tap to retry.'),
                ),
              ),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text('No projects match. Try another filter.',
                          style: TextStyle(color: AppColors.mute)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: list.length,
                      itemBuilder: (_, i) => ProjectCard(project: list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
