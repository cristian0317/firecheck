import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/inspeccion_model.dart';
import '../../services/firestore_service.dart';

class HistorialScreen extends StatelessWidget {
  final String? equipoId;

  const HistorialScreen({super.key, this.equipoId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(equipoId == null 
            ? 'Historial de Inspecciones' 
            : 'Inspecciones del Equipo'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Inspeccion>>(
        stream: firestoreService.getInspeccionesStream(equipoId: equipoId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el historial: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final inspecciones = snapshot.data ?? [];

          if (inspecciones.isEmpty) {
            return const Center(child: Text('No hay inspecciones registradas.'));
          }

          return ListView.builder(
            itemCount: inspecciones.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final inspeccion = inspecciones[index];
              final String fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(inspeccion.fecha);
              final bool todoOk = inspeccion.presion && inspeccion.valvula;

              return Card(
                elevation: 0,
                color: todoOk ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: todoOk ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Icon(
                    todoOk ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                    color: todoOk ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    'Estado: ${inspeccion.estadoGeneral}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(fechaFormateada),
                  children: [
                    if (inspeccion.fotoUrl != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            inspeccion.fotoUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Presión OK:', inspeccion.presion),
                          _infoRow('Válvula OK:', inspeccion.valvula),
                          const SizedBox(height: 8),
                          Text('Usuario: ${inspeccion.usuarioId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if (inspeccion.observaciones.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(inspeccion.observaciones),
                          ],
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            status ? Icons.check : Icons.close,
            size: 18,
            color: status ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
