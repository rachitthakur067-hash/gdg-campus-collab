import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/application_repository.dart';
import '../../models/application.dart';
import '../auth/auth_provider.dart';
import '../marketplace/providers.dart';

/// To use the real backend later, swap MockApplicationRepository() only.
final applicationRepoProvider =
    Provider<ApplicationRepository>((ref) => MockApplicationRepository());

/// The logged-in student's applications.
final myApplicationsProvider = FutureProvider<List<Application>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return <Application>[];
  return ref.watch(applicationRepoProvider).byApplicant(user.id);
});

/// Applications received by the logged-in client, across all projects.
final clientApplicationsProvider = FutureProvider<List<Application>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return <Application>[];
  return ref.watch(applicationRepoProvider).byClient(user.id);
});

final projectApplicationsProvider =
    FutureProvider.family<List<Application>, String>((ref, projectId) =>
        ref.watch(applicationRepoProvider).byProject(projectId));

class ApplicationActions {
  ApplicationActions(this._ref);
  final Ref _ref;

  void _refresh() {
    _ref.invalidate(myApplicationsProvider);
    _ref.invalidate(clientApplicationsProvider);
    _ref.invalidate(projectApplicationsProvider);
  }

  Future<void> apply(Application application) async {
    await _ref.read(applicationRepoProvider).apply(application);
    _refresh();
  }

  /// Accepting a team moves the project to "in progress", which is
  /// what will open the workspace in Phase 5.
  Future<void> setStatus(Application a, ApplicationStatus status) async {
    await _ref.read(applicationRepoProvider).updateStatus(a.id, status);
    if (status == ApplicationStatus.accepted) {
      await _ref.read(projectActionsProvider).markInProgress(a.projectId);
    }
    _refresh();
  }
}

final applicationActionsProvider =
    Provider<ApplicationActions>((ref) => ApplicationActions(ref));
