import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/extintor_model.dart';

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
  Stream<QuerySnapshot> getInspeccionesStream({String? extintorId}) {
    Query query = _db.collection('inspecciones').orderBy('timestamp', descending: true);
    
    if (extintorId != null) {
      query = query.where('extintor_id', isEqualTo: extintorId);
    }
    
    return query.snapshots();
  }

  Future<void> guardarInspeccion({
    required String extintorId,
    required bool presionCorrecta,
    required bool selloIntacto,
    required String observaciones,
  }) async {
    await _db.collection('inspecciones').add({
      'extintor_id': extintorId,
      'presion_correcta': presionCorrecta,
      'sello_intacto': selloIntacto,
      'observaciones': observaciones,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
