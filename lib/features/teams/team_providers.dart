import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/team_repository.dart';
import '../../models/team.dart';
import '../auth/auth_provider.dart';

/// To use the real backend later, swap MockTeamRepository() only.
final teamRepoProvider =
    Provider<TeamRepository>((ref) => MockTeamRepository());

/// Teams the logged-in user belongs to.
final myTeamsProvider = FutureProvider<List<Team>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return <Team>[];
  return ref.watch(teamRepoProvider).getTeamsForUser(user.id, user.email);
});

final teamByIdProvider = FutureProvider.family<Team?, String>(
    (ref, id) => ref.watch(teamRepoProvider).getTeam(id));

class TeamActions {
  TeamActions(this._ref);
  final Ref _ref;

  void _refresh() {
    _ref.invalidate(myTeamsProvider);
    _ref.invalidate(teamByIdProvider);
  }

  Future<void> create(Team team) async {
    await _ref.read(teamRepoProvider).createTeam(team);
    _refresh();
  }

  /// Mock: builds a name from the email. With the real backend, look the
  /// user up by email and use their real profile.
  Future<void> addMemberByEmail(String teamId, String email) async {
    final clean = email.trim();
    final local = clean.split('@').first;
    final name = local.isEmpty ? clean : local[0].toUpperCase() + local.substring(1);
    await _ref
        .read(teamRepoProvider)
        .addMember(teamId, TeamMember(name: name, email: clean));
    _refresh();
  }

  Future<void> removeMember(String teamId, String email) async {
    await _ref.read(teamRepoProvider).removeMember(teamId, email);
    _refresh();
  }
}

final teamActionsProvider = Provider<TeamActions>((ref) => TeamActions(ref));
