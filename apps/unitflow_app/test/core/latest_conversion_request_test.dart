import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/features/converter/domain/latest_conversion_request.dart';

void main() {
  test('newer request prevents older success from publishing', () async {
    final coordinator = LatestConversionRequest();
    final first = Completer<String>();
    final second = Completer<String>();
    final published = <String>[];

    final firstRun = coordinator.run<String>(
      operation: () => first.future,
      onSuccess: published.add,
      onFailure: (error, stackTrace) => fail('Unexpected failure: $error'),
    );
    final secondRun = coordinator.run<String>(
      operation: () => second.future,
      onSuccess: published.add,
      onFailure: (error, stackTrace) => fail('Unexpected failure: $error'),
    );

    second.complete('newest');
    await secondRun;
    first.complete('stale');
    await firstRun;

    expect(published, <String>['newest']);
  });

  test('stale failure is ignored after a newer request starts', () async {
    final coordinator = LatestConversionRequest();
    final first = Completer<String>();
    final second = Completer<String>();
    final failures = <Object>[];
    final published = <String>[];

    final firstRun = coordinator.run<String>(
      operation: () => first.future,
      onSuccess: published.add,
      onFailure: (error, stackTrace) => failures.add(error),
    );
    final secondRun = coordinator.run<String>(
      operation: () => second.future,
      onSuccess: published.add,
      onFailure: (error, stackTrace) => failures.add(error),
    );

    first.completeError(StateError('stale failure'));
    await firstRun;
    second.complete('current');
    await secondRun;

    expect(failures, isEmpty);
    expect(published, <String>['current']);
  });

  test('current failure is delivered with its stack trace', () async {
    final coordinator = LatestConversionRequest();
    Object? publishedError;
    StackTrace? publishedStack;

    await coordinator.run<String>(
      operation: () async => throw StateError('current failure'),
      onSuccess: (value) => fail('Unexpected success: $value'),
      onFailure: (error, stackTrace) {
        publishedError = error;
        publishedStack = stackTrace;
      },
    );

    expect(publishedError, isA<StateError>());
    expect(publishedStack, isNotNull);
  });

  test('invalidate drops an in-flight result without disposing coordinator', () async {
    final coordinator = LatestConversionRequest();
    final pending = Completer<int>();
    final published = <int>[];

    final run = coordinator.run<int>(
      operation: () => pending.future,
      onSuccess: published.add,
      onFailure: (error, stackTrace) => fail('Unexpected failure: $error'),
    );
    final generationBeforeInvalidate = coordinator.generation;

    coordinator.invalidate();
    pending.complete(42);
    await run;

    expect(coordinator.generation, greaterThan(generationBeforeInvalidate));
    expect(coordinator.isDisposed, isFalse);
    expect(published, isEmpty);
  });

  test('dispose drops pending work and rejects future requests', () async {
    final coordinator = LatestConversionRequest();
    final pending = Completer<int>();
    var callbackCount = 0;

    final run = coordinator.run<int>(
      operation: () => pending.future,
      onSuccess: (value) => callbackCount += 1,
      onFailure: (error, stackTrace) => callbackCount += 1,
    );

    coordinator.dispose();
    pending.complete(1);
    await run;

    expect(coordinator.isDisposed, isTrue);
    expect(callbackCount, 0);
    expect(
      () => coordinator.run<int>(
        operation: () async => 2,
        onSuccess: (value) {},
        onFailure: (error, stackTrace) {},
      ),
      throwsStateError,
    );
  });

  test('generation increases monotonically for request and invalidation events', () async {
    final coordinator = LatestConversionRequest();

    expect(coordinator.generation, 0);
    await coordinator.run<void>(
      operation: () async {},
      onSuccess: (value) {},
      onFailure: (error, stackTrace) => fail('Unexpected failure: $error'),
    );
    expect(coordinator.generation, 1);

    coordinator.invalidate();
    expect(coordinator.generation, 2);

    coordinator.dispose();
    expect(coordinator.generation, 3);
  });
}
