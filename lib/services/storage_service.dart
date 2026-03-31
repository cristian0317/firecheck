import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadInspeccionImage(dynamic file) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('inspecciones').child(fileName);
      
      UploadTask uploadTask;
      if (kIsWeb) {
        // En web, file es de tipo Uint8List
        uploadTask = ref.putData(file);
      } else {
        // En móvil, file es de tipo File
        uploadTask = ref.putFile(file as File);
      }

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
}
