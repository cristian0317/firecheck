import 'package:flutter/material.dart';
import '../../models/extintor_model.dart';
import '../../services/firestore_service.dart';

class InspeccionScreen extends StatefulWidget {
  final Extintor extintor;

  const InspeccionScreen({super.key, required this.extintor});

  @override
  State<InspeccionScreen> createState() => _InspeccionScreenState();
}

class _InspeccionScreenState extends State<InspeccionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _presionCorrecta = true;
  bool _selloIntacto = true;
  final TextEditingController _observacionesController = TextEditingController();
  bool _isSaving = false;

  Future<void> _guardarInspeccion() async {
    setState(() => _isSaving = true);

    try {
      await _firestoreService.guardarInspeccion(
        extintorId: widget.extintor.id,
        presionCorrecta: _presionCorrecta,
        selloIntacto: _selloIntacto,
        observaciones: _observacionesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspección de Extintor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildExtintorCard(theme),
            const SizedBox(height: 32),
            SwitchListTile(
              title: const Text('¿Presión del manómetro correcta?'),
              subtitle: const Text('Zona verde visible'),
              value: _presionCorrecta,
              onChanged: (val) => setState(() => _presionCorrecta = val),
            ),
            const Divider(height: 32),
            SwitchListTile(
              title: const Text('¿Sello y seguro intactos?'),
              subtitle: const Text('Pasador original presente'),
              value: _selloIntacto,
              onChanged: (val) => setState(() => _selloIntacto = val),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _observacionesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observaciones adicionales',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isSaving ? null : _guardarInspeccion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Guardar Inspección', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtintorCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Equipo a Inspeccionar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text('📍 Ubicación: ${widget.extintor.ubicacion}', style: const TextStyle(fontSize: 15)),
            Text('🧯 Tipo: ${widget.extintor.tipo}', style: const TextStyle(fontSize: 15)),
            Text('🆔 ID: ${widget.extintor.id}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
