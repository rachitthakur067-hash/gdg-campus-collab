import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/workspace_repository.dart';
import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../models/project.dart';
import '../../models/workspace.dart';
import '../applications/application_providers.dart';
import '../auth/auth_provider.dart';
import '../activity/activity_providers.dart';
import '../marketplace/providers.dart';
import '../teams/team_providers.dart';

/// To use the real backend later, swap MockWorkspaceRepository() only.
final workspaceRepoProvider =
    Provider<WorkspaceRepository>((ref) => MockWorkspaceRepository());

final tasksProvider = FutureProvider.family<List<WorkTask>, String>(
    (ref, projectId) => ref.watch(workspaceRepoProvider).getTasks(projectId));

final milestonesProvider = FutureProvider.family<List<Milestone>, String>(
    (ref, projectId) =>
        ref.watch(workspaceRepoProvider).getMilestones(projectId));

final postsProvider = FutureProvider.family<List<ProjectPost>, String>(
    (ref, projectId) => ref.watch(workspaceRepoProvider).getPosts(projectId));

enum WorkspaceRole { team, client, viewer }

/// The accepted application for a project, if any.
final _acceptedProvider =
    FutureProvider.family<Application?, String>((ref, projectId) async {
  final apps = await ref.watch(projectApplicationsProvider(projectId).future);
  for (final a in apps) {
    if (a.status == ApplicationStatus.accepted) return a;
  }
  return null;
});

/// What the logged-in user may do in this project's workspace.
final workspaceRoleProvider =
    FutureProvider.family<WorkspaceRole, String>((ref, projectId) async {
  final user = ref.watch(authProvider);
  if (user == null) return WorkspaceRole.viewer;
  final project = await ref.watch(projectByIdProvider(projectId).future);
  if (project == null) return WorkspaceRole.viewer;
  if (project.clientId == user.id) return WorkspaceRole.client;
  final accepted = await ref.watch(_acceptedProvider(projectId).future);
  if (accepted == null) return WorkspaceRole.viewer;
  if (accepted.applicantId == user.id) return WorkspaceRole.team;
  if (accepted.teamId.isNotEmpty) {
    final team = await ref.watch(teamByIdProvider(accepted.teamId).future);
    final e = user.email.toLowerCase();
    if (team != null &&
        team.members.any((m) =>
            (m.userId.isNotEmpty && m.userId == user.id) ||
            m.email.toLowerCase() == e)) {
      return WorkspaceRole.team;
    }
  }
  return WorkspaceRole.viewer;
});

/// Names of the people who can be assigned tasks.
final workspaceMembersProvider =
    FutureProvider.family<List<String>, String>((ref, projectId) async {
  final accepted = await ref.watch(_acceptedProvider(projectId).future);
  if (accepted == null) return <String>[];
  if (accepted.teamId.isNotEmpty) {
    final team = await ref.watch(teamByIdProvider(accepted.teamId).future);
    if (team != null) return team.members.map((m) => m.name).toList();
  }
  return [accepted.applicantName];
});

/// Projects whose workspace the user can open.
final myWorkspacesProvider = FutureProvider<List<Project>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return <Project>[];

  if (user.role == UserRole.client) {
    final mine = await ref.watch(myProjectsProvider.future);
    return mine
        .where((p) =>
            p.status == ProjectStatus.inProgress ||
            p.status == ProjectStatus.closed)
        .toList();
  }

  final accepted = await ref.watch(applicationRepoProvider).accepted();
  final teams = await ref.watch(myTeamsProvider.future);
  final teamIds = teams.map((t) => t.id).toSet();
  final repo = ref.watch(projectRepoProvider);
  final result = <Project>[];
  for (final a in accepted) {
    final isMine = a.applicantId == user.id ||
        (a.teamId.isNotEmpty && teamIds.contains(a.teamId));
    if (!isMine) continue;
    final p = await repo.getProject(a.projectId);
    if (p != null) result.add(p);
  }
  return result;
});

class WorkspaceActions {
  WorkspaceActions(this._ref);
  final Ref _ref;

  WorkspaceRepository get _repo => _ref.read(workspaceRepoProvider);

  void _refresh() {
    _ref.invalidate(tasksProvider);
    _ref.invalidate(milestonesProvider);
    _ref.invalidate(postsProvider);
  }

  Future<void> addTask(WorkTask t) async {
    await _repo.addTask(t);
    await _ref.read(activityLoggerProvider).log(
        projectId: t.projectId, message: 'Task added: ${t.title}');
    _refresh();
  }

  Future<void> setTaskStatus(String id, TaskStatus s) async {
    await _repo.updateTaskStatus(id, s);
    _refresh();
  }

  Future<void> addMilestone(Milestone m) async {
    await _repo.addMilestone(m);
    await _ref.read(activityLoggerProvider).log(
        projectId: m.projectId,
        message: 'New milestone: ${m.title}',
        toTeam: true);
    _refresh();
  }

  Future<void> submitMilestone(Milestone m, String link) async {
    await _repo.submitMilestone(m.id, link);
    await _ref.read(activityLoggerProvider).log(
        projectId: m.projectId,
        message: 'Milestone submitted: ${m.title}',
        toClient: true);
    _refresh();
  }

  Future<void> reviewMilestone(Milestone m, List<ChecklistItem> checklist,
      String feedback, bool approved) async {
    await _repo.reviewMilestone(m.id, checklist, feedback, approved);
    await _ref.read(activityLoggerProvider).log(
        projectId: m.projectId,
        message: approved
            ? 'Milestone approved: ${m.title}'
            : 'Changes requested on ${m.title}',
        toTeam: true);
    _refresh();
  }

  Future<void> addPost(ProjectPost p) async {
    await _repo.addPost(p);
    await _ref.read(activityLoggerProvider).log(
        projectId: p.projectId,
        message: p.isAnnouncement
            ? '${p.authorName} posted an announcement'
            : '${p.authorName} commented',
        toClient: p.authorRole != 'Client',
        toTeam: p.authorRole == 'Client');
    _refresh();
  }
}

final workspaceActionsProvider =
    Provider<WorkspaceActions>((ref) => WorkspaceActions(ref));

/// Alias used by the workspace screen.
final projectByIdProviderForWorkspace = projectByIdProvider;
