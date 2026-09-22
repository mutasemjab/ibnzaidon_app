import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

class Exam extends Equatable {
  const Exam({
    required this.id,
    required this.title,
    this.description,
    this.instructions,
    this.examType,
    this.durationMinutes = 0,
    this.totalQuestions = 0,
    this.totalMarks = 0,
    this.passingMarks,
    this.difficulty,
    this.showResultImmediately = false,
    this.course,
    this.subject,
  });

  final int id;
  final String title;
  final String? description;
  final String? instructions;
  final String? examType;
  final int durationMinutes;
  final int totalQuestions;
  final double totalMarks;
  final double? passingMarks;
  final String? difficulty;
  final bool showResultImmediately;
  final IdName? course;
  final IdName? subject;

  Duration get duration => Duration(minutes: durationMinutes);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    instructions,
    examType,
    durationMinutes,
    totalQuestions,
    totalMarks,
    passingMarks,
    difficulty,
    showResultImmediately,
    course,
    subject,
  ];
}

class QuestionOption extends Equatable {
  const QuestionOption({required this.id, required this.text});

  final int id;
  final String text;

  @override
  List<Object?> get props => [id, text];
}

class Question extends Equatable {
  const Question({
    required this.id,
    required this.text,
    this.type,
    this.marks = 0,
    this.imageUrl,
    this.options = const [],
  });

  final int id;
  final String text;
  final String? type;
  final double marks;
  final String? imageUrl;
  final List<QuestionOption> options;

  @override
  List<Object?> get props => [id, text, type, marks, imageUrl, options];
}

class ExamDetail extends Equatable {
  const ExamDetail({required this.exam, required this.questions});

  final Exam exam;
  final List<Question> questions;

  @override
  List<Object?> get props => [exam, questions];
}

/// An in-progress attempt (`POST exams/{id}/start`).
class ExamAttemptSession extends Equatable {
  const ExamAttemptSession({
    required this.attemptId,
    required this.startedAt,
    required this.detail,
    required this.resumed,
  });

  final int attemptId;
  final DateTime? startedAt;
  final ExamDetail detail;

  /// `true` when the server returned 200 for an existing attempt.
  final bool resumed;

  @override
  List<Object?> get props => [attemptId, startedAt, detail, resumed];
}

class AnswerReview extends Equatable {
  const AnswerReview({
    required this.questionId,
    required this.questionText,
    required this.isCorrect,
    this.selectedOptionId,
    this.marksEarned = 0,
    this.correctOptionId,
    this.correctOption,
    this.explanation,
  });

  final int questionId;
  final String questionText;
  final int? selectedOptionId;
  final bool isCorrect;
  final double marksEarned;
  final int? correctOptionId;
  final String? correctOption;
  final String? explanation;

  @override
  List<Object?> get props => [
    questionId,
    questionText,
    selectedOptionId,
    isCorrect,
    marksEarned,
    correctOptionId,
    correctOption,
    explanation,
  ];
}

class ExamResult extends Equatable {
  const ExamResult({
    required this.attemptId,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.isPassed,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.unanswered = 0,
    this.timeTakenMinutes = 0,
    this.reviews,
  });

  final int attemptId;
  final double score;
  final double totalMarks;

  /// 0..1
  final double percentage;
  final bool isPassed;
  final int correctAnswers;
  final int wrongAnswers;
  final int unanswered;
  final double timeTakenMinutes;

  /// Present only when the exam's `show_result_immediately` is true.
  final List<AnswerReview>? reviews;

  @override
  List<Object?> get props => [
    attemptId,
    score,
    totalMarks,
    percentage,
    isPassed,
    correctAnswers,
    wrongAnswers,
    unanswered,
    timeTakenMinutes,
    reviews,
  ];
}

class AttemptHistoryItem extends Equatable {
  const AttemptHistoryItem({
    required this.attemptId,
    required this.examId,
    required this.examTitle,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.isPassed,
    this.timeTakenMinutes = 0,
    this.submittedAt,
    this.examType,
    this.courseName,
    this.subjectName,
  });

  final int attemptId;
  final int examId;
  final String examTitle;
  final double score;
  final double totalMarks;
  final double percentage;
  final bool isPassed;
  final double timeTakenMinutes;
  final DateTime? submittedAt;
  final String? examType;
  final String? courseName;
  final String? subjectName;

  @override
  List<Object?> get props => [
    attemptId,
    examId,
    examTitle,
    score,
    totalMarks,
    percentage,
    isPassed,
    timeTakenMinutes,
    submittedAt,
    examType,
    courseName,
    subjectName,
  ];
}

class ExamQuery extends Equatable {
  const ExamQuery({
    this.search = '',
    this.courseId,
    this.subjectId,
    this.examType,
  });

  final String search;
  final int? courseId;
  final int? subjectId;
  final String? examType;

  ExamQuery copyWith({
    String? search,
    String? examType,
    bool clearType = false,
  }) => ExamQuery(
    search: search ?? this.search,
    courseId: courseId,
    subjectId: subjectId,
    examType: clearType ? null : examType ?? this.examType,
  );

  @override
  List<Object?> get props => [search, courseId, subjectId, examType];
}

/// Locally persisted attempt state so answers survive an app kill.
class ExamDraft extends Equatable {
  const ExamDraft({
    required this.localStartedAt,
    this.answers = const {},
    this.flagged = const {},
    this.currentIndex = 0,
  });

  final DateTime localStartedAt;
  final Map<int, int> answers;
  final Set<int> flagged;
  final int currentIndex;

  @override
  List<Object?> get props => [localStartedAt, answers, flagged, currentIndex];
}
