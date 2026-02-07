import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../screens/reservation_form_screen.dart';

class ReservationPDF {
  /// Genera el PDF y devuelve un Uint8List listo para imprimir/guardar.
  static Future<Uint8List> generarPDF(Reserva reserva, String reservaId) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Confirmación de Reserva",
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Text("ID de reserva: $reservaId"),
                pw.SizedBox(height: 10),

                pw.Text("Nombre: ${reserva.nombre}"),
                pw.Text("Teléfono: ${reserva.telefono}"),
                pw.Text("Correo: ${reserva.correo}"),
                pw.SizedBox(height: 20),

                pw.Text("Restaurante: ${reserva.restaurante}"),
                pw.Text("Sucursal: ${reserva.sucursal}"),
                pw.SizedBox(height: 10),

                pw.Text("Fecha: ${reserva.fecha}"),
                pw.Text("Hora: ${reserva.hora}"),
                pw.Text("Personas: ${reserva.personas}"),
                pw.SizedBox(height: 10),

                pw.Text("Mesa asignada: ${reserva.mesaNumero}"),
                pw.SizedBox(height: 30),

                pw.Text(
                  "Gracias por reservar con QuickTable.",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
