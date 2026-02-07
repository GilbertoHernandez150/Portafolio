import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/responsive.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

/// ===============================
/// MODELO DE MESA
/// ===============================
class Mesa {
  final String id;
  final int numero;
  final int capacidad;
  final bool disponible;

  Mesa({
    required this.id,
    required this.numero,
    required this.capacidad,
    required this.disponible,
  });
}

class EditReservationScreen extends StatefulWidget {
  const EditReservationScreen({super.key});

  @override
  EditReservationScreenState createState() => EditReservationScreenState();
}

class EditReservationScreenState extends State<EditReservationScreen> {
  GoogleMapController? mapController;

  // Form
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();
  final TextEditingController correoCtrl = TextEditingController();
  final TextEditingController personasCtrl = TextEditingController();
  final TextEditingController fechaCtrl = TextEditingController();

  // Datos de la reserva
  String? reservaId;

  String? restaurantId; // ID en Firestore
  String? restaurantName; // Nombre solo para mostrar

  String? sucursalId;
  String? sucursalName;

  String? fechaISO; // "2025-02-02"
  String? horarioSeleccionado;

  // Para poblar dropdowns
  List<QueryDocumentSnapshot> restaurantesDocs = [];
  List<QueryDocumentSnapshot> sucursalesDocs = [];

  // Horarios calculados
  List<String> horariosDisponibles = [];
  bool cargandoHorarios = false;

  // Mesas
  List<Mesa> _mesas = [];
  bool _loadingMesas = false;
  int _totalMesas = 0;
  int _mesasDisponiblesGlobal = 0;
  int _mesasDisponiblesHorario = 0;
  Set<String> _mesasOcupadasHorario = {};

  // Mapa
  LatLng mapPosition = const LatLng(18.4861, -69.9312);

