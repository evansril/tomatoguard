import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tomatoguard/features/detect/data/disease_classifier.dart';
import 'package:tomatoguard/features/history/data/scan_record.dart';

class ScanHistoryRepository {
  Database? _database;

  Future<Database> get _db async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final databasePath = path.join(await getDatabasesPath(), 'tomatoguard.db');
    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE scan_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image_path TEXT NOT NULL,
            class_name TEXT NOT NULL,
            display_name TEXT NOT NULL,
            confidence REAL NOT NULL,
            status TEXT NOT NULL,
            scanned_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<ScanRecord>> getAll() async {
    final rows = await (await _db).query(
      'scan_history',
      orderBy: 'scanned_at DESC',
    );
    return rows.map(ScanRecord.fromMap).toList(growable: false);
  }

  Future<ScanRecord> insert(
    XFile sourceImage,
    ClassificationResult result,
  ) async {
    final imagePath = await _storeImage(sourceImage);
    final scannedAt = DateTime.now();

    try {
      final id = await (await _db).insert('scan_history', {
        'image_path': imagePath,
        'class_name': result.className,
        'display_name': result.displayName,
        'confidence': result.confidence,
        'status': result.status.name,
        'scanned_at': scannedAt.toUtc().toIso8601String(),
      });
      return ScanRecord(
        id: id,
        imagePath: imagePath,
        className: result.className,
        displayName: result.displayName,
        confidence: result.confidence,
        status: result.status,
        scannedAt: scannedAt,
      );
    } catch (_) {
      try {
        await File(imagePath).delete();
      } on FileSystemException {
        // The database error remains the actionable failure.
      }
      rethrow;
    }
  }

  Future<void> delete(ScanRecord record) async {
    await (await _db).delete(
      'scan_history',
      where: 'id = ?',
      whereArgs: [record.id],
    );
    final image = File(record.imagePath);
    if (await image.exists()) await image.delete();
  }

  Future<void> clear() async {
    final records = await getAll();
    await (await _db).delete('scan_history');
    for (final record in records) {
      final image = File(record.imagePath);
      if (await image.exists()) await image.delete();
    }
  }

  Future<String> _storeImage(XFile source) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(documents.path, 'scan_images'));
    await directory.create(recursive: true);

    final extension = path.extension(source.path).isEmpty
        ? '.jpg'
        : path.extension(source.path);
    final filename = 'scan_${DateTime.now().microsecondsSinceEpoch}$extension';
    final destination = path.join(directory.path, filename);
    await File(source.path).copy(destination);
    return destination;
  }
}
