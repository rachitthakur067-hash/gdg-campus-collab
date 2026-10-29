enum UserRole { student, client, mentor, alumni }

extension UserRoleX on UserRole {
  String get label => name[0].toUpperCase() + name.substring(1);

  String get blurb => switch (this) {
        UserRole.student => 'Find projects, join teams',
        UserRole.client => 'Post projects, review work',
        UserRole.mentor => 'Guide teams, review milestones',
        UserRole.alumni => 'Share openings, mentor',
      };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.skills = const [],
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final List<String> skills;
}
