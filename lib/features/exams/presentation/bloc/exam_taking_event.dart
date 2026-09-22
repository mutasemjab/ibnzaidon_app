import 'package:equatable/equatable.dart';

sealed class ExamTakingEvent extends Equatable {
  const ExamTakingEvent();

  @override
  List<Object?> get props => [];
}

final class ExamAttemptStarted extends ExamTakingEvent {
  const ExamAttemptStarted();
}

final class ExamOptionSelected extends ExamTakingEvent {
  const ExamOptionSelected({required this.questionId, required this.optionId});

  final int questionId;
  final int optionId;

  @override
  List<Object?> get props => [questionId, optionId];
}

final class ExamAnswerCleared extends ExamTakingEvent {
  const ExamAnswerCleared(this.questionId);

  final int questionId;

  @override
  List<Object?> get props => [questionId];
}

final class ExamQuestionFlagToggled extends ExamTakingEvent {
  const ExamQuestionFlagToggled(this.questionId);

  final int questionId;

  @override
  List<Object?> get props => [questionId];
}

final class ExamQuestionSelected extends ExamTakingEvent {
  const ExamQuestionSelected(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class ExamSubmitRequested extends ExamTakingEvent {
  const ExamSubmitRequested({this.auto = false});

  final bool auto;

  @override
  List<Object?> get props => [auto];
}

final class ExamTicked extends ExamTakingEvent {
  const ExamTicked();
}

/// Timer, autosave, resume and submit for one exam attempt.
