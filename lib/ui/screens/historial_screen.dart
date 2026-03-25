import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Inspecciones'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getInspeccionesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el historial.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No hay inspecciones registradas.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final DateTime? timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final String fechaFormateada = timestamp != null 
                  ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp)
                  : 'Fecha desconocida';

              final bool presionOk = data['presion_correcta'] ?? false;
              final bool selloOk = data['sello_intacto'] ?? false;
              final bool todoOk = presionOk && selloOk;

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
                    'ID: ${data['extintor_id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(fechaFormateada),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Presión manómetro:', presionOk),
                          _infoRow('Sello y seguro:', selloOk),
                          if (data['observaciones'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(data['observaciones'] ?? 'Sin observaciones'),
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
