import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/library/domain/entities/library_item.dart';
import 'package:ibnzaidon/features/library/domain/repositories/library_repositories.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';
import 'package:ibnzaidon/shared/data/paged_parser.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  const LibraryRepositoryImpl({
    required ApiClient client,
    required ApiGuard guard,
  }) : _client = client,
       _guard = guard;

  final ApiClient _client;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, PagedList<LibraryItem>>> getItems(
    LibraryKind kind,
    int page,
    LibraryQuery query,
  ) => _guard.run(() async {
    final envelope = await _client.get(
      kind.path,
      optionalAuth: true,
      query: {
        'page': page,
        'search': query.search.trim(),
        'subject_id': query.subjectId,
        'year': query.year,
        if (kind == LibraryKind.worksheets) 'class_id': query.classId,
      },
    );
    return pagedFromEnvelope<LibraryItem>(envelope, _item);
  });

  static LibraryItem _item(Map<String, dynamic> json) => LibraryItem(
    id: parseInt(json['id']),
    title: parseString(json['title']),
    pdfUrl: tryParseString(json['pdf_url']),
    tag: tryParseString(json['tag']),
    year: tryParseInt(json['year']),
    pages: parseInt(json['pages']),
    fileSize: _fileSize(json['file_size']),
    subject: parseIdName(json['subject']),
    teacher: parseIdName(json['teacher']),
    classInfo: parseIdName(json['class']),
  );

  /// `file_size` may be a preformatted string ("2.4 MB") or raw bytes.
  static String? _fileSize(Object? raw) {
    if (raw is num) {
      final mb = raw / (1024 * 1024);
      return mb >= 1
          ? '${mb.toStringAsFixed(1)} MB'
          : '${(raw / 1024).toStringAsFixed(0)} KB';
    }
    return tryParseString(raw);
  }
}
