import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtiene la lista de horarios disponibles para una fecha dada.
  ///
  /// Estructura asumida:
  /// - restaurants/{restaurantId}/sucursales/{sucursalId}/configHorarios/{diaSemana}
  ///    - apertura: "10:00" o "10:00 AM"
  ///    - cierre:   "23:00" o "11:00 PM"
  ///    - intervaloMinutos: 30
  ///    - capacidadMesas (opcional) o maxReservasPorHora (opcional)
  ///
  /// - reservas (colección global o por restaurante, aquí asumo global):
  ///    - restaurantId, sucursalId, fecha ("YYYY-MM-DD"), hora ("HH:mm")
  Future<List<String>> getHorariosDisponibles({
    required String restaurantId,
    required String sucursalId,
    required String fecha, // "YYYY-MM-DD"
  }) async {
    final DateTime date;
    try {
      date = DateTime.parse(fecha);
    } catch (_) {
      return [];
    }

    final String diaSemana = _nombreDiaFirestore(date.weekday);

    final configRef = _db
        .collection("restaurants")
        .doc(restaurantId)
        .collection("sucursales")
        .doc(sucursalId)
        .collection("configHorarios")
        .doc(diaSemana);

    final configSnap = await configRef.get();
    if (!configSnap.exists) return [];

    final data = configSnap.data() as Map<String, dynamic>;

    final String aperturaStr = (data["apertura"] ?? data["horaApertura"] ?? "00:00").toString();
    final String cierreStr = (data["cierre"] ?? data["horaCierre"] ?? "00:00").toString();
    final int intervaloMinutos = (data["intervaloMinutos"] ?? 30) is int
        ? data["intervaloMinutos"]
        : int.tryParse(data["intervaloMinutos"].toString()) ?? 30;

    final int capacidadMesas = (data["capacidadMesas"] ??
            data["maxReservasPorHora"] ??
            data["mesas"] ??
            0) is int
        ? (data["capacidadMesas"] ??
            data["maxReservasPorHora"] ??
            data["mesas"] ??
            0)
        : int.tryParse(
                (data["capacidadMesas"] ??
                        data["maxReservasPorHora"] ??
                        data["mesas"] ??
                        "0")
                    .toString()) ??
            0;

    // Generar todos los horarios posibles entre apertura y cierre
    final int aperturaMin = _parseHoraToMinutes(aperturaStr);
    final int cierreMin = _parseHoraToMinutes(cierreStr);

    if (aperturaMin >= cierreMin) return [];

    final List<String> horarios = [];
    for (int m = aperturaMin; m < cierreMin; m += intervaloMinutos) {
      horarios.add(_formatMinutes(m));
    }

    // Traer reservas existentes para ese día y sucursal
    final reservasSnap = await _db
        .collection("reservas")
        .where("restaurantId", isEqualTo: restaurantId)
        .where("sucursalId", isEqualTo: sucursalId)
        .where("fecha", isEqualTo: fecha)
        .get();

    final Map<String, int> contadorPorHora = {};

    for (final doc in reservasSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String hora = (data["hora"] ?? "").toString();
      if (hora.isEmpty) continue;

      contadorPorHora[hora] = (contadorPorHora[hora] ?? 0) + 1;
    }

    // Filtrar horarios disponibles según capacidad
    final List<String> disponibles = horarios.where((h) {
      final ocupadas = contadorPorHora[h] ?? 0;
      if (capacidadMesas <= 0) return true; // sin límite
      return ocupadas < capacidadMesas;
    }).toList();

    return disponibles;
  }

  // ------------------ helpers ------------------

  String _nombreDiaFirestore(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "lunes";
      case DateTime.tuesday:
        return "martes";
      case DateTime.wednesday:
        return "miercoles";
      case DateTime.thursday:
        return "jueves";
      case DateTime.friday:
        return "viernes";
      case DateTime.saturday:
        return "sabado";
      case DateTime.sunday:
      default:
        return "domingo";
    }
  }

  /// Convierte "10:00", "10:00 AM", "22:30" → minutos desde 00:00
  int _parseHoraToMinutes(String raw) {
    String h = raw.trim().toUpperCase();

    bool pm = h.contains("PM");
    h = h.replaceAll("AM", "").replaceAll("PM", "").trim();

    final parts = h.split(":");
    int hour = int.tryParse(parts[0]) ?? 0;
    int min = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    if (pm && hour < 12) hour += 12;
    if (!pm && hour == 12 && raw.toUpperCase().contains("AM")) hour = 0;

    return hour * 60 + min;
  }

  /// Convierte minutos → "HH:mm" 24h
  String _formatMinutes(int m) {
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return "$h:$mm";
  }
}
