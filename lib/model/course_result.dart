class CourseResult {
  final String id;
  final String studentId;
  final String courseId;
  final String? assignmentId;
  double score;

  CourseResult({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.score,
    this.assignmentId,
  });
}
