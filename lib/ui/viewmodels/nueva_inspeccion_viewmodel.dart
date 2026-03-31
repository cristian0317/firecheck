import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/extintor_model.dart';
import '../../models/inspeccion_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class NuevaInspeccionViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final Extintor extintor;

  bool _presionOk = true;
  bool _valvulaOk = true;
  String _estadoGeneral = 'Bueno';
  String _observaciones = '';
  bool _isLoading = false;
  
  XFile? _imageFile;

  NuevaInspeccionViewModel({required this.extintor});

  // Getters
  bool get presionOk => _presionOk;
  bool get valvulaOk => _valvulaOk;
  String get estadoGeneral => _estadoGeneral;
  String get observaciones => _observaciones;
  bool get isLoading => _isLoading;
  XFile? get imageFile => _imageFile;

  // Setters
  set presionOk(bool value) {
    _presionOk = value;
    notifyListeners();
  }

  set valvulaOk(bool value) {
    _valvulaOk = value;
    notifyListeners();
  }

  set estadoGeneral(String value) {
    _estadoGeneral = value;
    notifyListeners();
  }

  set observaciones(String value) {
    _observaciones = value;
    notifyListeners();
  }

  Future<void> tomarFoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Reducir calidad para ahorrar espacio
      );
      if (photo != null) {
        _imageFile = photo;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al abrir la cámara: $e');
    }
  }

  Future<bool> guardarInspeccion() async {
    // Intentar obtener el usuario actual, si es nulo reintentar una vez tras un mini delay
    // para manejar posibles race conditions en web tras refrescos
    var user = _auth.currentUser;
    if (user == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      user = _auth.currentUser;
    }

    if (user == null) {
      throw Exception('Sesión expirada o usuario no autenticado. Por favor, inicie sesión nuevamente.');
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? fotoUrl;
      
      // Subir imagen si existe
      if (_imageFile != null) {
        if (kIsWeb) {
          final bytes = await _imageFile!.readAsBytes();
          fotoUrl = await _storageService.uploadInspeccionImage(bytes);
        } else {
          fotoUrl = await _storageService.uploadInspeccionImage(File(_imageFile!.path));
        }
      }

      final nuevaInspeccion = Inspeccion(
        equipoId: extintor.id,
        usuarioId: user.uid,
        fecha: DateTime.now(),
        presion: _presionOk,
        valvula: _valvulaOk,
        estadoGeneral: _estadoGeneral,
        observaciones: _observaciones,
        fotoUrl: fotoUrl,
      );

      await _firestoreService.guardarInspeccion(nuevaInspeccion);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