  // -------------------------------------------------------------------
  // Cargar argumentos que vienen desde MyReservationsScreen
  // -------------------------------------------------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _cargarDatosIniciales(args);
    }

    _cargarRestaurantes();
  }

  void _cargarDatosIniciales(Map<String, dynamic> data) {
    reservaId = data["id"];

    nombreCtrl.text = data["nombre"] ?? "";
    telefonoCtrl.text = data["telefono"] ?? "";
    correoCtrl.text = data["correo"] ?? "";
    personasCtrl.text = data["personas"]?.toString() ?? "1";

    restaurantId = data["restauranteId"];
    restaurantName = data["restaurante"];

    sucursalId = data["sucursalId"];
    sucursalName = data["sucursal"];

    fechaISO = data["fecha"]; // "2025-02-02"
    horarioSeleccionado = data["hora"]; // "9:00 AM"

    // Mostrar la fecha inicial en el campo de texto
    if (fechaISO != null) {
      fechaCtrl.text = fechaISO!;
    }
  }

  // -------------------------------------------------------------------
  // Utilidades de FECHA
  // -------------------------------------------------------------------
  String _fechaTextoReal(DateTime d) {
    // YYYY-MM-DD
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _fechaBonita(DateTime d) {
    // DD/MM/YYYY
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: fechaISO != null
          ? DateTime.parse(fechaISO!)
          : hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 60)),
      locale: const Locale('es', 'ES'),
    );

    if (picked == null) return;

    setState(() {
      fechaISO = _fechaTextoReal(picked);
      fechaCtrl.text = _fechaBonita(picked);
      horarioSeleccionado = null;
      horariosDisponibles = [];
      _mesasOcupadasHorario.clear();
      _mesasDisponiblesHorario = _mesasDisponiblesGlobal;
    });

    await _cargarHorarios();
  }

  // -------------------------------------------------------------------
  // Firestore: restaurantes y sucursales
  // -------------------------------------------------------------------
  Future<void> _cargarRestaurantes() async {
    final snap =
        await FirebaseFirestore.instance.collection("restaurants").get();

    restaurantesDocs = snap.docs;

    // Si solo tengo el nombre pero no el id, intentar empatar
    if (restaurantId == null && restaurantName != null) {
      try {
        final doc = restaurantesDocs.firstWhere(
          (d) => (d.data() as Map<String, dynamic>)["nombre"] == restaurantName,
        );
        restaurantId = doc.id;
      } catch (_) {}
    }

    setState(() {});

    if (restaurantId != null) {
      await _cargarSucursales();
    }
  }

  Future<void> _cargarSucursales() async {
    if (restaurantId == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("restaurants")
        .doc(restaurantId)
        .collection("sucursales")
        .get();

    sucursalesDocs = snap.docs;

    // Igual que arriba, si solo tengo nombre, buscar id
    if (sucursalId == null && sucursalName != null) {
      try {
        final doc = sucursalesDocs.firstWhere(
          (d) => (d.data() as Map<String, dynamic>)["nombre"] == sucursalName,
        );
        sucursalId = doc.id;
      } catch (_) {}
    }

    // Actualizar posición del mapa con la sucursal actual
    if (sucursalId != null) {
      try {
        final doc = sucursalesDocs.firstWhere((d) => d.id == sucursalId);
        final data = doc.data() as Map<String, dynamic>;
        final lat = (data["lat"] ?? 0).toDouble();
        final lng = (data["lng"] ?? 0).toDouble();
        mapPosition = LatLng(lat, lng);

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: mapPosition, zoom: 16),
          ),
        );
      } catch (_) {}
    }

    // Cargar mesas de esa sucursal
    await _loadMesas();

    setState(() {});

    if (fechaISO != null && sucursalId != null) {
      await _cargarHorarios();
    }
  }

  // -------------------------------------------------------------------
  // Horarios: parsear, generar, cargar desde Firestore
  // -------------------------------------------------------------------
  TimeOfDay _parseTime(String str) {
    // "9:00 AM" -> 09:00 (24h)
    final parts = str.split(" ");
    final hm = parts[0].split(":");
    int hour = int.parse(hm[0]);
    final int minute = int.parse(hm[1]);
    final ampm = parts.length > 1 ? parts[1].toUpperCase() : "AM";

    if (ampm == "PM" && hour != 12) hour += 12;
    if (ampm == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  List<String> _generarHoras(String apertura, String cierre, int intervalo) {
    final TimeOfDay a = _parseTime(apertura);
    final TimeOfDay c = _parseTime(cierre);

    int inicio = a.hour * 60 + a.minute;
    final int fin = c.hour * 60 + c.minute;

    final List<String> resultado = [];

    while (inicio < fin) {
      final int h = inicio ~/ 60;
      final int m = inicio % 60;

      final t = TimeOfDay(hour: h, minute: m);
      resultado.add(t.format(context)); // "9:00 AM"

      inicio += intervalo;
    }

    return resultado;
  }

  Future<void> _cargarHorarios() async {
    if (restaurantId == null || sucursalId == null || fechaISO == null) {
      horariosDisponibles = [];
      horarioSeleccionado = null;
      setState(() {});
      return;
    }

    setState(() {
      cargandoHorarios = true;
      horariosDisponibles = [];
    });

    try {
      // fechaISO debería ser "YYYY-MM-DD"
      final partes = fechaISO!.split("-");
      final fecha = DateTime(
        int.parse(partes[0]),
        int.parse(partes[1]),
        int.parse(partes[2]),
      );

      final dias = [
        "lunes",
        "martes",
        "miercoles",
        "jueves",
        "viernes",
        "sabado",
        "domingo",
      ];

      final diaSemana = dias[fecha.weekday - 1];

      final snap = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("sucursales")
          .doc(sucursalId)
          .collection("horarios")
          .doc(diaSemana)
          .get();

      if (!snap.exists) {
        horariosDisponibles = [];
        horarioSeleccionado = null;
      } else {
        final data = snap.data()!;
        horariosDisponibles = _generarHoras(
          data["apertura"],
          data["cierre"],
          data["intervalo"],
        );

        // Si el horario anterior sigue estando disponible, mantenerlo seleccionado
        if (horarioSeleccionado != null &&
            !horariosDisponibles.contains(horarioSeleccionado)) {
          horarioSeleccionado = null;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error obteniendo horarios: $e")),
        );
      }
    }

    if (mounted) {
      setState(() => cargandoHorarios = false);
    }

    // Actualizar ocupación de mesas para el horario actual (si hay)
    if (horarioSeleccionado != null) {
      await _actualizarOcupacionMesas();
    }
  }

  // -------------------------------------------------------------------
  // CARGAR MESAS
  // -------------------------------------------------------------------
  Future<void> _loadMesas() async {
    if (restaurantId == null || sucursalId == null) return;

    setState(() {
      _loadingMesas = true;
      _mesas = [];
      _mesasOcupadasHorario.clear();
      _mesasDisponiblesHorario = 0;
      _mesasDisponiblesGlobal = 0;
      _totalMesas = 0;
    });

    final snap = await FirebaseFirestore.instance
        .collection("restaurants")
        .doc(restaurantId)
        .collection("sucursales")
        .doc(sucursalId)
        .collection("mesas")
        .get();

    final mesas = snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return Mesa(
        id: d.id,
        numero: data["numero"] ?? 0,
        capacidad: data["capacidad"] ?? 0,
        disponible: data["disponible"] ?? true,
      );
    }).toList();

    setState(() {
      _mesas = mesas;
      _totalMesas = mesas.length;
      _mesasDisponiblesGlobal = mesas.where((m) => m.disponible).length;
      _mesasDisponiblesHorario = _mesasDisponiblesGlobal;
      _loadingMesas = false;
    });
  }

  // -------------------------------------------------------------------
  // MESAS OCUPADAS EN FECHA + HORA
  // -------------------------------------------------------------------
  Future<void> _actualizarOcupacionMesas() async {
    if (sucursalId == null ||
        fechaISO == null ||
        horarioSeleccionado == null ||
        _mesas.isEmpty) {
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection("reservas")
        .where("sucursalId", isEqualTo: sucursalId)
        .where("fecha", isEqualTo: fechaISO)
        .where("hora", isEqualTo: horarioSeleccionado)
        .get();

    final ocupadas = snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)["mesaId"])
        .whereType<String>()
        .toSet();

    setState(() {
      _mesasOcupadasHorario = ocupadas;
      _mesasDisponiblesHorario = _mesas
          .where((m) => m.disponible && !ocupadas.contains(m.id))
          .length;
    });
  }

  // -------------------------------------------------------------------
  // ASIGNAR MESA AUTOMÁTICAMENTE
  // -------------------------------------------------------------------
  Future<Mesa?> _asignarMesaAutomatica(int personas) async {
    if (_mesas.isEmpty) {
      await _loadMesas();
    }

    await _actualizarOcupacionMesas();

    final candidatas = _mesas.where((m) {
      final ocupada = _mesasOcupadasHorario.contains(m.id);
      return m.disponible && !ocupada && m.capacidad >= personas;
    }).toList();

    if (candidatas.isEmpty) return null;

    candidatas.sort((a, b) => a.capacidad.compareTo(b.capacidad));
    return candidatas.first;
  }

  // -------------------------------------------------------------------
  // WIDGET – MESAS DISPONIBLES
  // -------------------------------------------------------------------
  Widget _buildMesasInfo() {
    if (sucursalId == null) return const SizedBox.shrink();

    if (_loadingMesas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mesas.isEmpty) {
      return const Text(
        "Esta sucursal no tiene mesas registradas.",
        style: TextStyle(color: Colors.redAccent),
      );
    }

    final textoDisponibles = horarioSeleccionado == null
        ? "Mesas disponibles: $_mesasDisponiblesGlobal de $_totalMesas"
        : "Mesas disponibles para este horario: "
          "$_mesasDisponiblesHorario de $_totalMesas";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textoDisponibles,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _mesas.map((m) {
              final ocupada = _mesasOcupadasHorario.contains(m.id);
              final libre = m.disponible && !ocupada;

              return Container(
                width: 110,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: libre
                      ? Colors.green.withOpacity(0.08)
                      : Colors.red.withOpacity(0.05),
                  border: Border.all(
                    color: libre ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Mesa ${m.numero}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: libre ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Cap: ${m.capacidad}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      libre ? "Libre" : "Ocupada",
                      style: TextStyle(
                        fontSize: 12,
                        color: libre ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Guardar cambios de la reserva
  // -------------------------------------------------------------------
  Future<void> _guardarCambios() async {
    if (reservaId == null) return;

    if (restaurantId == null ||
        sucursalId == null ||
        fechaISO == null ||
        horarioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Seleccione restaurante, sucursal, fecha y horario.",
          ),
        ),
      );
      return;
    }

    final personas = int.tryParse(personasCtrl.text) ?? 1;

    final mesaAsignada = await _asignarMesaAutomatica(personas);

    if (mesaAsignada == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No hay una mesa disponible para esa cantidad de personas en ese horario.",
          ),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("reservas")
        .doc(reservaId)
        .update({
      "nombre": nombreCtrl.text.trim(),
      "telefono": telefonoCtrl.text.trim(),
      "correo": correoCtrl.text.trim(),
      "personas": personas,
      "restaurante": restaurantName,
      "restauranteId": restaurantId,
      "sucursal": sucursalName,
      "sucursalId": sucursalId,
      "fecha": fechaISO,
      "hora": horarioSeleccionado,
      "mesaId": mesaAsignada.id,
      "mesaNumero": mesaAsignada.numero,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reserva actualizada correctamente")),
    );

    Navigator.pop(context);
  }

  // -------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final double padding = Responsive.isMobile(context) ? 15 : 30;
    final double spacing = Responsive.isMobile(context) ? 15 : 20;
    final double mapHeight = Responsive.isMobile(context) ? 230 : 350;

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Reserva")),

      body: restaurantesDocs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: ListView(
                  children: [
                    // DATOS BÁSICOS
                    CustomInput(
                      label: "Nombre completo",
                      controller: nombreCtrl,
                    ),
                    SizedBox(height: spacing),

                    CustomInput(
                      label: "Teléfono",
                      controller: telefonoCtrl,
                    ),
                    SizedBox(height: spacing),

                    CustomInput(
                      label: "Correo",
                      controller: correoCtrl,
                    ),
                    SizedBox(height: spacing),

                    CustomInput(
                      label: "Cantidad de personas",
                      controller: personasCtrl,
                    ),
                    SizedBox(height: spacing),

                    // RESTAURANTE
                    DropdownButtonFormField<String>(
                      value: restaurantId,
                      decoration:
                          const InputDecoration(labelText: "Restaurante"),
                      items: restaurantesDocs.map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: d.id,
                          child: Text(data["nombre"] ?? "Sin nombre"),
                        );
                      }).toList(),
                      onChanged: (id) async {
                        if (id == null) return;

                        final doc =
                            restaurantesDocs.firstWhere((e) => e.id == id);
                        final data = doc.data() as Map<String, dynamic>;

                        setState(() {
                          restaurantId = id;
                          restaurantName = data["nombre"] ?? "";
                          sucursalId = null;
                          sucursalName = null;
                          sucursalesDocs = [];
                          horariosDisponibles = [];
                          horarioSeleccionado = null;
                          _mesas = [];
                          _mesasOcupadasHorario.clear();
                          _mesasDisponiblesGlobal = 0;
                          _mesasDisponiblesHorario = 0;
                          _totalMesas = 0;
                        });

                        await _cargarSucursales();
                      },
                    ),
                    SizedBox(height: spacing),

                    // SUCURSAL
                    if (restaurantId != null)
                      DropdownButtonFormField<String>(
                        value: sucursalId,
                        decoration:
                            const InputDecoration(labelText: "Sucursal"),
                        items: sucursalesDocs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: d.id,
                            child: Text(data["nombre"] ?? "Sucursal"),
                          );
                        }).toList(),
                        onChanged: (id) async {
                          if (id == null) return;

                          final doc =
                              sucursalesDocs.firstWhere((e) => e.id == id);
                          final data = doc.data() as Map<String, dynamic>;

                          sucursalId = id;
                          sucursalName = data["nombre"] ?? "";

                          // actualizar mapa
                          final lat = (data["lat"] ?? 0).toDouble();
                          final lng = (data["lng"] ?? 0).toDouble();
                          mapPosition = LatLng(lat, lng);

                          mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: mapPosition, zoom: 16),
                            ),
                          );

                          setState(() {
                            horariosDisponibles = [];
                            horarioSeleccionado = null;
                          });

                          await _loadMesas();
                          if (fechaISO != null) {
                            await _cargarHorarios();
                          }
                        },
                      ),
                    SizedBox(height: spacing),

                    // FECHA EDITABLE
                    TextField(
                      controller: fechaCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Fecha",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _seleccionarFecha,
                    ),
                    SizedBox(height: spacing),

                    // HORARIOS
                    if (cargandoHorarios)
                      const Center(child: CircularProgressIndicator())
                    else if (horariosDisponibles.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: horarioSeleccionado,
                        decoration:
                            const InputDecoration(labelText: "Horario"),
                        items: horariosDisponibles
                            .map(
                              (h) => DropdownMenuItem<String>(
                                value: h,
                                child: Text(h),
                              ),
                            )
                            .toList(),
                        onChanged: (v) async {
                          setState(() => horarioSeleccionado = v);
                          await _actualizarOcupacionMesas();
                        },
                      )
                    else if (sucursalId != null && fechaISO != null)
                      const Text(
                        "No hay horarios configurados para esa fecha.",
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: spacing),

                    // MESAS DISPONIBLES
                    _buildMesasInfo(),
                    SizedBox(height: spacing),

                    // MAPA
                    Container(
                      height: mapHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: GoogleMap(
                          onMapCreated: (controller) =>
                              mapController = controller,
                          initialCameraPosition: CameraPosition(
                            target: mapPosition,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("loc"),
                              position: mapPosition,
                              infoWindow: InfoWindow(
                                title: sucursalName ?? "Sucursal",
                              ),
                            ),
                          },
                          zoomControlsEnabled: true,
                        ),
                      ),
                    ),

                    SizedBox(height: spacing + 10),

                    // BOTÓN GUARDAR
                    CustomButton(
                      text: "Guardar Cambios",
                      onPressed: _guardarCambios,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
