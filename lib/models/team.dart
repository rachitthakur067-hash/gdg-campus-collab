class TeamMember {
  const TeamMember({
    required this.name,
    required this.email,
    this.userId = '',
    this.isLead = false,
  });

  final String name;
  final String email;
  final String userId;
  final bool isLead;

  String get roleLabel => isLead ? 'Lead' : 'Member';
}

class Team {
  const Team({
    required this.id,
    required this.name,
    required this.description,
    required this.skills,
    required this.leadId,
    required this.members,
    this.previousWork = '',
  });

  final String id;
  final String name;
  final String description;
  final List<String> skills;
  final String previousWork;
  final String leadId;
  final List<TeamMember> members;
}
