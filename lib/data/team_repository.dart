import '../models/team.dart';

abstract class TeamRepository {
  /// Teams the user belongs to (matched by user id or email).
  Future<List<Team>> getTeamsForUser(String userId, String email);
  Future<Team?> getTeam(String id);
  Future<void> createTeam(Team team);
  Future<void> addMember(String teamId, TeamMember member);
  Future<void> removeMember(String teamId, String email);
}

class MockTeamRepository implements TeamRepository {
  final List<Team> _teams = [
    const Team(
      id: 't1',
      name: 'Code Crew',
      description: 'Third-year CS students who like shipping small apps fast.',
      skills: ['Flutter', 'Firebase', 'UI design'],
      previousWork: 'Built a hostel mess feedback app for our college fest.',
      leadId: 'u1',
      members: [
        TeamMember(
            name: 'Riya Sharma',
            email: 'student@demo.com',
            userId: 'u1',
            isLead: true),
        TeamMember(name: 'Aarav', email: 'aarav@demo.com'),
      ],
    ),
  ];

  @override
  Future<List<Team>> getTeamsForUser(String userId, String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final e = email.toLowerCase();
    return _teams
        .where((t) => t.members.any((m) =>
            (m.userId.isNotEmpty && m.userId == userId) ||
            m.email.toLowerCase() == e))
        .toList();
  }

  @override
  Future<Team?> getTeam(String id) async {
    for (final t in _teams) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> createTeam(Team team) async {
    _teams.insert(0, team);
  }

  @override
  Future<void> addMember(String teamId, TeamMember member) async {
    final i = _teams.indexWhere((t) => t.id == teamId);
    if (i == -1) throw Exception('Team not found.');
    final t = _teams[i];
    final exists = t.members
        .any((m) => m.email.toLowerCase() == member.email.toLowerCase());
    if (exists) throw Exception('That person is already in the team.');
    _teams[i] = _copy(t, [...t.members, member]);
  }

  @override
  Future<void> removeMember(String teamId, String email) async {
    final i = _teams.indexWhere((t) => t.id == teamId);
    if (i == -1) return;
    final t = _teams[i];
    _teams[i] = _copy(
        t, t.members.where((m) => m.email.toLowerCase() != email.toLowerCase()).toList());
  }

  Team _copy(Team t, List<TeamMember> members) => Team(
        id: t.id,
        name: t.name,
        description: t.description,
        skills: t.skills,
        previousWork: t.previousWork,
        leadId: t.leadId,
        members: members,
      );
}
