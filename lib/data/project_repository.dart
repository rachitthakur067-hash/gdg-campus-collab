import '../models/project.dart';

abstract class ProjectRepository {
  /// Open projects only (what students and mentors browse).
  Future<List<Project>> getProjects({String query = '', String? domain});
  Future<List<Project>> getProjectsByClient(String clientId);
  Future<Project?> getProject(String id);
  Future<void> createProject(Project project);
  Future<void> setStatus(String id, ProjectStatus status);
}

class MockProjectRepository implements ProjectRepository {
  final List<Project> _projects = [
    Project(
      id: 'p1',
      title: 'Campus event app',
      description:
          'A mobile app where students discover and register for campus events.',
      domain: 'Mobile',
      skills: ['Flutter', 'UI design'],
      deadline: DateTime(2026, 11, 30),
      status: ProjectStatus.open,
      clientId: 'u2',
      clientName: 'Priya Mehta',
      deliverables: 'Working Android app and source code',
    ),
    Project(
      id: 'p2',
      title: 'Alumni job board',
      description: 'A web portal where alumni post openings for students.',
      domain: 'Web',
      skills: ['React', 'SQL'],
      deadline: DateTime(2026, 12, 10),
      status: ProjectStatus.open,
      clientId: 'u2',
      clientName: 'Priya Mehta',
      deliverables: 'Hosted website and documentation',
    ),
    Project(
      id: 'p3',
      title: 'Crop price predictor',
      description: 'Predict local crop prices from past market data.',
      domain: 'AI',
      skills: ['Python', 'ML'],
      deadline: DateTime(2026, 12, 20),
      status: ProjectStatus.open,
      clientId: 'u4',
      clientName: 'AgriTech Labs',
      deliverables: 'Trained model and a short report',
    ),
    Project(
      id: 'p4',
      title: 'Brand kit for the tech fest',
      description: 'Logo, colours and social media templates.',
      domain: 'Design',
      skills: ['Figma'],
      deadline: DateTime(2026, 11, 22),
      status: ProjectStatus.open,
      clientId: 'u4',
      clientName: 'AgriTech Labs',
      deliverables: 'Figma file and exported assets',
    ),
  ];

  @override
  Future<List<Project>> getProjects({String query = '', String? domain}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.trim().toLowerCase();
    return _projects.where((p) {
      final open = p.status == ProjectStatus.open;
      final matchesDomain = domain == null || p.domain == domain;
      final matchesQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.skills.any((s) => s.toLowerCase().contains(q));
      return open && matchesDomain && matchesQuery;
    }).toList();
  }

  @override
  Future<List<Project>> getProjectsByClient(String clientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _projects.where((p) => p.clientId == clientId).toList();
  }

  @override
  Future<Project?> getProject(String id) async {
    for (final p in _projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<void> createProject(Project project) async {
    _projects.insert(0, project);
  }

  @override
  Future<void> setStatus(String id, ProjectStatus status) async {
    final i = _projects.indexWhere((p) => p.id == id);
    if (i != -1) _projects[i] = _projects[i].copyWith(status: status);
  }
}
