import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHorariosScreen extends StatefulWidget {
  const AdminHorariosScreen({super.key});

  @override
  State<AdminHorariosScreen> createState() => _AdminHorariosScreenState();
}

class _AdminHorariosScreenState extends State<AdminHorariosScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String? selectedRestaurantId;
  String? selectedSucursalId;

  final List<String> dias = [
    "lunes",
    "martes",
    "miercoles",
    "jueves",
    "viernes",
    "sabado",
    "domingo",
  ];

  bool loading = false;

  // ----------------------------------------------------------------
  // Seleccionar hora moderna
  // ----------------------------------------------------------------
  Future<String?> _selectTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (t == null) return null;

    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final ampm = t.period == DayPeriod.am ? "AM" : "PM";

    return "$hour:$minute $ampm";
  }

  TimeOfDay _parseTime(String str) {
    final p = str.split(" ");
    final hm = p[0].split(":");

    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);
    final ampm = p[1];

    if (ampm == "PM" && hour != 12) hour += 12;
    if (ampm == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  int _calcularIntervalo(String apertura, String cierre) {
    final a = _parseTime(apertura);
    final c = _parseTime(cierre);

    final inicio = a.hour * 60 + a.minute;
    final fin = c.hour * 60 + c.minute;

    return (fin - inicio).clamp(1, 1440);
  }

  // ----------------------------------------------------------------
  // Crear horario (modal)
  // ----------------------------------------------------------------
  void _crearHorario() {
    String? diaSeleccionado;
    String? horaApertura;
    String? horaCierre;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setS) {
          return AlertDialog(
            title: const Text("Agregar Horario"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Día"),
                  items: dias.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (v) => setS(() => diaSeleccionado = v),
                ),

                const SizedBox(height: 12),

                // Apertura
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: horaApertura),
                  decoration:
                      const InputDecoration(labelText: "Hora apertura"),
                  onTap: () async {
                    final t = await _selectTime();
                    if (t != null) setS(() => horaApertura = t);
                  },
                ),

                const SizedBox(height: 12),

                // Cierre
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: horaCierre),
                  decoration:
                      const InputDecoration(labelText: "Hora cierre"),
                  onTap: () async {
                    final t = await _selectTime();
                    if (t != null) setS(() => horaCierre = t);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (diaSeleccionado == null ||
                      horaApertura == null ||
                      horaCierre == null) return;

                  final intervalo =
                      _calcularIntervalo(horaApertura!, horaCierre!);

                  await db
                      .collection("restaurants")
                      .doc(selectedRestaurantId)
                      .collection("sucursales")
                      .doc(selectedSucursalId)
                      .collection("horarios")
                      .doc(diaSeleccionado)
                      .set({
                    "apertura": horaApertura!,
                    "cierre": horaCierre!,
                    "intervalo": intervalo,
                  });

                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------
  // Editar horario
  // ----------------------------------------------------------------
  void _editarHorario(String dia, Map<String, dynamic> data) {
    String horaApertura = data["apertura"];
    String horaCierre = data["cierre"];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setS) {
          return AlertDialog(
            title: Text("Editar — ${dia.toUpperCase()}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: horaApertura),
                  decoration:
                      const InputDecoration(labelText: "Hora apertura"),
                  onTap: () async {
                    final t = await _selectTime();
                    if (t != null) setS(() => horaApertura = t);
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: horaCierre),
                  decoration:
                      const InputDecoration(labelText: "Hora cierre"),
                  onTap: () async {
                    final t = await _selectTime();
                    if (t != null) setS(() => horaCierre = t);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final intervalo =
                      _calcularIntervalo(horaApertura, horaCierre);

                  await db
                      .collection("restaurants")
                      .doc(selectedRestaurantId)
                      .collection("sucursales")
                      .doc(selectedSucursalId)
                      .collection("horarios")
                      .doc(dia)
                      .update({
                    "apertura": horaApertura,
                    "cierre": horaCierre,
                    "intervalo": intervalo,
                  });

                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------
  // UI PRINCIPAL
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurar Horarios"),
        backgroundColor: const Color(0xFF0A4D8C),
      ),

      floatingActionButton: (selectedRestaurantId != null &&
              selectedSucursalId != null)
          ? FloatingActionButton(
              onPressed: _crearHorario,
              backgroundColor: const Color(0xFF0A4D8C),
              child: const Icon(Icons.add),
            )
          : null,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Restaurante
            StreamBuilder<QuerySnapshot>(
              stream: db.collection("restaurants").snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();

                final docs = snap.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedRestaurantId,
                  decoration: const InputDecoration(
                      labelText: "Seleccione restaurante"),
                  items: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: d.id,
                      child: Text(data["nombre"]),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedRestaurantId = v;
                      selectedSucursalId = null;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Sucursal
            if (selectedRestaurantId != null)
              StreamBuilder<QuerySnapshot>(
                stream: db
                    .collection("restaurants")
                    .doc(selectedRestaurantId)
                    .collection("sucursales")
                    .snapshots(),
                builder: (_, snap) {
                  if (!snap.hasData) return Container();

                  final docs = snap.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: selectedSucursalId,
                    decoration: const InputDecoration(
                        labelText: "Seleccione sucursal"),
                    items: docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(data["nombre"]),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedSucursalId = v;
                      });
                    },
                  );
                },
              ),

            const SizedBox(height: 16),

            // Horarios
            if (selectedSucursalId == null)
              const Text("Seleccione restaurante y sucursal.")
            else
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection("restaurants")
                      .doc(selectedRestaurantId)
                      .collection("sucursales")
                      .doc(selectedSucursalId)
                      .collection("horarios")
                      .snapshots(),
                  builder: (_, snap) {
                    if (!snap.hasData)
                      return const Center(
                          child: CircularProgressIndicator());

                    final docs = snap.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                          child: Text("No hay horarios agregados."));
                    }

                    return ListView(
                      children: docs.map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final dia = d.id;

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(dia.toUpperCase()),
                            subtitle: Text(
                              "Apertura: ${data["apertura"]}\n"
                              "Cierre: ${data["cierre"]}\n"
                              "Cada: ${data["intervalo"]} min",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _editarHorario(dia, data),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_forever,
                                      color: Colors.red),
                                  onPressed: () {
                                    db
                                        .collection("restaurants")
                                        .doc(selectedRestaurantId)
                                        .collection("sucursales")
                                        .doc(selectedSucursalId)
                                        .collection("horarios")
                                        .doc(dia)
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
