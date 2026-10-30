import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/project_repository.dart';
import '../../models/project.dart';
import '../auth/auth_provider.dart';
import '../activity/activity_providers.dart';

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

/// Open projects, re-fetched whenever the filter changes.
final projectsProvider = FutureProvider<List<Project>>((ref) {
  final f = ref.watch(filterProvider);
  return ref
      .watch(projectRepoProvider)
      .getProjects(query: f.query, domain: f.domain);
});

/// The logged-in client's own listings (any status).
final myProjectsProvider = FutureProvider<List<Project>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return <Project>[];
  return ref.watch(projectRepoProvider).getProjectsByClient(user.id);
});

final projectByIdProvider = FutureProvider.family<Project?, String>(
    (ref, id) => ref.watch(projectRepoProvider).getProject(id));

/// Write actions. Each one refreshes the lists that changed.
class ProjectActions {
  ProjectActions(this._ref);
  final Ref _ref;

  void _refresh() {
    _ref.invalidate(projectsProvider);
    _ref.invalidate(myProjectsProvider);
    _ref.invalidate(projectByIdProvider);
  }

  Future<void> create(Project project) async {
    await _ref.read(projectRepoProvider).createProject(project);
    await _ref.read(activityLoggerProvider).log(
        projectId: project.id,
        message: '${project.clientName} published ${project.title}');
    _refresh();
  }

  Future<void> close(String projectId) async {
    await _ref
        .read(projectRepoProvider)
        .setStatus(projectId, ProjectStatus.closed);
    await _ref.read(activityLoggerProvider).log(
        projectId: projectId,
        message: 'Project closed',
        toClient: true,
        toTeam: true);
    _refresh();
  }

  Future<void> markInProgress(String projectId) async {
    await _ref
        .read(projectRepoProvider)
        .setStatus(projectId, ProjectStatus.inProgress);
    _refresh();
  }
}

final projectActionsProvider = Provider<ProjectActions>((ref) => ProjectActions(ref));
