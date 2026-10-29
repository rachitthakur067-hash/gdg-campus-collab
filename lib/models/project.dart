enum ProjectStatus { draft, open, inProgress, closed }

extension ProjectStatusX on ProjectStatus {
  String get label => switch (this) {
        ProjectStatus.draft => 'Draft',
        ProjectStatus.open => 'Open',
        ProjectStatus.inProgress => 'In progress',
        ProjectStatus.closed => 'Closed',
      };
}

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.domain,
    required this.skills,
    required this.deadline,
    required this.status,
    required this.clientId,
    required this.clientName,
  });

  final String id;
  final String title;
  final String description;
  final String domain;
  final List<String> skills;
  final DateTime deadline;
  final ProjectStatus status;
  final String clientId;
  final String clientName;
}
