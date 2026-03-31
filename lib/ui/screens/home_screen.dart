import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firecheck/models/extintor_model.dart';
import '../../services/firestore_service.dart';
import 'nueva_inspeccion_screen.dart';
import 'agregar_equipo_screen.dart';
import 'historial_screen.dart';
import 'qr_scanner_screen.dart';
import 'login_screen.dart';
import 'qr_preview_screen.dart'; // IMPORTANTE

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extintores Asignados'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'Historial Global',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistorialScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Extintor>>(
        stream: firestoreService.getExtintoresStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_person_outlined, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Acceso Restringido',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No tienes permisos para ver esta lista o tu sesión ha expirado.\nDetalle técnico: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.login),
                      label: const Text('Volver al Login y Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final extintores = snapshot.data ?? [];

          if (extintores.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay extintores registrados.'),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: extintores.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final extintor = extintores[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.fire_extinguisher, 
                      color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    '${extintor.tipo} - ${extintor.ubicacion}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${extintor.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // AHORA NAVEGA A LA PREVISUALIZACIÓN
                      IconButton(
                        icon: const Icon(Icons.qr_code, size: 24, color: Colors.blue),
                        tooltip: 'Ver Etiqueta QR',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRPreviewScreen(extintor: extintor),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.history_edu, size: 20),
                        tooltip: 'Ver historial',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistorialScreen(equipoId: extintor.id),
                            ),
                          );
                        },
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NuevaInspeccionScreen(extintor: extintor),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'qr_scanner_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerScreen()),
              );
            },
            tooltip: 'Escanear QR',
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_equipo_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgregarEquipoScreen()),
              );
            },
            label: const Text('Registrar Equipo'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
