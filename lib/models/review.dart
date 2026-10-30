class Review {
  const Review({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.fromId,
    required this.fromName,
    required this.fromRole,
    required this.toLabel,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String projectTitle;
  final String fromId;
  final String fromName;
  final String fromRole; // 'Client' or 'Team'
  final String toLabel; // team name or client name
  final int rating; // 1 to 5
  final String comment;
  final DateTime createdAt;
}
