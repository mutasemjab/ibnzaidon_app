/// Abstraction over Crashlytics so features and tests never import Firebase.
abstract interface class CrashReporter {
  void recordError(Object error, StackTrace? stackTrace, {String? reason});
}

final class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  void recordError(Object error, StackTrace? stackTrace, {String? reason}) {}
}
