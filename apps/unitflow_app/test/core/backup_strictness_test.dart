import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  test('backup import rejects duplicate top-level keys', () {
    final repository = MemoryUserStateRepository();
    const payload = '{'
        '"schemaVersion":2,'
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

    expect(() => repository.importJson(payload), throwsFormatException);
  });

  test('backup import rejects duplicate nested custom-unit keys', () {
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
        '"customUnits":[{'
        '"id":"double_meter",'
        '"id":"triple_meter",'
        '"category":"length",'
        '"name":"Double Meter",'
        '"symbol":"dmx",'
        '"scale":"2",'
        '"offset":"0",'
        '"aliases":[],'
        '"description":""'
        '}]'
        '}';

    expect(() => repository.importJson(payload), throwsFormatException);
  });
}
