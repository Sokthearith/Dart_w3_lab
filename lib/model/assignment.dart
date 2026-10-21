enum AssignmentStage { DRAFT, PUBLISHED, CLOSED }

class Assignment {
  final String id;
  final String courseId;
  final String title;
  AssignmentStage stage;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    this.stage = AssignmentStage.DRAFT,
  });
}
