import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/extintor_model.dart';
import '../../services/pdf_service.dart';
import '../../services/web_download_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class QRPreviewScreen extends StatelessWidget {
  final Extintor extintor;
  final GlobalKey _qrKey = GlobalKey();

  QRPreviewScreen({super.key, required this.extintor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etiqueta QR'),
        actions: [
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () => WebDownloadService.downloadWidgetAsImage(_qrKey, fileName: 'QR_${extintor.id}'),
              tooltip: 'Descargar como Imagen (Web)',
            ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => PdfService.generarEtiquetaQR(extintor),
            tooltip: 'Descargar PDF',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _qrKey,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'FIRECHECK',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 20),
                        QrImageView(
                          data: extintor.id,
                          version: QrVersions.auto,
                          size: 250.0,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'ID: ${extintor.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Text(
                          'Tipo: ${extintor.tipo}',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        Text(
                          'Ubicación: ${extintor.ubicacion}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (kIsWeb)
                ElevatedButton.icon(
                  onPressed: () => WebDownloadService.downloadWidgetAsImage(_qrKey, fileName: 'QR_${extintor.id}'),
                  icon: const Icon(Icons.download_for_offline),
                  label: const Text('DESCARGAR IMAGEN QR (.PNG)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => PdfService.generarEtiquetaQR(extintor),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('GENERAR ETIQUETA PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
