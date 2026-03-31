import 'package:cloud_firestore/cloud_firestore.dart';

class Inspeccion {
  final String? id;
  final String equipoId;
  final String usuarioId;
  final DateTime fecha;
  final bool presion;
  final bool valvula;
  final String estadoGeneral;
  final String observaciones;
  final String? fotoUrl;

  Inspeccion({
    this.id,
    required this.equipoId,
    required this.usuarioId,
    required this.fecha,
    required this.presion,
    required this.valvula,
    required this.estadoGeneral,
    required this.observaciones,
    this.fotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'equipoId': equipoId,
      'usuarioId': usuarioId,
      'fecha': Timestamp.fromDate(fecha),
      'presion': presion,
      'valvula': valvula,
      'estado_general': estadoGeneral,
      'observaciones': observaciones,
      'fotoUrl': fotoUrl,
    };
  }

  factory Inspeccion.fromMap(String id, Map<String, dynamic> map) {
    return Inspeccion(
      id: id,
      equipoId: map['equipoId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      presion: map['presion'] ?? false,
      valvula: map['valvula'] ?? false,
      estadoGeneral: map['estado_general'] ?? 'Bueno',
      observaciones: map['observaciones'] ?? '',
      fotoUrl: map['fotoUrl'],
    );
  }
}
