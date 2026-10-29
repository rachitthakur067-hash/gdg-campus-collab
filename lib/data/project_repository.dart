import '../models/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects({String query = '', String? domain});
  Future<void> createProject(Project project);
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
    ),
  ];

  @override
  Future<List<Project>> getProjects({String query = '', String? domain}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.trim().toLowerCase();
    return _projects.where((p) {
      final matchesDomain = domain == null || p.domain == domain;
      final matchesQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.skills.any((s) => s.toLowerCase().contains(q));
      return matchesDomain && matchesQuery;
    }).toList();
  }

  @override
  Future<void> createProject(Project project) async {
    _projects.insert(0, project);
  }
}
