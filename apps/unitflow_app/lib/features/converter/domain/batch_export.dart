import 'dart:convert';

import 'unit_models.dart';

enum BatchExportFormat { csv, tsv, json }

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
    final materialized = results.toList(growable: false);
    return switch (format) {
      BatchExportFormat.csv => _encodeDelimited(
        materialized,
        delimiter: ',',
        includeHeader: includeHeader,
      ),
      BatchExportFormat.tsv => _encodeDelimited(
        materialized,
        delimiter: '\t',
        includeHeader: includeHeader,
      ),
      BatchExportFormat.json => _encodeJson(materialized),
    };
  }

  String _encodeDelimited(
    List<ConversionResult> results, {
    required String delimiter,
    required bool includeHeader,
  }) {
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

  String _encodeJson(List<ConversionResult> results) => const JsonEncoder.withIndent('  ').convert(
    results
        .map(
          (result) => <String, String>{
            'input': result.input.toCanonicalString(),
            'from_unit_id': result.from.id,
            'from_unit': result.from.name,
            'from_symbol': result.from.symbol,
            'output': result.output.toCanonicalString(),
            'to_unit_id': result.to.id,
            'to_unit': result.to.name,
            'to_symbol': result.to.symbol,
          },
        )
        .toList(growable: false),
  );

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
