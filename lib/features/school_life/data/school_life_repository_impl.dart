import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/school_life/domain/entities/school_record.dart';
import 'package:ibnzaidon/features/school_life/domain/repositories/school_life_repository.dart';

/// Defensive parsing for endpoints without a documented response shape.
/// Assumed field names are listed in the `_*Keys` constants — verify them
/// with the backend before enabling the feature flags.
class SchoolLifeRepositoryImpl implements SchoolLifeRepository {
  const SchoolLifeRepositoryImpl({
    required ApiClient client,
    required ApiGuard guard,
  }) : _client = client,
       _guard = guard;

  static const _titleKeys = [
    'title',
    'name',
    'subject',
    'subject_name',
    'day',
    'course',
  ];
  static const _bodyKeys = [
    'body',
    'content',
    'description',
    'notes',
    'text',
    'message',
  ];
  static const _dateKeys = [
    'date',
    'published_at',
    'exam_date',
    'starts_at',
    'created_at',
  ];
  static const _signedKeys = ['is_signed', 'signed', 'has_signed'];
  static const _signedAtKeys = ['signed_at', 'signed_date'];

  final ApiClient _client;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, List<SchoolRecord>>> getRecords(
    SchoolRecordKind kind,
  ) => _guard.run(() async {
    final envelope = await _client.get(kind.path);
    return _extractList(envelope.data).map(record).toList();
  });

  @override
  Future<Either<Failure, SchoolRecord>> getAnnouncement(int id) =>
      _guard.run(() async {
        final envelope = await _client.get('announcements/$id');
        return record(asMap(envelope.data) ?? const {});
      });

  @override
  Future<Either<Failure, ConductOverview>> getConduct() => _guard.run(() async {
    final conduct = await _client.get('conduct');
    final status = await _client.get('conduct/status');
    final doc = asMap(conduct.data) ?? const <String, dynamic>{};
    final rec = record(doc);
    return ConductOverview(
      document: ConductDocument(
        title: rec.title,
        body: rec.body,
        fields: rec.fields,
      ),
      status: _status(asMap(status.data) ?? const {}),
    );
  });

  @override
  Future<Either<Failure, ConductStatus>> signConduct() => _guard.run(() async {
    final envelope = await _client.post('conduct/sign');
    final map = asMap(envelope.data) ?? const <String, dynamic>{};
    final parsed = _status(map);
    // A 2xx sign response means signed even if the body is empty.
    return ConductStatus(
      isSigned: true,
      signedAt: parsed.signedAt ?? DateTime.now(),
    );
  });

  ConductStatus _status(Map<String, dynamic> map) {
    var signed = false;
    for (final key in _signedKeys) {
      if (map.containsKey(key)) signed = parseBool(map[key]);
    }
    DateTime? signedAt;
    for (final key in _signedAtKeys) {
      signedAt ??= tryParseDate(map[key]);
    }
    return ConductStatus(isSigned: signed, signedAt: signedAt);
  }

  /// The list may be the payload itself or nested under any key.
  static List<Map<String, dynamic>> _extractList(Object? data) {
    Iterable<Object?> raw = const [];
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      for (final value in data.values) {
        if (value is List) {
          raw = value;
          break;
        }
      }
    }
    return [
      for (final item in raw)
        if (asMap(item) != null) asMap(item)!,
    ];
  }

  static SchoolRecord record(Map<String, dynamic> json) {
    String? first(List<String> keys) {
      for (final key in keys) {
        final value = tryParseString(json[key]);
        if (value != null) return value;
      }
      return null;
    }

    DateTime? date;
    for (final key in _dateKeys) {
      date ??= tryParseDate(json[key]);
    }
    final used = {..._titleKeys, ..._bodyKeys, ..._dateKeys, 'id'};
    return SchoolRecord(
      id: tryParseInt(json['id']),
      title: first(_titleKeys),
      body: first(_bodyKeys),
      date: date,
      fields: {
        for (final entry in json.entries)
          if (!used.contains(entry.key) &&
              (entry.value is String ||
                  entry.value is num ||
                  entry.value is bool))
            entry.key: entry.value.toString(),
      },
    );
  }
}
