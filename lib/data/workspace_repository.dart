import '../models/workspace.dart';

abstract class WorkspaceRepository {
  Future<List<WorkTask>> getTasks(String projectId);
  Future<void> addTask(WorkTask task);
  Future<void> updateTaskStatus(String id, TaskStatus status);

  Future<List<Milestone>> getMilestones(String projectId);
  Future<void> addMilestone(Milestone milestone);
  Future<void> submitMilestone(String id, String link);
  Future<void> reviewMilestone(
      String id, List<ChecklistItem> checklist, String feedback, bool approved);

  Future<List<ProjectPost>> getPosts(String projectId);
  Future<void> addPost(ProjectPost post);
}

class MockWorkspaceRepository implements WorkspaceRepository {
  final List<WorkTask> _tasks = [
    WorkTask(
        id: 'k1',
        projectId: 'p5',
        title: 'Design login screens',
        assignee: 'Riya Sharma',
        dueDate: DateTime(2026, 11, 2),
        priority: TaskPriority.high,
        status: TaskStatus.done),
    WorkTask(
        id: 'k2',
        projectId: 'p5',
        title: 'Set up Firebase project',
        assignee: 'Aarav',
        dueDate: DateTime(2026, 11, 3),
        priority: TaskPriority.medium,
        status: TaskStatus.done),
    WorkTask(
        id: 'k3',
        projectId: 'p5',
        title: 'Build complaint form',
        assignee: 'Riya Sharma',
        dueDate: DateTime(2026, 11, 8),
        priority: TaskPriority.high,
        status: TaskStatus.doing),
    WorkTask(
        id: 'k4',
        projectId: 'p5',
        title: 'Write test cases',
        assignee: 'Aarav',
        dueDate: DateTime(2026, 11, 11),
        priority: TaskPriority.low),
  ];

  final List<Milestone> _milestones = [
    Milestone(
      id: 'm1',
      projectId: 'p5',
      title: 'Prototype',
      dueDate: DateTime(2026, 11, 12),
      checklist: const [
        ChecklistItem('Matches the brief'),
        ChecklistItem('Screens work on a phone'),
        ChecklistItem('Source code shared'),
      ],
    ),
    Milestone(
      id: 'm2',
      projectId: 'p5',
      title: 'Final delivery',
      dueDate: DateTime(2026, 12, 3),
      checklist: const [
        ChecklistItem('All features working'),
        ChecklistItem('User guide included'),
      ],
    ),
  ];

  final List<ProjectPost> _posts = [
    ProjectPost(
      id: 'c1',
      projectId: 'p5',
      authorId: 'u2',
      authorName: 'Priya Mehta',
      authorRole: 'Client',
      text: 'Welcome aboard! Please share the prototype by 12 Nov.',
      createdAt: DateTime(2026, 10, 25, 10, 30),
      isAnnouncement: true,
    ),
    ProjectPost(
      id: 'c2',
      projectId: 'p5',
      authorId: 'u1',
      authorName: 'Riya Sharma',
      authorRole: 'Team',
      text: 'Thanks! We will post updates here every few days.',
      createdAt: DateTime(2026, 10, 25, 11, 5),
    ),
  ];

  @override
  Future<List<WorkTask>> getTasks(String projectId) async =>
      _tasks.where((t) => t.projectId == projectId).toList();

  @override
  Future<void> addTask(WorkTask task) async => _tasks.add(task);

  @override
  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) _tasks[i] = _tasks[i].copyWith(status: status);
  }

  @override
  Future<List<Milestone>> getMilestones(String projectId) async =>
      _milestones.where((m) => m.projectId == projectId).toList();

  @override
  Future<void> addMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> submitMilestone(String id, String link) async {
    final i = _milestones.indexWhere((m) => m.id == id);
    if (i == -1) return;
    _milestones[i] = _milestones[i].copyWith(
        status: MilestoneStatus.submitted, submissionLink: link);
  }

  @override
  Future<void> reviewMilestone(String id, List<ChecklistItem> checklist,
      String feedback, bool approved) async {
    final i = _milestones.indexWhere((m) => m.id == id);
    if (i == -1) return;
    _milestones[i] = _milestones[i].copyWith(
      checklist: checklist,
      feedback: feedback,
      status: approved
          ? MilestoneStatus.approved
          : MilestoneStatus.changesRequested,
    );
  }

  @override
  Future<List<ProjectPost>> getPosts(String projectId) async =>
      _posts.where((p) => p.projectId == projectId).toList();

  @override
  Future<void> addPost(ProjectPost post) async => _posts.add(post);
}
