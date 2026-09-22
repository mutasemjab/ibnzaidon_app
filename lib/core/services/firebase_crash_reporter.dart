import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:ibnzaidon/core/error/crash_reporter.dart';

final class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  void recordError(Object error, StackTrace? stackTrace, {String? reason}) {
    _crashlytics.recordError(error, stackTrace, reason: reason);
  }
}
