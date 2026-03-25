class Extintor {
  final String id;
  final String ubicacion;
  final String tipo;

  Extintor({
    required this.id,
    required this.ubicacion,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ubicacion': ubicacion,
      'tipo': tipo,
    };
  }

  factory Extintor.fromMap(String id, Map<String, dynamic> map) {
    return Extintor(
      id: id,
      ubicacion: map['ubicacion'] ?? '',
      tipo: map['tipo'] ?? '',
    );
  }
}
