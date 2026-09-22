import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';

/// Exam payload fields are only partly specified by the contract; every
/// field is read defensively with nullable fallbacks.
abstract final class ExamModels {
  static Exam exam(Map<String, dynamic> json) => Exam(
    id: parseInt(json['id']),
    title: parseString(json['title']),
    description: tryParseString(json['description']),
    instructions: tryParseString(json['instructions']),
    examType: tryParseString(json['exam_type']),
    durationMinutes: parseInt(json['duration_minutes']),
    totalQuestions: parseInt(
      json['total_questions'] ??
          json['questions_count'] ??
          asList(json['questions']).length,
    ),
    totalMarks: parseDouble(json['total_marks']),
    passingMarks: tryParseDouble(json['passing_marks'] ?? json['pass_marks']),
    difficulty: tryParseString(json['difficulty_level'] ?? json['difficulty']),
    showResultImmediately: parseBool(json['show_result_immediately']),
    course: parseIdName(json['course']),
    subject: parseIdName(json['subject']),
  );

  static QuestionOption option(Map<String, dynamic> json) => QuestionOption(
    id: parseInt(json['id']),
    text: parseString(json['option_text'] ?? json['text']),
  );

  static Question question(Map<String, dynamic> json) => Question(
    id: parseInt(json['id']),
    text: parseString(json['question_text'] ?? json['text']),
    type: tryParseString(json['question_type']),
    marks: parseDouble(json['marks']),
    imageUrl: tryParseString(json['image']),
    options: mapList(json['options'], option),
  );

  static ExamDetail detail(Map<String, dynamic> data) {
    final examJson = asMap(data['exam']) ?? data;
    final questions = mapList(
      examJson['questions'] ?? data['questions'],
      question,
    );
    return ExamDetail(exam: exam(examJson), questions: questions);
  }

  static AnswerReview review(Map<String, dynamic> json) => AnswerReview(
    questionId: parseInt(json['question_id']),
    questionText: parseString(json['question_text']),
    selectedOptionId: tryParseInt(json['selected_option_id']),
    isCorrect: parseBool(json['is_correct']),
    marksEarned: parseDouble(json['marks_earned']),
    correctOptionId: tryParseInt(json['correct_option_id']),
    correctOption: tryParseString(json['correct_option']),
    explanation: tryParseString(json['explanation']),
  );

  static ExamResult result(Map<String, dynamic> data) {
    final reviewsRaw = data['answers'];
    return ExamResult(
      attemptId: parseInt(data['attempt_id']),
      score: parseDouble(data['score']),
      totalMarks: parseDouble(data['total_marks']),
      // The API reports 0..100.
      percentage: normalizeProgress(data['percentage'], isPercentage: true),
      isPassed: parseBool(data['is_passed']),
      correctAnswers: parseInt(data['correct_answers']),
      wrongAnswers: parseInt(data['wrong_answers']),
      unanswered: parseInt(data['unanswered']),
      timeTakenMinutes: parseDouble(data['time_taken_minutes']),
      reviews: reviewsRaw is List ? mapList(reviewsRaw, review) : null,
    );
  }

  static AttemptHistoryItem history(Map<String, dynamic> json) {
    final examJson = asMap(json['exam']) ?? const <String, dynamic>{};
    return AttemptHistoryItem(
      attemptId: parseInt(json['attempt_id'] ?? json['id']),
      examId: parseInt(examJson['id']),
      examTitle: parseString(examJson['title']),
      score: parseDouble(json['score']),
      totalMarks: parseDouble(json['total_marks']),
      percentage: normalizeProgress(json['percentage'], isPercentage: true),
      isPassed: parseBool(json['is_passed']),
      timeTakenMinutes: parseDouble(json['time_taken_minutes']),
      submittedAt: tryParseDate(json['submitted_at']),
      examType: tryParseString(examJson['exam_type']),
      courseName:
          parseIdName(examJson['course'])?.name ??
          tryParseString(examJson['course']),
      subjectName:
          parseIdName(examJson['subject'])?.name ??
          tryParseString(examJson['subject']),
    );
  }
}
