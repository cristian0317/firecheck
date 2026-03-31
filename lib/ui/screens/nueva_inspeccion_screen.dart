import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../models/extintor_model.dart';
import '../../services/pdf_service.dart';
import '../viewmodels/nueva_inspeccion_viewmodel.dart';
import 'qr_preview_screen.dart'; // IMPORTANTE

class NuevaInspeccionScreen extends StatefulWidget {
  final Extintor extintor;

  const NuevaInspeccionScreen({super.key, required this.extintor});

  @override
  State<NuevaInspeccionScreen> createState() => _NuevaInspeccionScreenState();
}

class _NuevaInspeccionScreenState extends State<NuevaInspeccionScreen> {
  late final NuevaInspeccionViewModel _viewModel;
  final TextEditingController _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = NuevaInspeccionViewModel(extintor: widget.extintor);
    _observacionesController.addListener(() {
      _viewModel.observaciones = _observacionesController.text;
    });
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    try {
      await _viewModel.tomarFoto();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _guardar() async {
    try {
      final success = await _viewModel.guardarInspeccion();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inspección guardada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Inspección'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.blue),
            tooltip: 'Ver Etiqueta QR',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRPreviewScreen(extintor: widget.extintor),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExtintorInfo(),
                    const SizedBox(height: 24),
                    _buildFotoPreview(),
                    const SizedBox(height: 24),
                    _buildForm(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _viewModel.isLoading ? null : _guardar,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Inspección'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_viewModel.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFotoPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Evidencia fotográfica:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: _viewModel.isLoading ? null : _tomarFoto,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: _viewModel.imageFile == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Tocar para tomar foto', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: kIsWeb
                          ? Image.network(_viewModel.imageFile!.path, fit: BoxFit.cover)
                          : Image.file(File(_viewModel.imageFile!.path), fit: BoxFit.cover),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtintorInfo() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extintor: ${widget.extintor.tipo}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Ubicación: ${widget.extintor.ubicacion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Presión OK'),
          subtitle: const Text('¿El manómetro indica la zona verde?'),
          value: _viewModel.presionOk,
          onChanged: (val) => _viewModel.presionOk = val,
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Válvula OK'),
          subtitle: const Text('¿Sello de seguridad intacto?'),
          value: _viewModel.valvulaOk,
          onChanged: (val) => _viewModel.valvulaOk = val,
        ),
        const Divider(),
        const SizedBox(height: 16),
        const Text('Estado general:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _viewModel.estadoGeneral,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: ['Bueno', 'Regular', 'Malo']
              .map((estado) => DropdownMenuItem(
                    value: estado,
                    child: Text(estado),
                  ))
              .toList(),
          onChanged: (val) => _viewModel.estadoGeneral = val!,
        ),
        const SizedBox(height: 24),
        const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _observacionesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ingrese observaciones adicionales...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
