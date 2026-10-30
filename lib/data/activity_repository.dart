import '../models/activity.dart';

abstract class ActivityRepository {
  Future<void> log(ActivityEvent event);
  Future<List<ActivityEvent>> forUser(String userId); // newest first
  Future<List<ActivityEvent>> forProject(String projectId); // oldest first
  Future<Set<String>> readIds(String userId);
  Future<void> markRead(String userId, List<String> eventIds);
}

class MockActivityRepository implements ActivityRepository {
  final List<ActivityEvent> _events = [
    ActivityEvent(
        id: 'e1',
        projectId: 'p5',
        projectTitle: 'Hostel complaint portal',
        message: 'Priya Mehta published Hostel complaint portal',
        createdAt: DateTime(2026, 10, 18, 9, 0)),
    ActivityEvent(
        id: 'e2',
        projectId: 'p5',
        projectTitle: 'Hostel complaint portal',
        message: 'Code Crew applied to Hostel complaint portal',
        createdAt: DateTime(2026, 10, 20, 10, 15),
        recipientIds: ['u2']),
    ActivityEvent(
        id: 'e3',
        projectId: 'p5',
        projectTitle: 'Hostel complaint portal',
        message: 'Priya Mehta accepted Code Crew. The workspace is open.',
        createdAt: DateTime(2026, 10, 25, 10, 0),
        recipientIds: ['u1']),
    ActivityEvent(
        id: 'e4',
        projectId: 'p5',
        projectTitle: 'Hostel complaint portal',
        message: 'Priya Mehta posted an announcement',
        createdAt: DateTime(2026, 10, 25, 10, 30),
        recipientIds: ['u1']),
    ActivityEvent(
        id: 'e5',
        projectId: 'p5',
        projectTitle: 'Hostel complaint portal',
        message: 'Riya Sharma commented',
        createdAt: DateTime(2026, 10, 25, 11, 5),
        recipientIds: ['u2']),
  ];

  final Map<String, Set<String>> _read = {};

  @override
  Future<void> log(ActivityEvent event) async => _events.add(event);

  @override
  Future<List<ActivityEvent>> forUser(String userId) async {
    final list =
        _events.where((e) => e.recipientIds.contains(userId)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<ActivityEvent>> forProject(String projectId) async {
    final list = _events.where((e) => e.projectId == projectId).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<Set<String>> readIds(String userId) async =>
      {...(_read[userId] ?? <String>{})};

  @override
  Future<void> markRead(String userId, List<String> eventIds) async {
    _read.putIfAbsent(userId, () => <String>{}).addAll(eventIds);
  }
}
