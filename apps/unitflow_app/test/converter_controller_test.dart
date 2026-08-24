import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/bridge/native_conversion_bridge.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/conversion_engine.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';
import 'package:unitflow/features/converter/presentation/converter_controller.dart';

void main() {
  late AppController appController;
  late ConverterController controller;

  setUp(() async {
    appController = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    await appController.initialize();
    controller = ConverterController(appController: appController);
  });

  tearDown(() {
    controller.dispose();
    appController.dispose();
  });

  test('default length pair converts meters to kilometers exactly', () {
    controller.setInput('1500');

    expect(controller.category, UnitCategory.length);
    expect(controller.fromUnitId, 'meter');
    expect(controller.toUnitId, 'kilometer');
    expect(controller.result?.output, ExactDecimal.parse('1.5'));
    expect(controller.error, isNull);
  });

  test('swap reverses the selected conversion pair', () {
    controller.setInput('1.5');
    controller.swapUnits();

    expect(controller.fromUnitId, 'kilometer');
    expect(controller.toUnitId, 'meter');
    expect(controller.result?.output, ExactDecimal.parse('1500'));
  });

  test('changing category always selects a valid same-category pair', () {
    controller.setCategory(UnitCategory.temperature);

    expect(controller.fromUnit?.category, UnitCategory.temperature);
    expect(controller.toUnit?.category, UnitCategory.temperature);
    expect(controller.fromUnitId, isNotEmpty);
    expect(controller.toUnitId, isNotEmpty);
  });

  test('invalid numeric input produces a safe validation message', () {
    controller.setInput('not-a-number');

    expect(controller.result, isNull);
    expect(controller.error, isNotNull);
    expect(controller.error, isNot(contains('Exception')));
  });

  test('batch results stay within the selected category', () {
    controller.setCategory(UnitCategory.mass);
    controller.setInput('2');

    final results = controller.batchResults();

    expect(results, isNotEmpty);
    expect(results.every((result) => result.from.category == UnitCategory.mass), isTrue);
    expect(results.every((result) => result.to.category == UnitCategory.mass), isTrue);
  });

  test('fallback batch engine accepts the documented maximum target count', () {
    final engine = ExactConversionEngine();
    final results = engine.batchConvert(
      value: ExactDecimal.parse('2'),
      fromUnitId: 'meter',
      toUnitIds: List<String>.filled(maxBatchConversionTargets, 'centimeter'),
    );

    expect(maxBatchConversionTargets, 256);
    expect(results, hasLength(maxBatchConversionTargets));
    expect(results.first.output, ExactDecimal.parse('200'));
    expect(results.last.output, ExactDecimal.parse('200'));
  });

  test('fallback batch engine rejects requests above the shared target limit', () {
    final engine = ExactConversionEngine();

    expect(
      () => engine.batchConvert(
        value: ExactDecimal.parse('2'),
        fromUnitId: 'meter',
        toUnitIds: List<String>.filled(
          maxBatchConversionTargets + 1,
          'centimeter',
        ),
      ),
      throwsA(
        isA<ConversionFailure>().having(
          (failure) => failure.message,
          'message',
          contains('at most 256'),
        ),
      ),
    );
  });

  test('older native conversion completion cannot overwrite newer input', () async {
    final bridge = _DelayedNativeBridge();
    final nativeApp = AppController(
      repository: MemoryUserStateRepository(UserState(onboardingComplete: true)),
      nativeBridgeLoader: () async => bridge,
    );
    await nativeApp.initialize();
    final nativeController = ConverterController(appController: nativeApp);
    addTearDown(() {
      nativeController.dispose();
      nativeApp.dispose();
    });

    nativeController.setInput('2');
    nativeController.setInput('3');

    bridge.complete(value: '3', output: '9');
    await Future<void>.delayed(Duration.zero);
    expect(nativeController.result?.output, ExactDecimal.parse('9'));

    bridge.complete(value: '2', output: '8');
    await Future<void>.delayed(Duration.zero);
    expect(nativeController.result?.output, ExactDecimal.parse('9'));

    bridge.complete(value: '1', output: '7');
    await Future<void>.delayed(Duration.zero);
    expect(nativeController.result?.output, ExactDecimal.parse('9'));
  });
}

const _validInfo = NativeBridgeInfo(
  protocolVersion: nativeBridgeProtocolVersion,
  backendId: 'rust-core',
  capabilities: <String>{
    nativeBridgeCapabilityConvert,
    nativeBridgeCapabilityBatchConvert,
    nativeBridgeCapabilityCanonicalDecimalText,
  },
);

final class _DelayedNativeBridge implements NativeConversionBridge {
  final Map<String, Completer<NativeBridgeConversionResponse>> _pending =
      <String, Completer<NativeBridgeConversionResponse>>{};
  final Map<String, NativeBridgeConversionRequest> _requests =
      <String, NativeBridgeConversionRequest>{};

  @override
  NativeBridgeInfo get info => _validInfo;

  @override
  Future<NativeBridgeConversionResponse> convert(
    NativeBridgeConversionRequest request,
  ) {
    final completer = Completer<NativeBridgeConversionResponse>();
    _pending[request.value] = completer;
    _requests[request.value] = request;
    return completer.future;
  }

  void complete({required String value, required String output}) {
    final request = _requests[value]!;
    _pending[value]!.complete(
      NativeBridgeConversionResponse(
        input: request.value,
        output: output,
        fromUnitId: request.fromUnitId,
        toUnitId: request.toUnitId,
      ),
    );
  }

  @override
  Future<List<NativeBridgeConversionResponse>> batchConvert(
    NativeBridgeBatchConversionRequest request,
  ) async => request.targetUnitIds
      .map(
        (target) => NativeBridgeConversionResponse(
          input: request.value,
          output: request.value,
          fromUnitId: request.fromUnitId,
          toUnitId: target,
        ),
      )
      .toList(growable: false);
}
