import '../logging/app_log.dart';

/// Records the exception type without exposing exception text or user content, then
/// returns a stable message suitable for display in the UI.
String userSafeFailure(
  Object error, {
  required String event,
  required String fallback,
}) {
  AppLog.write(
    LogLevel.error,
    event,
    fields: <String, Object?>{'error_type': error.runtimeType.toString()},
  );
  return fallback;
}
