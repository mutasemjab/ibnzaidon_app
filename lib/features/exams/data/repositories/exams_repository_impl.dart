import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/storage/key_value_store.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/exams/data/models/exam_models.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/domain/repositories/exams_repository.dart';
import 'package:ibnzaidon/shared/data/paged_parser.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

class ExamsRepositoryImpl implements ExamsRepository {
  const ExamsRepositoryImpl({
    required ApiClient client,
    required ApiGuard guard,
  }) : _client = client,
       _guard = guard;

  final ApiClient _client;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, PagedList<Exam>>> getExams(
    int page,
    ExamQuery query,
  ) => _guard.run(() async {
    final envelope = await _client.get(
      'exams',
      query: {
        'page': page,
        'search': query.search.trim(),
        'course_id': query.courseId,
        'subject_id': query.subjectId,
        'exam_type': query.examType,
      },
    );
    return pagedFromEnvelope<Exam>(envelope, ExamModels.exam);
  });

  @override
  Future<Either<Failure, ExamDetail>> getExamDetail(int id) =>
      _guard.run(() async {
        final envelope = await _client.get('exams/$id', optionalAuth: true);
        return ExamModels.detail(envelope.dataMap);
      });

  /// 201 = new attempt, 200 = an in-progress attempt exists (resume it).
  @override
  Future<Either<Failure, ExamAttemptSession>> startExam(int id) =>
      _guard.run(() async {
        final response = await _client.postRaw('exams/$id/start');
        final data = response.envelope.dataMap;
        var detail = ExamModels.detail(data);
        if (detail.questions.isEmpty) {
          final fetched = await _client.get('exams/$id', optionalAuth: true);
          detail = ExamModels.detail(fetched.dataMap);
        }
        return ExamAttemptSession(
          attemptId: parseInt(data['attempt_id']),
          startedAt: tryParseDate(data['started_at']),
          detail: detail,
          resumed: response.statusCode == 200,
        );
      });

  @override
  Future<Either<Failure, ExamResult>> submitAttempt(
    int attemptId,
    Map<int, int> answers,
  ) => _guard.run(() async {
    final envelope = await _client.post(
      'attempts/$attemptId/submit',
      body: {
        'answers': [
          for (final entry in answers.entries)
            {'question_id': entry.key, 'option_id': entry.value},
        ],
      },
    );
    return ExamModels.result(envelope.dataMap);
  });

  @override
  Future<Either<Failure, PagedList<AttemptHistoryItem>>> getMyExams(int page) =>
      _guard.run(() async {
        final envelope = await _client.get('my-exams', query: {'page': page});
        return pagedFromEnvelope<AttemptHistoryItem>(
          envelope,
          ExamModels.history,
        );
      });
}

/// Persists in-progress answers as JSON keyed by attempt id.
class ExamDraftRepositoryImpl implements ExamDraftRepository {
  const ExamDraftRepositoryImpl(this._store);

  static const _prefix = 'exam.draft.';

  final KeyValueStore _store;

  String _key(int attemptId) => '$_prefix$attemptId';

  @override
  ExamDraft? load(int attemptId) {
    final json = asMap(_store.getJson(_key(attemptId)));
    if (json == null) return null;
    final startedAt = tryParseDate(json['local_started_at']);
    if (startedAt == null) return null;
    final answers = asMap(json['answers']) ?? const {};
    return ExamDraft(
      localStartedAt: startedAt,
      answers: {
        for (final entry in answers.entries)
          if (int.tryParse(entry.key) != null &&
              tryParseInt(entry.value) != null)
            int.parse(entry.key): tryParseInt(entry.value)!,
      },
      flagged: {
        for (final id in asList(json['flagged']))
          if (tryParseInt(id) != null) tryParseInt(id)!,
      },
      currentIndex: parseInt(json['current_index']),
    );
  }

  @override
  Future<void> save(int attemptId, ExamDraft draft) => _store.setJson(
    _key(attemptId),
    {
      'local_started_at': draft.localStartedAt.toIso8601String(),
      'answers': {
        for (final entry in draft.answers.entries) '${entry.key}': entry.value,
      },
      'flagged': draft.flagged.toList(),
      'current_index': draft.currentIndex,
    },
  );

  @override
  Future<void> clear(int attemptId) => _store.remove(_key(attemptId));
}
