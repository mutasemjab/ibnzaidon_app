import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/core/storage/key_value_store.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/domain/repositories/exams_repository.dart';

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<void> setBool(String key, {required bool value}) async =>
      _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Iterable<String> get keys => _data.keys;
}

class FixedLocale implements LocaleCodeProvider {
  const FixedLocale([this.languageCode = 'ar']);

  @override
  final String languageCode;
}

class InMemoryExamDrafts implements ExamDraftRepository {
  final Map<int, ExamDraft> drafts = {};

  @override
  ExamDraft? load(int attemptId) => drafts[attemptId];

  @override
  Future<void> save(int attemptId, ExamDraft draft) async =>
      drafts[attemptId] = draft;

  @override
  Future<void> clear(int attemptId) async => drafts.remove(attemptId);
}
