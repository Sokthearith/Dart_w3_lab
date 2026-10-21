import '../lib/model/assignment.dart';
import '../lib/service/lms_system.dart';

void main() {
  final lms = LmsSystem();

  lms.addStudent(studentId: 'S01', studentName: 'Sophea');
  lms.addStudent(studentId: 'S02', studentName: 'Dara');
  lms.addCourse(id: 'C01', name: 'Mobile Development');

  lms.enrollStudent(studentId: 'S01', courseId: 'C01');
  lms.enrollStudent(studentId: 'S02', courseId: 'C01');

  lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
  lms.addResult(studentId: 'S02', courseId: 'C01', score: 92);

  lms.addAssignment(
    assignmentId: 'A01',
    courseId: 'C01',
    title: 'Flutter Widgets',
  );
  lms.changeAssignmentStage(
    assignmentId: 'A01',
    stage: AssignmentStage.PUBLISHED,
  );

  print(lms.students.map((s) => s.name).toList());
  print(lms.courses.first.studentIds);
  print(lms.results.map((r) => r.score).toList());
}
