import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../utils/reservation_pdf.dart';
import '../screens/reservation_form_screen.dart';

import '../helpers/responsive.dart';
import '../services/reservation_service.dart';
import '../widgets/reservation_card.dart';

class MyReservationsScreen extends StatelessWidget {
  final service = ReservationService();

  @override
  Widget build(BuildContext context) {
    final double padding = Responsive.isMobile(context) ? 10 : 40;

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Reservas"), centerTitle: true),

      body: Padding(
        padding: EdgeInsets.all(padding),

        // ------------------------------
        // 🔵 ESCUCHAR RESERVAS EN VIVO
        // ------------------------------
        child: StreamBuilder<QuerySnapshot>(
          stream: service.getReservasStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No tienes reservas aún.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final reservas = snapshot.data!.docs;

            return ListView.builder(
              itemCount: reservas.length,
              itemBuilder: (_, index) {
                final doc = reservas[index];
                final data = doc.data() as Map<String, dynamic>;

                return ReservationCard(
                  restaurant: data["restaurante"],
                  sucursal: data["sucursal"],
                  fecha: data["fecha"],
                  hora: data["hora"],
                  personas: data["personas"],

                  // 🔵 EDITAR
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      "/editReservation",
                      arguments: {"id": doc.id, ...data},
                    );
                  },

                  // 🔵 BORRAR (REAL)
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Eliminar reserva"),
                        content: const Text(
                          "¿Seguro que deseas eliminar esta reserva?",
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Cancelar"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text(
                              "Eliminar",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await service.deleteReserva(doc.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Reserva eliminada"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },

                  // 🔵 IMPRIMIR (PDF)
                  onPrint: () async {
                    try {
                      final reserva = Reserva(
                        nombre: data["nombre"] ?? "",
                        telefono: data["telefono"] ?? "",
                        correo: data["correo"] ?? "",
                        restaurante: data["restaurante"] ?? "",
                        sucursal: data["sucursal"] ?? "",
                        fecha: data["fecha"] ?? "",
                        hora: data["hora"] ?? "",
                        personas: data["personas"] ?? 0,
                        restauranteId: data["restauranteId"],
                        sucursalId: data["sucursalId"],
                        mesaId: data["mesaId"],
                        mesaNumero: data["mesaNumero"],
                      );

                      // 🔵 Generar PDF (Uint8List)
                      final pdfBytes = await ReservationPDF.generarPDF(
                        reserva,
                        doc.id,
                      );

                      // 🔵 Mostrar PDF en visor de impresión
                      await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al generar PDF: $e")),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
