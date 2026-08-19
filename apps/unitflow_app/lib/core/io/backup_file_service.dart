import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

/// Cross-platform file boundary for UnitFlow backup data.
///
/// The repository performs schema/content validation after this service reads the bounded text.
/// File selection is user initiated and no broad storage permission is requested by UnitFlow.
final class BackupFileService {
  const BackupFileService();

  static const maxBytes = 1_000_000;
  static const suggestedFileName = 'unitflow-backup.json';

  static const _jsonType = XTypeGroup(
    label: 'UnitFlow JSON backup',
    extensions: <String>['json'],
    mimeTypes: <String>['application/json'],
    uniformTypeIdentifiers: <String>['public.json'],
    webWildCards: <String>['application/json'],
  );

  /// Opens a user-selected JSON backup and returns its UTF-8 text.
  /// Returns `null` when the user cancels.
  Future<String?> importBackup() async {
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_jsonType],
    );
    if (file == null) {
      return null;
    }

    final size = await file.length();
    if (size <= 0 || size > maxBytes) {
      throw const BackupFileException(
        'Backup file must be between 1 byte and 1 MB.',
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) {
      throw const BackupFileException('Backup file exceeds the 1 MB limit.');
    }
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      throw const BackupFileException('Backup file is not valid UTF-8 text.');
    }
  }

  /// Shows the platform save-location UI and writes a UTF-8 JSON backup.
  ///
  /// Returns `false` when no save location is available or the user cancels. The caller can keep
  /// clipboard export as a universal fallback for platforms without save-location support.
  Future<bool> exportBackup(String content) async {
    final bytes = utf8.encode(content);
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const BackupFileException(
        'Backup content must be between 1 byte and 1 MB.',
      );
    }

    final location = await getSaveLocation(
      acceptedTypeGroups: const <XTypeGroup>[_jsonType],
      suggestedName: suggestedFileName,
    );
    if (location == null) {
      return false;
    }

    final file = XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: 'application/json',
      name: suggestedFileName,
    );
    await file.saveTo(location.path);
    return true;
  }
}

final class BackupFileException implements Exception {
  const BackupFileException(this.message);

  final String message;

  @override
  String toString() => message;
}
