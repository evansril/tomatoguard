import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tomatoguard/features/detect/data/disease_classifier.dart';
import 'package:tomatoguard/features/history/data/scan_history_repository.dart';
import 'package:tomatoguard/features/history/data/scan_record.dart';

class ScanHistoryStore extends ChangeNotifier {
  ScanHistoryStore(this._repository);

  final ScanHistoryRepository _repository;

  List<ScanRecord> _records = const [];
  bool _isLoading = true;
  String? _error;

  List<ScanRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _records = await _repository.getAll();
      _error = null;
    } catch (_) {
      _error = 'Scan history could not be loaded.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> add(XFile image, ClassificationResult result) async {
    try {
      final record = await _repository.insert(image, result);
      _records = [record, ..._records];
      _error = null;
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'This result could not be saved to scan history.';
      notifyListeners();
      return false;
    }
  }

  Future<void> delete(ScanRecord record) async {
    await _repository.delete(record);
    _records = _records.where((item) => item.id != record.id).toList();
    notifyListeners();
  }

  Future<void> clear() async {
    await _repository.clear();
    _records = const [];
    notifyListeners();
  }
}
