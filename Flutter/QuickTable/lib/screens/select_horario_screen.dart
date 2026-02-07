import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/horario_item.dart';

class SelectHorarioScreen extends StatelessWidget {
  final String restaurantId;
  final String sucursalId;
  final String fecha;
  final int personas;

  // 🔥 YA NO ES CONST (NO PUEDE SER CONST PORQUE db NO ES CONST)
  SelectHorarioScreen({
    super.key,
    required this.restaurantId,
    required this.sucursalId,
    required this.fecha,
    required this.personas,
  });

  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar Horario")),
      
      body: FutureBuilder(
        future: db
            .collection("restaurants")
            .doc(restaurantId)
            .collection("sucursales")
            .doc(sucursalId)
            .collection("configHorarios")
            .doc(_diaSemana())
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final apertura = data["apertura"];
          final cierre = data["cierre"];
          final intervalos = data["intervalos"];

          final horarios = generarHorarios(apertura, cierre, intervalos);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: horarios.map((h) {
              return StreamBuilder(
                stream: db
                    .collection("disponibilidad")
                    .doc("${sucursalId}_$fecha")
                    .snapshots(),
                builder: (context, dispSnap) {
                  int mesasOcupadas = 0;
                  int mesasTotales = 10;

                  if (dispSnap.hasData && dispSnap.data!.exists) {
                    final d = dispSnap.data!;
                    mesasOcupadas = d["mesasOcupadas"];
                    mesasTotales = d["mesasTotales"];
                  }

                  int disponibles = mesasTotales - mesasOcupadas;

                  return HorarioItem(
                    hora: h,
                    disponible: disponibles > 0,
                    casiLleno: disponibles <= 3 && disponibles > 0,
                    onTap: () {
                      Navigator.pop(context, h);
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// Obtiene el día de la semana según la fecha seleccionada.
  String _diaSemana() {
    final dias = [
      "lunes",
      "martes",
      "miercoles",
      "jueves",
      "viernes",
      "sabado",
      "domingo"
    ];

    final fechaDT = DateTime.parse(fecha);
    return dias[fechaDT.weekday - 1];
  }
}

///////////////////////////////////////////////////////////////////////////////
// 🔥 HELPER FUNCTIONS (Generación de horarios y utilidades)
///////////////////////////////////////////////////////////////////////////////

List<String> generarHorarios(String apertura, String cierre, int intervalo) {
  final List<String> horarios = [];

  TimeOfDay inicio = _parseTime(apertura);
  TimeOfDay fin = _parseTime(cierre);

  while (_compareTime(inicio, fin) < 0) {
    horarios.add(_formatTime(inicio));
    inicio = _sumarMinutos(inicio, intervalo);
  }

  return horarios;
}

TimeOfDay _parseTime(String hhmm) {
  final partes = hhmm.split(":");
  return TimeOfDay(
    hour: int.parse(partes[0]),
    minute: int.parse(partes[1]),
  );
}

String _formatTime(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return "$h:$m";
}

int _compareTime(TimeOfDay a, TimeOfDay b) {
  if (a.hour == b.hour) return a.minute - b.minute;
  return a.hour - b.hour;
}

TimeOfDay _sumarMinutos(TimeOfDay t, int min) {
  final total = t.hour * 60 + t.minute + min;
  return TimeOfDay(
    hour: total ~/ 60,
    minute: total % 60,
  );
}
