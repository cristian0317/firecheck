import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/extintor_model.dart';
import '../models/inspeccion_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener extintores en tiempo real
  Stream<List<Extintor>> getExtintoresStream() {
    return _db.collection('extintores').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Extintor.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Obtener historial de inspecciones (todas o por extintor)
  Stream<List<Inspeccion>> getInspeccionesStream({String? equipoId}) {
    Query query = _db.collection('inspecciones').orderBy('fecha', descending: true);
    
    if (equipoId != null) {
      query = query.where('equipoId', isEqualTo: equipoId);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Inspeccion.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Guardar una nueva inspección
  Future<void> guardarInspeccion(Inspeccion inspeccion) async {
    try {
      await _db.collection('inspecciones').add(inspeccion.toMap());
    } catch (e) {
      throw Exception('Error al guardar la inspección: $e');
    }
  }

  // Buscar extintor por ID
  Future<Extintor?> getExtintorById(String id) async {
    try {
      final doc = await _db.collection('extintores').doc(id).get();
      if (doc.exists) {
        return Extintor.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al buscar extintor: $e');
    }
  }
}
