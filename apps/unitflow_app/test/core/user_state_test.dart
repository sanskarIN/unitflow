import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/format/decimal_format.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('user state round-trips through backup JSON', () {
    final repository = MemoryUserStateRepository();
    final state = UserState(
      theme: ThemePreference.dark,
      notation: DecimalNotation.engineering,
      roundingMode: DecimalRoundingMode.halfAwayFromZero,
      decimalPlaces: 8,
      reduceMotion: true,
      onboardingComplete: true,
      favoriteUnitIds: <String>{'meter'},
      pinnedPairs: const <PinnedPair>[
        PinnedPair(
          category: UnitCategory.length,
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
        ),
      ],
      customUnits: const <CustomUnitData>[
        CustomUnitData(
          id: 'double_meter',
          category: UnitCategory.length,
          name: 'Double Meter',
          symbol: 'dmx',
          scale: '2',
          offset: '0',
        ),
      ],
    );

    final encoded = repository.exportJson(state);
    final restored = repository.importJson(encoded);

    expect(restored.theme, ThemePreference.dark);
    expect(restored.notation, DecimalNotation.engineering);
    expect(restored.roundingMode, DecimalRoundingMode.halfAwayFromZero);
    expect(restored.decimalPlaces, 8);
    expect(restored.reduceMotion, isTrue);
    expect(restored.favoriteUnitIds, contains('meter'));
    expect(restored.pinnedPairs.single.toUnitId, 'kilometer');
    expect(restored.customUnits.single.id, 'double_meter');
  });

  test('memory repository enforces production import size bound', () {
    final repository = MemoryUserStateRepository();
    final oversized = ' ' * 1_000_001;

    expect(() => repository.importJson(oversized), throwsFormatException);
  });

  test('schema version one backups migrate to nearest-even rounding', () {
    final repository = MemoryUserStateRepository();
    const legacy = '{'
        '"schemaVersion":1,'
        '"theme":"system",'
        '"notation":"plain",'
        '"decimalPlaces":12,'
        '"useGrouping":true,'
        '"onboardingComplete":true,'
        '"favoriteUnitIds":[],'
        '"pinnedPairs":[],'
        '"recents":[],'
        '"customUnits":[]'
        '}';

    final restored = repository.importJson(legacy);

    expect(restored.roundingMode, DecimalRoundingMode.nearestEven);
    expect(restored.reduceMotion, isFalse);
    expect(restored.toJson()['schemaVersion'], UserState.schemaVersion);
  });

  test('schema version two without reduceMotion defaults to false', () {
    final repository = MemoryUserStateRepository();
    const legacyV2 = '{'
        '"schemaVersion":2,'
        '"theme":"system",'
        '"notation":"plain",'
        '"roundingMode":"nearestEven",'
        '"decimalPlaces":12,'
        '"useGrouping":true,'
        '"onboardingComplete":true,'
        '"favoriteUnitIds":[],'
        '"pinnedPairs":[],'
        '"recents":[],'
        '"customUnits":[]'
        '}';

    final restored = repository.importJson(legacyV2);

    expect(restored.reduceMotion, isFalse);
  });

  test('invalid schema version is rejected', () {
    final repository = MemoryUserStateRepository();
    expect(
      () => repository.importJson('{"schemaVersion":999}'),
      throwsFormatException,
    );
  });

  test('unknown top-level fields are rejected', () {
    final repository = MemoryUserStateRepository();
    const payload = '{'
        '"schemaVersion":2,'
        '"theme":"system",'
        '"notation":"plain",'
        '"roundingMode":"nearestEven",'
        '"decimalPlaces":12,'
        '"useGrouping":true,'
        '"onboardingComplete":true,'
        '"favoriteUnitIds":[],'
        '"pinnedPairs":[],'
        '"recents":[],'
        '"customUnits":[],'
        '"unexpected":true'
        '}';

    expect(() => repository.importJson(payload), throwsFormatException);
  });

  test('unknown nested fields are rejected', () {
    final repository = MemoryUserStateRepository();
    const payload = '{'
        '"schemaVersion":2,'
        '"theme":"system",'
        '"notation":"plain",'
        '"roundingMode":"nearestEven",'
        '"decimalPlaces":12,'
        '"useGrouping":true,'
        '"onboardingComplete":true,'
        '"favoriteUnitIds":[],'
        '"pinnedPairs":[],'
        '"recents":[{'
        '"input":"1",'
        '"fromUnitId":"meter",'
        '"toUnitId":"kilometer",'
        '"createdAt":"2026-08-19T00:00:00Z",'
        '"unexpected":true'
        '}],'
        '"customUnits":[]'
        '}';

    expect(() => repository.importJson(payload), throwsFormatException);
  });

  test('oversized pinned-pair collection is rejected', () {
    final json = UserState(
      onboardingComplete: true,
      pinnedPairs: List<PinnedPair>.generate(
        UserState.maxPinnedPairs + 1,
        (index) => PinnedPair(
          category: UnitCategory.length,
          fromUnitId: 'meter',
          toUnitId: 'unit_$index',
        ),
      ),
    ).toJson();

    expect(() => UserState.fromJson(json), throwsFormatException);
  });

  test('custom unit aliases are trimmed and deduplicated', () {
    const unit = CustomUnitData(
      id: 'double_meter',
      category: UnitCategory.length,
      name: ' Double Meter ',
      symbol: ' dmx ',
      scale: '2.0',
      offset: '0.0',
      aliases: <String>[' double ', 'DOUBLE', 'two meters'],
      description: ' Example unit. ',
    );

    final definition = unit.toUnitDefinition();

    expect(definition.name, 'Double Meter');
    expect(definition.symbol, 'dmx');
    expect(definition.aliases, <String>['double', 'two meters']);
    expect(definition.description, 'Example unit.');
  });

  test('persisted pinned pair identifiers must be safe stable IDs', () {
    expect(PinnedPair.tryParse('length|meter|kilometer'), isNotNull);
    expect(PinnedPair.tryParse('length|../meter|kilometer'), isNull);
    expect(PinnedPair.tryParse('length|meter|bad unit'), isNull);
  });

  test('custom units reject built-in style formula with zero scale', () {
    const unit = CustomUnitData(
      id: 'bad_scale',
      category: UnitCategory.length,
      name: 'Bad scale',
      symbol: 'bad',
      scale: '0',
      offset: '0',
    );
    expect(unit.toUnitDefinition, throwsFormatException);
  });
}
