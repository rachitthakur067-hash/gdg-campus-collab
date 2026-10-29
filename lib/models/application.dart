enum ApplicationStatus { pending, shortlisted, accepted, declined }

extension ApplicationStatusX on ApplicationStatus {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class Application {
  const Application({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.applicantId,
    required this.applicantName,
    required this.proposal,
    required this.createdAt,
    this.teamId = '',
    this.teamName = '',
    this.status = ApplicationStatus.pending,
  });

  final String id;
  final String projectId;
  final String projectTitle;
  final String clientId;
  final String applicantId;
  final String applicantName;
  final String teamId;
  final String teamName;
  final String proposal;
  final DateTime createdAt;
  final ApplicationStatus status;

  String get displayName => teamName.trim().isEmpty ? applicantName : teamName;

  Application copyWith({ApplicationStatus? status}) => Application(
        id: id,
        projectId: projectId,
        projectTitle: projectTitle,
        clientId: clientId,
        applicantId: applicantId,
        applicantName: applicantName,
        teamId: teamId,
        teamName: teamName,
        proposal: proposal,
        createdAt: createdAt,
        status: status ?? this.status,
      );
}
