import 'package:flutter/material.dart';
import '../helpers/responsive.dart';

class ReservationCard extends StatelessWidget {
  final String restaurant;
  final String sucursal;
  final String fecha;
  final String hora;
  final int personas;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPrint;

  ReservationCard({
    required this.restaurant,
    required this.sucursal,
    required this.fecha,
    required this.hora,
    required this.personas,
    this.onEdit,
    this.onDelete,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    double spacing = Responsive.isMobile(context) ? 10 : 20;

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔵 Datos principales
            Text(
              restaurant,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "$sucursal",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 4),
            Text("$fecha • $hora", style: TextStyle(fontSize: 15)),
            SizedBox(height: 4),
            Text("Personas: $personas", style: TextStyle(fontSize: 15)),

            SizedBox(height: spacing),

            // 🔵 BOTONES (Editar / Borrar / Imprimir)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Editar
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: Colors.blue, size: 26),
                  tooltip: "Editar reserva",
                ),

                // Borrar
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, color: Colors.red, size: 26),
                  tooltip: "Eliminar reserva",
                ),

                // Imprimir/PDF
                IconButton(
                  onPressed: onPrint,
                  icon: Icon(Icons.picture_as_pdf,
                      color: Colors.green, size: 26),
                  tooltip: "Imprimir o descargar PDF",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
