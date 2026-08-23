/// Coordinates asynchronous conversion work so only the newest request may
/// publish a result into presentation state.
///
/// This is deliberately independent from Flutter widgets and from the native
/// bridge implementation. A future controller can route both Dart and Rust
/// work through this gate without allowing a slower, older request to overwrite
/// a newer input or selection.
final class LatestConversionRequest {
  int _generation = 0;
  bool _disposed = false;

  int get generation => _generation;
  bool get isDisposed => _disposed;

  /// Runs one asynchronous operation and publishes callbacks only when this
  /// request is still the newest live request when the operation completes.
  Future<void> run<T>({
    required Future<T> Function() operation,
    required void Function(T value) onSuccess,
    required void Function(Object error, StackTrace stackTrace) onFailure,
  }) async {
    if (_disposed) {
      throw StateError('LatestConversionRequest has been disposed.');
    }

    final requestGeneration = ++_generation;
    try {
      final value = await operation();
      if (_disposed || requestGeneration != _generation) {
        return;
      }
      onSuccess(value);
    } on Object catch (error, stackTrace) {
      if (_disposed || requestGeneration != _generation) {
        return;
      }
      onFailure(error, stackTrace);
    }
  }

  /// Invalidates any in-flight request without starting replacement work.
  void invalidate() {
    if (_disposed) {
      return;
    }
    _generation += 1;
  }

  /// Permanently invalidates pending work and rejects future [run] calls.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _generation += 1;
  }
}
