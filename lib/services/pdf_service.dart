import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/extintor_model.dart';

class PdfService {
  static Future<void> generarEtiquetaQR(Extintor extintor) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Formato ideal para etiquetas térmicas
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'FIRECHECK',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Sistema de Seguridad e Inspección', style: const pw.TextStyle(fontSize: 8)),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),
                pw.BarcodeWidget(
                  data: extintor.id,
                  barcode: pw.Barcode.qrCode(),
                  width: 120,
                  height: 120,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'ID: ${extintor.id}',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Tipo: ${extintor.tipo}', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Ubicación: ${extintor.ubicacion}', style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1),
                pw.Text(
                  'ESCANEÉ PARA INSPECCIÓN',
                  style: pw.TextStyle(fontSize: 7, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Muestra la ventana de previsualización e impresión
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Etiqueta_${extintor.id}',
    );
  }
}
