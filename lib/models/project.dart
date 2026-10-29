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
    this.deliverables = '',
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
  final String deliverables;

  Project copyWith({ProjectStatus? status}) => Project(
        id: id,
        title: title,
        description: description,
        domain: domain,
        skills: skills,
        deadline: deadline,
        status: status ?? this.status,
        clientId: clientId,
        clientName: clientName,
        deliverables: deliverables,
      );
}
