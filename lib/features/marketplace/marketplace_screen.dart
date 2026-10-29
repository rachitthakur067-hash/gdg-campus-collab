import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../auth/auth_provider.dart';
import 'project_card.dart';
import 'providers.dart';

const _domains = ['Mobile', 'Web', 'AI', 'Design'];

/// Students and mentors: browse open projects with search and filters.
/// Clients: see their own listings and create new ones.
class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isClient = user?.role == UserRole.client;
    final filter = ref.watch(filterProvider);
    final projects =
        isClient ? ref.watch(myProjectsProvider) : ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isClient ? 'My listings' : 'Find a project')),
      floatingActionButton: isClient
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/create-project'),
              icon: const Icon(Icons.add),
              label: const Text('New project'),
            )
          : null,
      body: Column(
        children: [
          if (!isClient) ...[
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
                    onTap: () =>
                        ref.read(filterProvider.notifier).setDomain(null),
                  ),
                  for (final d in _domains)
                    _FilterChip(
                      label: d,
                      selected: filter.domain == d,
                      onTap: () =>
                          ref.read(filterProvider.notifier).setDomain(d),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: projects.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: TextButton(
                  onPressed: () {
                    ref.invalidate(projectsProvider);
                    ref.invalidate(myProjectsProvider);
                  },
                  child: const Text('Could not load projects. Tap to retry.'),
                ),
              ),
              data: (list) => list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                            isClient
                                ? 'No listings yet. Tap New project to publish your first one.'
                                : 'No projects match. Try another filter.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.mute)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: list.length,
                      itemBuilder: (_, i) => ProjectCard(
                        project: list[i],
                        onTap: () => context.push('/project/${list[i].id}'),
                      ),
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
