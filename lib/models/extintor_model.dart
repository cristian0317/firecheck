class Extintor {
  final String id;
  final String ubicacion;
  final String tipo;
  final String capacidad;
  final String estado;

  Extintor({
    required this.id,
    required this.ubicacion,
    required this.tipo,
    required this.capacidad,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ubicacion': ubicacion,
      'tipo': tipo,
      'capacidad': capacidad,
      'estado': estado,
    };
  }

  factory Extintor.fromMap(String id, Map<String, dynamic> map) {
    return Extintor(
      id: id,
      ubicacion: map['ubicacion'] ?? '',
      tipo: map['tipo'] ?? '',
      capacidad: map['capacidad'] ?? '',
      estado: map['estado'] ?? 'Operativo',
    );
  }
}
