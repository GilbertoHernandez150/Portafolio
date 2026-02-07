import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/reservation_form_screen.dart';

class ReservationService {
  final CollectionReference reservasRef =
      FirebaseFirestore.instance.collection("reservas");

  Future<String> crearReserva(Reserva reserva) async {
    try {
      final data = {
        "nombre": reserva.nombre,
        "telefono": reserva.telefono,
        "correo": reserva.correo,

        // Identificadores del restaurante y sucursal
        "restaurante": reserva.restaurante,
        "restauranteId": reserva.restauranteId,
        "sucursal": reserva.sucursal,
        "sucursalId": reserva.sucursalId,

        // Fecha / hora
        "fecha": reserva.fecha,
        "hora": reserva.hora,

        // Personas
        "personas": reserva.personas,

        // 🔵 CAMPOS IMPORTANTES PARA MESAS
        "mesaId": reserva.mesaId,          // <-- AHORA SÍ SE GUARDA
        "mesaNumero": reserva.mesaNumero,  // <-- AHORA SÍ SE GUARDA

        // Timestamp
        "createdAt": FieldValue.serverTimestamp(),
      };

      final doc = await reservasRef.add(data);
      return doc.id;
    } catch (e) {
      throw Exception("Error al guardar la reserva: $e");
    }
  }

  Stream<QuerySnapshot> getReservasStream() {
    return reservasRef.orderBy("createdAt", descending: true).snapshots();
  }

  Future<void> deleteReserva(String id) async {
    await reservasRef.doc(id).delete();
  }
}
