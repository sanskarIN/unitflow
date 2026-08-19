import '../domain/unit_models.dart';

/// Produces UTF-8 friendly RFC-4180-style CSV text for batch conversion results.
/// Values are already canonical decimal strings, so no locale-dependent separators leak into
/// exported numeric data.
String batchResultsToCsv(
  Iterable<ConversionResult> results, {
  required String Function(ConversionResult result) valueFormatter,
}) {
  final buffer = StringBuffer('unit_id,unit_name,symbol,value\r\n');
  for (final result in results) {
    buffer
      ..write(_csv(result.to.id))
      ..write(',')
      ..write(_csv(result.to.name))
      ..write(',')
      ..write(_csv(result.to.symbol))
      ..write(',')
      ..write(_csv(valueFormatter(result)))
      ..write('\r\n');
  }
  return buffer.toString();
}

String _csv(String value) {
  if (!value.contains(RegExp('[,\\r\\n"]'))) {
    return value;
  }
  return '"${value.replaceAll('"', '""')}"';
}
