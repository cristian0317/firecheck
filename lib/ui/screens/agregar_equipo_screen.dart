import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarEquipoScreen extends StatefulWidget {
  const AgregarEquipoScreen({super.key});

  @override
  State<AgregarEquipoScreen> createState() => _AgregarEquipoScreenState();
}

class _AgregarEquipoScreenState extends State<AgregarEquipoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();

  String _tipoSeleccionado = 'PQS';
  String _estadoSeleccionado = 'Operativo';
  bool _isSaving = false;

  final List<String> _tipos = ['PQS', 'CO2', 'Agua', 'Espuma', 'K (Cocina)'];
  final List<String> _estados = ['Operativo', 'Vencido', 'Mantenimiento', 'Fuera de Servicio'];

  Future<void> _guardarEquipo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final String id = _idController.text.trim();
      
      await FirebaseFirestore.instance.collection('extintores').doc(id).set({
        'id': id,
        'ubicacion': _ubicacionController.text.trim(),
        'capacidad': _capacidadController.text.trim(),
        'tipo': _tipoSeleccionado,
        'estado': _estadoSeleccionado,
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Extintor registrado con éxito'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _ubicacionController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Extintor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'ID del Extintor',
                  hintText: 'Ej: EXT-002',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el ID' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación Exacta',
                  hintText: 'Ej: Pasillo Norte, Piso 2',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese la ubicación' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _capacidadController,
                decoration: const InputDecoration(
                  labelText: 'Capacidad',
                  hintText: 'Ej: 10 lbs',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese la capacidad' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Extintor',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _tipos.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
                onChanged: (val) => setState(() => _tipoSeleccionado = val!),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _estadoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Estado Inicial',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                ),
                items: _estados.map((estado) => DropdownMenuItem(value: estado, child: Text(estado))).toList(),
                onChanged: (val) => setState(() => _estadoSeleccionado = val!),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSaving ? null : _guardarEquipo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isSaving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('Guardar Equipo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
