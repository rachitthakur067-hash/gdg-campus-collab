enum TaskStatus { todo, doing, done }

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'To do',
        TaskStatus.doing => 'In progress',
        TaskStatus.done => 'Done',
      };
}

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class WorkTask {
  const WorkTask({
    required this.id,
    required this.projectId,
    required this.title,
    required this.assignee,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
  });

  final String id;
  final String projectId;
  final String title;
  final String assignee;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;

  WorkTask copyWith({TaskStatus? status}) => WorkTask(
        id: id,
        projectId: projectId,
        title: title,
        assignee: assignee,
        dueDate: dueDate,
        priority: priority,
        status: status ?? this.status,
      );
}

class ChecklistItem {
  const ChecklistItem(this.text, {this.done = false});
  final String text;
  final bool done;

  ChecklistItem copyWith({bool? done}) =>
      ChecklistItem(text, done: done ?? this.done);
}

enum MilestoneStatus { notSubmitted, submitted, changesRequested, approved }

extension MilestoneStatusX on MilestoneStatus {
  String get label => switch (this) {
        MilestoneStatus.notSubmitted => 'Not submitted',
        MilestoneStatus.submitted => 'Submitted',
        MilestoneStatus.changesRequested => 'Changes requested',
        MilestoneStatus.approved => 'Approved',
      };
}

class Milestone {
  const Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.dueDate,
    required this.checklist,
    this.status = MilestoneStatus.notSubmitted,
    this.submissionLink = '',
    this.feedback = '',
  });

  final String id;
  final String projectId;
  final String title;
  final DateTime dueDate;
  final List<ChecklistItem> checklist;
  final MilestoneStatus status;
  final String submissionLink;
  final String feedback;

  Milestone copyWith({
    MilestoneStatus? status,
    String? submissionLink,
    String? feedback,
    List<ChecklistItem>? checklist,
  }) =>
      Milestone(
        id: id,
        projectId: projectId,
        title: title,
        dueDate: dueDate,
        checklist: checklist ?? this.checklist,
        status: status ?? this.status,
        submissionLink: submissionLink ?? this.submissionLink,
        feedback: feedback ?? this.feedback,
      );
}

/// A comment or announcement in the project discussion.
class ProjectPost {
  const ProjectPost({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.text,
    required this.createdAt,
    this.isAnnouncement = false,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String authorName;
  final String authorRole; // 'Client' or 'Team'
  final String text;
  final DateTime createdAt;
  final bool isAnnouncement;
}
