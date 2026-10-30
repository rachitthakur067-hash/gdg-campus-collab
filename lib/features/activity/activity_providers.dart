import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/activity_repository.dart';
import '../../data/review_repository.dart';
import '../../models/activity.dart';
import '../../models/application.dart';
import '../../models/review.dart';
import '../applications/application_providers.dart';
import '../auth/auth_provider.dart';
import '../marketplace/providers.dart';
import '../teams/team_providers.dart';

/// To use the real backend later, swap the Mock... repositories only.
final activityRepoProvider =
    Provider<ActivityRepository>((ref) => MockActivityRepository());
final reviewRepoProvider =
    Provider<ReviewRepository>((ref) => MockReviewRepository());

/// Notifications for the logged-in user, newest first.
final feedProvider = FutureProvider<List<ActivityEvent>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return <ActivityEvent>[];
  return ref.watch(activityRepoProvider).forUser(user.id);
});

final readIdsProvider = FutureProvider<Set<String>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return <String>{};
  return ref.watch(activityRepoProvider).readIds(user.id);
});

final unreadCountProvider = Provider<int>((ref) {
  final feed = ref.watch(feedProvider).value ?? <ActivityEvent>[];
  final read = ref.watch(readIdsProvider).value ?? <String>{};
  return feed.where((e) => !read.contains(e.id)).length;
});

/// Every event of one project, oldest first (the history timeline).
final projectHistoryProvider =
    FutureProvider.family<List<ActivityEvent>, String>((ref, projectId) =>
        ref.watch(activityRepoProvider).forProject(projectId));

final projectReviewsProvider = FutureProvider.family<List<Review>, String>(
    (ref, projectId) => ref.watch(reviewRepoProvider).forProject(projectId));

/// The review the logged-in user already wrote for this project, if any.
final myReviewProvider =
    FutureProvider.family<Review?, String>((ref, projectId) async {
  final user = ref.watch(authProvider);
  if (user == null) return null;
  final all = await ref.watch(projectReviewsProvider(projectId).future);
  for (final r in all) {
    if (r.fromId == user.id) return r;
  }
  return null;
});

/// Writes one event and works out who should be notified.
class ActivityLogger {
  ActivityLogger(this._ref);
  final Ref _ref;

  Future<void> log({
    required String projectId,
    required String message,
    bool toClient = false,
    bool toTeam = false,
    List<String> recipients = const [],
  }) async {
    final project = await _ref.read(projectRepoProvider).getProject(projectId);
    final to = <String>{...recipients};
    if (toClient && project != null) to.add(project.clientId);
    if (toTeam) to.addAll(await _teamIds(projectId));
    to.remove(_ref.read(authProvider)?.id); // never notify yourself

    await _ref.read(activityRepoProvider).log(ActivityEvent(
          id: 'e${DateTime.now().microsecondsSinceEpoch}',
          projectId: projectId,
          projectTitle: project?.title ?? '',
          message: message,
          createdAt: DateTime.now(),
          recipientIds: to.toList(),
        ));
    _ref.invalidate(feedProvider);
    _ref.invalidate(readIdsProvider);
    _ref.invalidate(projectHistoryProvider);
  }

  Future<List<String>> _teamIds(String projectId) async {
    final apps = await _ref.read(applicationRepoProvider).byProject(projectId);
    for (final a in apps) {
      if (a.status == ApplicationStatus.accepted) {
        return applicationRecipients(a);
      }
    }
    return [];
  }

  /// The applicant plus every team member who has a user id.
  Future<List<String>> applicationRecipients(Application a) async {
    final ids = <String>{a.applicantId};
    if (a.teamId.isNotEmpty) {
      final team = await _ref.read(teamRepoProvider).getTeam(a.teamId);
      if (team != null) {
        for (final m in team.members) {
          if (m.userId.isNotEmpty) ids.add(m.userId);
        }
      }
    }
    return ids.toList();
  }
}

final activityLoggerProvider =
    Provider<ActivityLogger>((ref) => ActivityLogger(ref));

class ActivityActions {
  ActivityActions(this._ref);
  final Ref _ref;

  Future<void> markRead(List<String> ids) async {
    final user = _ref.read(authProvider);
    if (user == null || ids.isEmpty) return;
    await _ref.read(activityRepoProvider).markRead(user.id, ids);
    _ref.invalidate(readIdsProvider);
  }
}

final activityActionsProvider =
    Provider<ActivityActions>((ref) => ActivityActions(ref));

class ReviewActions {
  ReviewActions(this._ref);
  final Ref _ref;

  Future<void> submit(Review r) async {
    await _ref.read(reviewRepoProvider).add(r);
    await _ref.read(activityLoggerProvider).log(
          projectId: r.projectId,
          message: '${r.fromName} rated ${r.toLabel} ${r.rating}/5',
          toClient: true,
          toTeam: true,
        );
    _ref.invalidate(projectReviewsProvider);
    _ref.invalidate(myReviewProvider);
  }
}

final reviewActionsProvider =
    Provider<ReviewActions>((ref) => ReviewActions(ref));
