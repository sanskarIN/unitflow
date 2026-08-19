import '../../../l10n/generated/app_localizations.dart';
import '../domain/unit_models.dart';

extension UnitCategoryLocalizations on UnitCategory {
  String localizedLabel(AppLocalizations strings) => switch (this) {
    UnitCategory.length => strings.categoryLength,
    UnitCategory.area => strings.categoryArea,
    UnitCategory.volume => strings.categoryVolume,
    UnitCategory.mass => strings.categoryMass,
    UnitCategory.speed => strings.categorySpeed,
    UnitCategory.pressure => strings.categoryPressure,
    UnitCategory.energy => strings.categoryEnergy,
    UnitCategory.power => strings.categoryPower,
    UnitCategory.angle => strings.categoryAngle,
    UnitCategory.dataSize => strings.categoryDataSize,
    UnitCategory.frequency => strings.categoryFrequency,
    UnitCategory.time => strings.categoryTime,
    UnitCategory.temperature => strings.categoryTemperature,
  };

  String localizedExplanation(AppLocalizations strings) => switch (this) {
    UnitCategory.length => strings.educationLength,
    UnitCategory.area => strings.educationArea,
    UnitCategory.volume => strings.educationVolume,
    UnitCategory.mass => strings.educationMass,
    UnitCategory.speed => strings.educationSpeed,
    UnitCategory.pressure => strings.educationPressure,
    UnitCategory.energy => strings.educationEnergy,
    UnitCategory.power => strings.educationPower,
    UnitCategory.angle => strings.educationAngle,
    UnitCategory.dataSize => strings.educationDataSize,
    UnitCategory.frequency => strings.educationFrequency,
    UnitCategory.time => strings.educationTime,
    UnitCategory.temperature => strings.educationTemperature,
  };

  String localizedExample(AppLocalizations strings) => switch (this) {
    UnitCategory.length => strings.exampleLength,
    UnitCategory.area => strings.exampleArea,
    UnitCategory.volume => strings.exampleVolume,
    UnitCategory.mass => strings.exampleMass,
    UnitCategory.speed => strings.exampleSpeed,
    UnitCategory.pressure => strings.examplePressure,
    UnitCategory.energy => strings.exampleEnergy,
    UnitCategory.power => strings.examplePower,
    UnitCategory.angle => strings.exampleAngle,
    UnitCategory.dataSize => strings.exampleDataSize,
    UnitCategory.frequency => strings.exampleFrequency,
    UnitCategory.time => strings.exampleTime,
    UnitCategory.temperature => strings.exampleTemperature,
  };
}
