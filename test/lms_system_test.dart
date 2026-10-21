import 'package:test/test.dart';

import '../lib/model/assignment.dart';
import '../lib/service/lms_system.dart';

void main() {
  late LmsSystem lms;

  setUp(() {
    lms = LmsSystem();
  });

  void addTwoStudentsAndCourse() {
    lms.addStudent(studentId: 'S01', studentName: 'Sophea');
    lms.addStudent(studentId: 'S02', studentName: 'Dara');
    lms.addCourse(id: 'C01', name: 'Mobile Development');
  }

  group('Students', () {
    test('add student', () {
      lms.addStudent(studentId: 'S01', studentName: 'Sophea');
      expect(lms.students.single.name, 'Sophea');
      expect(
        () => lms.addStudent(studentId: 'S01', studentName: 'Other'),
        throwsException,
      );
      expect(lms.students, hasLength(1));
    });

    test('remove student', () {
      lms.addStudent(studentId: 'S01', studentName: 'Sophea');
      lms.removeStudent(studentId: 'S01');
      expect(lms.students, isEmpty);
      expect(() => lms.removeStudent(studentId: 'S01'), throwsException);
    });

    test('remove student and their results', () {
      addTwoStudentsAndCourse();
      lms.addCourse(id: 'C02', name: 'Dart OOP');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S01', courseId: 'C02');
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 50);
      lms.addResult(studentId: 'S01', courseId: 'C02', score: 60);
      final unrelated = lms.addResult(
        studentId: 'S02', courseId: 'C01', score: 90,
      );
      lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'Widgets',
      );
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
      );
      lms.addResult(
        studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 70,
      );

      lms.removeStudent(studentId: 'S01');

      expect(lms.students.map((s) => s.id), ['S02']);
      expect(lms.courses[0].studentIds, ['S02']);
      expect(lms.courses[1].studentIds, isEmpty);
      expect(lms.results.map((r) => r.id), [unrelated.id]);
      expect(lms.courses[0].scoreIds, [unrelated.id]);
      expect(lms.courses[1].scoreIds, isEmpty);
      expect(lms.assignments, hasLength(1));
    });
  });

  group('Courses', () {
    test('add and remove course', () {
      lms.addCourse(id: 'C01', name: 'Mobile Development');
      expect(lms.courses.single.name, 'Mobile Development');
      lms.removeCourse(courseId: 'C01');
      expect(lms.courses, isEmpty);
    });

    test('duplicate course', () {
      lms.addCourse(id: 'C01', name: 'One');
      expect(() => lms.addCourse(id: 'C01', name: 'Two'), throwsException);
      expect(lms.courses, hasLength(1));
    });

    test('remove missing course', () {
      expect(() => lms.removeCourse(courseId: 'missing'), throwsException);
    });

    test('course removal cleans up results', () {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'Lab',
      );

      lms.removeCourse(courseId: 'C01');

      expect(lms.courses, isEmpty);
      expect(lms.results, isEmpty);
      expect(lms.assignments, isEmpty);
      expect(lms.students, hasLength(2));
    });
  });

  group('Enrollment', () {
    test('enroll student', () {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      expect(lms.courses.single.studentIds, ['S01']);
    });

    test('addStudentToCourse works', () {
      addTwoStudentsAndCourse();
      lms.addStudentToCourse(studentId: 'S01', courseId: 'C01');
      expect(lms.courses.single.studentIds, ['S01']);
    });

    test('missing student', () {
      lms.addCourse(id: 'C01', name: 'Course');
      expect(
        () => lms.enrollStudent(studentId: 'missing', courseId: 'C01'),
        throwsException,
      );
    });

    test('missing course', () {
      lms.addStudent(studentId: 'S01', studentName: 'Sophea');
      expect(
        () => lms.enrollStudent(studentId: 'S01', courseId: 'missing'),
        throwsException,
      );
    });

    test('duplicate enrollment', () {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      expect(
        () => lms.enrollStudent(studentId: 'S01', courseId: 'C01'),
        throwsException,
      );
      expect(lms.courses.single.studentIds, ['S01']);
    });

    test('enroll in two courses', () {
      addTwoStudentsAndCourse();
      lms.addCourse(id: 'C02', name: 'Databases');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S01', courseId: 'C02');
      expect(lms.courses.every((c) => c.studentIds.contains('S01')), isTrue);
    });
  });

  group('Unenrollment', () {
    test('remove enrollment', () {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      final other = lms.addResult(
        studentId: 'S02', courseId: 'C01', score: 95,
      );
      lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'Week 1',
      );
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
      );
      lms.addResult(
        studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 80,
      );

      lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01');

      expect(lms.students, hasLength(2));
      expect(lms.courses, hasLength(1));
      expect(lms.courses.single.studentIds, ['S02']);
      expect(lms.results.map((r) => r.id), [other.id]);
      expect(lms.courses.single.scoreIds, [other.id]);
    });

    test('remove missing enrollment', () {
      addTwoStudentsAndCourse();
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01'),
        throwsException,
      );
      expect(lms.students, hasLength(2));
      expect(lms.courses, hasLength(1));
    });

    test('unenroll with missing data', () {
      addTwoStudentsAndCourse();
      expect(
        () => lms.discardStudentFromCourse(studentId: 'ghost', courseId: 'C01'),
        throwsException,
      );
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S01', courseId: 'ghost'),
        throwsException,
      );
    });
  });

  group('Results', () {
    setUp(() {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
    });

    test('add result', () {
      final result = lms.addResult(
        studentId: 'S01', courseId: 'C01', score: 85,
      );
      expect(result.id, 'R1');
      expect(result.score, 85);
      expect(result.studentId, 'S01');
      expect(result.courseId, 'C01');
      expect(result.assignmentId, isNull);
      expect(lms.courses.single.scoreIds, [result.id]);
    });

    test('scores 0 and 100', () {
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');
      expect(lms.addResult(
        studentId: 'S01', courseId: 'C01', score: 0,
      ).score, 0);
      expect(lms.addResult(
        studentId: 'S02', courseId: 'C01', score: 100,
      ).score, 100);
    });

    test('invalid scores', () {
      for (final value in [-1, 101, double.infinity, double.nan]) {
        expect(
          () => lms.addResult(
            studentId: 'S01', courseId: 'C01', score: value,
          ),
          throwsException,
        );
      }
      expect(lms.results, isEmpty);
    });

    test('result for missing student or course', () {
      expect(
        () => lms.addResult(studentId: 'missing', courseId: 'C01', score: 80),
        throwsException,
      );
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'missing', score: 80),
        throwsException,
      );
    });

    test('result for unenrolled student', () {
      expect(
        () => lms.addResult(studentId: 'S02', courseId: 'C01', score: 80),
        throwsException,
      );
    });

    test('duplicate result', () {
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 80);
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C01', score: 90),
        throwsException,
      );
      expect(lms.results, hasLength(1));
    });

    test('results for different courses', () {
      lms.addCourse(id: 'C02', name: 'Databases');
      lms.enrollStudent(studentId: 'S01', courseId: 'C02');
      final a = lms.addResult(studentId: 'S01', courseId: 'C01', score: 80);
      final b = lms.addResult(studentId: 'S01', courseId: 'C02', score: 90);
      expect(a.id, isNot(b.id));
    });
  });

  group('Remove results', () {
    test('remove result', () {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');
      final first = lms.addResult(
        studentId: 'S01', courseId: 'C01', score: 85,
      );
      final second = lms.addResult(
        studentId: 'S02', courseId: 'C01', score: 90,
      );

      lms.removeResult(resultId: first.id);

      expect(lms.results.map((r) => r.id), [second.id]);
      expect(lms.courses.single.scoreIds, [second.id]);
      expect(lms.students, hasLength(2));
      expect(lms.courses, hasLength(1));
      expect(lms.courses.single.studentIds, ['S01', 'S02']);
    });

    test('remove missing result', () {
      expect(() => lms.removeResult(resultId: 'missing'), throwsException);
    });

    test('result IDs stay unique', () {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      final first = lms.addResult(
        studentId: 'S01', courseId: 'C01', score: 70,
      );
      lms.removeResult(resultId: first.id);
      final second = lms.addResult(
        studentId: 'S01', courseId: 'C01', score: 75,
      );
      expect(second.id, isNot(first.id));
    });
  });

  group('Assignments', () {
    setUp(() {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
    });

    test('add assignment', () {
      final assignment = lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'First lab',
      );
      expect(assignment.stage, AssignmentStage.DRAFT);
      expect(assignment.courseId, 'C01');
      expect(lms.courses.single.assignmentIds, ['A01']);
    });

    test('invalid assignment', () {
      lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'First lab',
      );
      expect(
        () => lms.addAssignment(
          assignmentId: 'A01', courseId: 'C01', title: 'Copy',
        ),
        throwsException,
      );
      expect(
        () => lms.addAssignment(
          assignmentId: 'A02', courseId: 'missing', title: 'Bad',
        ),
        throwsException,
      );
    });

    test('assignment must be published', () {
      lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'First lab',
      );
      expect(
        () => lms.addResult(
          studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 88,
        ),
        throwsException,
      );
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
      );
      final result = lms.addResult(
        studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 88,
      );
      expect(result.assignmentId, 'A01');
      expect(lms.courses.single.scoreIds, [result.id]);
    });

    test('results from different assignments', () {
      lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'Quiz',
      );
      lms.addAssignment(
        assignmentId: 'A02', courseId: 'C01', title: 'Lab',
      );
      for (final id in ['A01', 'A02']) {
        lms.changeAssignmentStage(
          assignmentId: id, stage: AssignmentStage.PUBLISHED,
        );
      }
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 80);
      lms.addResult(
        studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 85,
      );
      lms.addResult(
        studentId: 'S01', courseId: 'C01', assignmentId: 'A02', score: 90,
      );
      expect(lms.results, hasLength(3));
      expect(
        () => lms.addResult(
          studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 95,
        ),
        throwsException,
      );
    });

    test('wrong course for assignment', () {
      lms.addCourse(id: 'C02', name: 'Other');
      lms.addAssignment(
        assignmentId: 'A02', courseId: 'C02', title: 'Other lab',
      );
      lms.changeAssignmentStage(
        assignmentId: 'A02', stage: AssignmentStage.PUBLISHED,
      );
      expect(
        () => lms.addResult(
          studentId: 'S01', courseId: 'C01', assignmentId: 'A02', score: 75,
        ),
        throwsException,
      );
    });

    test('remove assignment and results', () {
      final general = lms.addResult(
        studentId: 'S01', courseId: 'C01', score: 75,
      );
      lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'Lab',
      );
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
      );
      lms.addResult(
        studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 95,
      );

      lms.removeAssignment(assignmentId: 'A01');

      expect(lms.assignments, isEmpty);
      expect(lms.courses.single.assignmentIds, isEmpty);
      expect(lms.results.map((r) => r.id), [general.id]);
      expect(lms.courses.single.scoreIds, [general.id]);
      expect(lms.students, hasLength(2));
    });

    test('remove missing assignment', () {
      expect(
        () => lms.removeAssignment(assignmentId: 'missing'),
        throwsException,
      );
    });
  });

  group('Assignment stages', () {
    setUp(() {
      addTwoStudentsAndCourse();
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.addAssignment(
        assignmentId: 'A01', courseId: 'C01', title: 'Quiz',
      );
    });

    test('assignment stages', () {
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
      );
      expect(lms.assignments.single.stage, AssignmentStage.PUBLISHED);
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.CLOSED,
      );
      expect(lms.assignments.single.stage, AssignmentStage.CLOSED);
    });

    test('wrong stage changes', () {
      expect(
        () => lms.changeAssignmentStage(
          assignmentId: 'A01', stage: AssignmentStage.CLOSED,
        ),
        throwsException,
      );
      expect(
        () => lms.changeAssignmentStage(
          assignmentId: 'A01', stage: AssignmentStage.DRAFT,
        ),
        throwsException,
      );
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
      );
      expect(
        () => lms.changeAssignmentStage(
          assignmentId: 'A01', stage: AssignmentStage.DRAFT,
        ),
        throwsException,
      );
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.CLOSED,
      );
      expect(
        () => lms.changeAssignmentStage(
          assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
        ),
        throwsException,
      );
    });

    test('update published result', () {
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
      );
      final result = lms.addResult(
        studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 65,
      );
      lms.updateResult(resultId: result.id, score: 82.5);
      expect(result.score, 82.5);
    });

    test('closed assignment', () {
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.PUBLISHED,
      );
      final result = lms.addResult(
        studentId: 'S01', courseId: 'C01', assignmentId: 'A01', score: 80,
      );
      lms.changeAssignmentStage(
        assignmentId: 'A01', stage: AssignmentStage.CLOSED,
      );
      expect(
        () => lms.updateResult(resultId: result.id, score: 90),
        throwsException,
      );
      expect(
        () => lms.addResult(
          studentId: 'S02', courseId: 'C01', assignmentId: 'A01', score: 90,
        ),
        throwsException,
      );
      expect(result.score, 80);
    });

    test('update course result', () {
      final result = lms.addResult(
        studentId: 'S01', courseId: 'C01', score: 40,
      );
      lms.updateResult(resultId: result.id, score: 60);
      expect(result.score, 60);
      expect(
        () => lms.updateResult(resultId: result.id, score: -4),
        throwsException,
      );
      expect(result.score, 60);
      expect(
        () => lms.updateResult(resultId: 'missing', score: 75),
        throwsException,
      );
    });
  });
}
