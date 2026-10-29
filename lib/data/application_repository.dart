import '../models/application.dart';

abstract class ApplicationRepository {
  Future<void> apply(Application application);
  Future<List<Application>> byApplicant(String applicantId);
  Future<List<Application>> byProject(String projectId);
  Future<List<Application>> byClient(String clientId);
  Future<void> updateStatus(String id, ApplicationStatus status);
}

class MockApplicationRepository implements ApplicationRepository {
  final List<Application> _items = [
    Application(
      id: 'a1',
      projectId: 'p1',
      projectTitle: 'Campus event app',
      clientId: 'u2',
      applicantId: 'u9',
      applicantName: 'Aarav Singh',
      teamName: 'Team Nova',
      proposal:
          'We are 4 students with Flutter and Firebase experience. We can ship a first version in 3 weeks.',
      createdAt: DateTime(2026, 10, 28),
    ),
    Application(
      id: 'a2',
      projectId: 'p1',
      projectTitle: 'Campus event app',
      clientId: 'u2',
      applicantId: 'u10',
      applicantName: 'Meera Joshi',
      teamName: 'Team Pixel',
      proposal: 'A design-first team. We will start with user research and wireframes.',
      createdAt: DateTime(2026, 10, 28),
    ),
  ];

  @override
  Future<void> apply(Application application) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final exists = _items.any((a) =>
        a.projectId == application.projectId &&
        a.applicantId == application.applicantId);
    if (exists) throw Exception('You already applied to this project.');
    _items.insert(0, application);
  }

  @override
  Future<List<Application>> byApplicant(String applicantId) async =>
      _items.where((a) => a.applicantId == applicantId).toList();

  @override
  Future<List<Application>> byProject(String projectId) async =>
      _items.where((a) => a.projectId == projectId).toList();

  @override
  Future<List<Application>> byClient(String clientId) async =>
      _items.where((a) => a.clientId == clientId).toList();

  @override
  Future<void> updateStatus(String id, ApplicationStatus status) async {
    final i = _items.indexWhere((a) => a.id == id);
    if (i != -1) _items[i] = _items[i].copyWith(status: status);
  }
}
