import 'unit_models.dart';

enum BatchExportFormat { csv, tsv }

extension BatchExportFormatInfo on BatchExportFormat {
  String get delimiter => switch (this) {
    BatchExportFormat.csv => ',',
    BatchExportFormat.tsv => '\t',
  };
}

/// Deterministic text export for batch-conversion results.
///
/// Values use canonical decimal strings so exports are locale-independent and can
/// be re-imported by spreadsheets and scripts without grouping ambiguity.
final class BatchExportFormatter {
  const BatchExportFormatter();

  String encode(
    Iterable<ConversionResult> results, {
    BatchExportFormat format = BatchExportFormat.csv,
    bool includeHeader = true,
  }) {
    final delimiter = format.delimiter;
    final lines = <String>[];
    if (includeHeader) {
      lines.add(
        <String>[
          'input',
          'from_unit_id',
          'from_unit',
          'from_symbol',
          'output',
          'to_unit_id',
          'to_unit',
          'to_symbol',
        ].map((value) => _escape(value, delimiter)).join(delimiter),
      );
    }

    for (final result in results) {
      lines.add(
        <String>[
          result.input.toCanonicalString(),
          result.from.id,
          result.from.name,
          result.from.symbol,
          result.output.toCanonicalString(),
          result.to.id,
          result.to.name,
          result.to.symbol,
        ].map((value) => _escape(value, delimiter)).join(delimiter),
      );
    }
    return lines.join('\n');
  }

  String _escape(String value, String delimiter) {
    if (!value.contains(delimiter) &&
        !value.contains('"') &&
        !value.contains('\n') &&
        !value.contains('\r')) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }
}
