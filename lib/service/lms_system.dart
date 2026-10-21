import '../model/assignment.dart';
import '../model/course.dart';
import '../model/course_result.dart';
import '../model/student.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];
  final List<Assignment> assignments = [];

  int _nextResultId = 1;

  void addStudent({required String studentId, required String studentName}) {
    if (_findStudentOrNull(studentId) != null) {
      throw Exception('Student $studentId already exists');
    }
    students.add(Student(id: studentId, name: studentName));
  }

  void removeStudent({required String studentId}) {
    _requireStudent(studentId);

    for (final course in courses) {
      course.studentIds.remove(studentId);
    }

    for (final result in results.where((r) => r.studentId == studentId).toList()) {
      _deleteResult(result);
    }
    students.removeWhere((s) => s.id == studentId);
  }

  void addCourse({required String id, required String name}) {
    if (_findExistingCourse(id) != null) {
      throw Exception('Course $id already exists');
    }
    courses.add(Course(id: id, name: name));
  }

  void removeCourse({required String courseId}) {
    _requireCourse(courseId);

    for (final result in results.where((r) => r.courseId == courseId).toList()) {
      _deleteResult(result);
    }
    assignments.removeWhere((a) => a.courseId == courseId);
    courses.removeWhere((c) => c.id == courseId);
  }

  void enrollStudent({required String studentId, required String courseId}) {
    _requireStudent(studentId);
    final course = _requireCourse(courseId);
    if (course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is already enrolled in $courseId');
    }
    course.studentIds.add(studentId);
  }

  void addStudentToCourse({required String studentId, required String courseId}) {
    enrollStudent(studentId: studentId, courseId: courseId);
  }

  void discardStudentFromCourse({
    required String studentId,
    required String courseId,
  }) {
    _requireStudent(studentId);
    final course = _requireCourse(courseId);
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in $courseId');
    }

    for (final result in results
        .where((r) => r.studentId == studentId && r.courseId == courseId)
        .toList()) {
      _deleteResult(result);
    }
    course.studentIds.remove(studentId);
  }

  CourseResult addResult({
    required String studentId,
    required String courseId,
    required num score,
    String? assignmentId,
  }) {
    _requireStudent(studentId);
    final course = _requireCourse(courseId);
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in $courseId');
    }
    _validateScore(score);

    if (assignmentId != null) {
      final assignment = _requireAssignment(assignmentId);
      if (assignment.courseId != courseId) {
        throw Exception('Assignment $assignmentId does not belong to $courseId');
      }
      if (assignment.stage != AssignmentStage.PUBLISHED) {
        throw Exception('Assignment $assignmentId is not open for results');
      }
    }

    final exists = results.any((r) =>
        r.studentId == studentId &&
        r.courseId == courseId &&
        r.assignmentId == assignmentId);
    if (exists) {
      throw Exception('This student already has a result');
    }

    final result = CourseResult(
      id: 'R${_nextResultId++}',
      studentId: studentId,
      courseId: courseId,
      score: score.toDouble(),
      assignmentId: assignmentId,
    );
    results.add(result);
    course.scoreIds.add(result.id);
    return result;
  }

  void removeResult({required String resultId}) {
    final result = _requireResult(resultId);
    _deleteResult(result);
  }

  void updateResult({required String resultId, required num score}) {
    final result = _requireResult(resultId);
    _validateScore(score);
    if (result.assignmentId != null) {
      final assignment = _requireAssignment(result.assignmentId!);
      if (assignment.stage != AssignmentStage.PUBLISHED) {
        throw Exception('Assignment is not published');
      }
    }
    result.score = score.toDouble();
  }

  Assignment addAssignment({
    required String assignmentId,
    required String courseId,
    required String title,
  }) {
    final course = _requireCourse(courseId);
    if (_findAssignmentOrNull(assignmentId) != null) {
      throw Exception('Assignment $assignmentId already exists');
    }
    final assignment = Assignment(
      id: assignmentId,
      courseId: courseId,
      title: title,
    );
    assignments.add(assignment);
    course.assignmentIds.add(assignmentId);
    return assignment;
  }

  void removeAssignment({required String assignmentId}) {
    final assignment = _requireAssignment(assignmentId);

    for (final result in results
        .where((r) => r.assignmentId == assignmentId)
        .toList()) {
      _deleteResult(result);
    }
    _requireCourse(assignment.courseId).assignmentIds.remove(assignmentId);
    assignments.removeWhere((a) => a.id == assignmentId);
  }

  void changeAssignmentStage({
    required String assignmentId,
    required AssignmentStage stage,
  }) {
    final assignment = _requireAssignment(assignmentId);
    final canChange =
        (assignment.stage == AssignmentStage.DRAFT &&
            stage == AssignmentStage.PUBLISHED) ||
        (assignment.stage == AssignmentStage.PUBLISHED &&
            stage == AssignmentStage.CLOSED);
    if (!canChange) {
      throw Exception(
        'Invalid assignment stage: ${assignment.stage.name} -> ${stage.name}',
      );
    }
    assignment.stage = stage;
  }

  Student? _findStudentOrNull(String studentId) {
    for (final student in students) {
      if (student.id == studentId) return student;
    }
    return null;
  }

  Course? _findExistingCourse(String courseId) {
    for (final course in courses) {
      if (course.id == courseId) return course;
    }
    return null;
  }

  Assignment? _findAssignmentOrNull(String assignmentId) {
    for (final assignment in assignments) {
      if (assignment.id == assignmentId) return assignment;
    }
    return null;
  }

  Student _requireStudent(String studentId) {
    final student = _findStudentOrNull(studentId);
    if (student == null) throw Exception('Student $studentId does not exist');
    return student;
  }

  Course _requireCourse(String courseId) {
    final course = _findExistingCourse(courseId);
    if (course == null) throw Exception('Course $courseId does not exist');
    return course;
  }

  Assignment _requireAssignment(String assignmentId) {
    final assignment = _findAssignmentOrNull(assignmentId);
    if (assignment == null) {
      throw Exception('Assignment $assignmentId does not exist');
    }
    return assignment;
  }

  CourseResult _requireResult(String resultId) {
    for (final result in results) {
      if (result.id == resultId) return result;
    }
    throw Exception('Result $resultId does not exist');
  }

  void _validateScore(num score) {
    if (!score.isFinite || score < 0 || score > 100) {
      throw Exception('Score must be between 0 and 100');
    }
  }

  void _deleteResult(CourseResult result) {
    results.removeWhere((r) => r.id == result.id);
    _findExistingCourse(result.courseId)?.scoreIds.remove(result.id);
  }
}
