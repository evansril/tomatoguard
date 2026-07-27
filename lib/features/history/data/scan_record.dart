import 'package:tomatoguard/features/detect/data/disease_classifier.dart';

class ScanRecord {
  const ScanRecord({
    required this.id,
    required this.imagePath,
    required this.className,
    required this.displayName,
    required this.confidence,
    required this.status,
    required this.scannedAt,
  });

  final int id;
  final String imagePath;
  final String className;
  final String displayName;
  final double confidence;
  final DetectionStatus status;
  final DateTime scannedAt;

  ClassificationResult toClassificationResult() {
    return ClassificationResult(
      className: className,
      displayName: displayName,
      confidence: confidence,
      status: status,
      scores: const {},
    );
  }

  factory ScanRecord.fromMap(Map<String, Object?> map) {
    return ScanRecord(
      id: map['id']! as int,
      imagePath: map['image_path']! as String,
      className: map['class_name']! as String,
      displayName: map['display_name']! as String,
      confidence: (map['confidence']! as num).toDouble(),
      status: DetectionStatus.values.byName(map['status']! as String),
      scannedAt: DateTime.parse(map['scanned_at']! as String).toLocal(),
    );
  }
}
