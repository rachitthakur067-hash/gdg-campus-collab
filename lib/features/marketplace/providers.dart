import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/project_repository.dart';
import '../../models/project.dart';

/// To use the real backend later, swap MockProjectRepository() only.
final projectRepoProvider =
    Provider<ProjectRepository>((ref) => MockProjectRepository());

class ProjectFilter {
  const ProjectFilter({this.query = '', this.domain});
  final String query;
  final String? domain;
}

class FilterNotifier extends Notifier<ProjectFilter> {
  @override
  ProjectFilter build() => const ProjectFilter();

  void setQuery(String q) =>
      state = ProjectFilter(query: q, domain: state.domain);
  void setDomain(String? d) =>
      state = ProjectFilter(query: state.query, domain: d);
}

final filterProvider =
    NotifierProvider<FilterNotifier, ProjectFilter>(FilterNotifier.new);

/// Re-fetches automatically whenever the filter changes.
final projectsProvider = FutureProvider<List<Project>>((ref) {
  final f = ref.watch(filterProvider);
  return ref
      .watch(projectRepoProvider)
      .getProjects(query: f.query, domain: f.domain);
});
