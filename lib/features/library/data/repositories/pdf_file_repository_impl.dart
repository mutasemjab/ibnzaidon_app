import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/crash_reporter.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/stable_hash.dart';
import 'package:ibnzaidon/features/library/domain/repositories/library_repositories.dart';
import 'package:path_provider/path_provider.dart';

class PdfFileRepositoryImpl implements PdfFileRepository {
  const PdfFileRepositoryImpl({
    required ApiClient client,
    required ApiGuard guard,
    required CrashReporter crashReporter,
  }) : _client = client,
       _guard = guard,
       _crashReporter = crashReporter;

  final ApiClient _client;
  final ApiGuard _guard;
  final CrashReporter _crashReporter;

  Future<File> _fileFor(String url) async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory('${base.path}/pdf_cache');
    if (!directory.existsSync()) await directory.create(recursive: true);
    return File('${directory.path}/${stableHash(url)}.pdf');
  }

  @override
  Future<String?> cachedPath(String url) async {
    try {
      final file = await _fileFor(url);
      return file.existsSync() && file.lengthSync() > 0 ? file.path : null;
    } on Object catch (error, stackTrace) {
      _crashReporter.recordError(error, stackTrace, reason: 'pdf cache');
      return null;
    }
  }

  @override
  Future<Either<Failure, String>> download(
    String url, {
    void Function(double progress)? onProgress,
  }) => _guard.run(() async {
    final target = await _fileFor(url);
    final partial = File('${target.path}.part');
    await _client.download(
      url,
      partial.path,
      onProgress: (received, total) {
        if (total > 0) onProgress?.call(received / total);
      },
    );
    await partial.rename(target.path);
    return target.path;
  });
}
