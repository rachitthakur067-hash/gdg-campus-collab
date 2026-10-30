/// One thing that happened in a project. Used for the notification feed
/// (filtered by recipient) and the project history timeline.
class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.message,
    required this.createdAt,
    this.recipientIds = const [],
  });

  final String id;
  final String projectId;
  final String projectTitle;
  final String message;
  final DateTime createdAt;

  /// User ids who should be notified. Empty means history only.
  final List<String> recipientIds;
}
