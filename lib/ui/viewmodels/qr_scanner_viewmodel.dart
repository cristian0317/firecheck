import 'package:flutter/foundation.dart';
import '../../models/extintor_model.dart';
import '../../services/firestore_service.dart';

class QRScannerViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<Extintor?> procesarQR(String code) async {
    if (_isProcessing) return null;

    _isProcessing = true;
    notifyListeners();

    try {
      final extintor = await _firestoreService.getExtintorById(code);
      _isProcessing = false;
      notifyListeners();
      return extintor;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      rethrow;
    }
  }

  void resetProcessing() {
    _isProcessing = false;
    notifyListeners();
  }
}
