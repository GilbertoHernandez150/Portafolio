import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import '../utils/reservation_pdf.dart';
import 'package:pdf/pdf.dart';

import '../widgets/custom_button.dart';
import '../helpers/responsive.dart';
import '../services/reservation_service.dart';

import '../services/email_service.dart'; // ⭐ NUEVO

/// ===============================================
/// MODELOS
/// ===============================================

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

class Reserva {
  String nombre;
  String telefono;
  String correo;
  String restaurante;
  String sucursal;
  String fecha;
  String hora;
  int personas;

  String? restauranteId;
  String? sucursalId;
  String? mesaId;
  int? mesaNumero;

  Reserva({
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.restaurante,
    required this.sucursal,
    required this.fecha,
    required this.hora,
    required this.personas,
    this.restauranteId,
    this.sucursalId,
    this.mesaId,
    this.mesaNumero,
  });
}

/// ===============================================
/// PANTALLA PRINCIPAL
/// ===============================================

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  ReservationFormScreenState createState() => ReservationFormScreenState();
}

class ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController peopleCtrl = TextEditingController();
  final TextEditingController fechaCtrl = TextEditingController();

  String? restaurantId;
  String? sucursalId;
  String? selectedRestaurant;
  String? selectedSucursal;

  String? selectedHorario;
  String? fechaISO;

  GoogleMapController? mapController;
  LatLng mapPosition = const LatLng(18.4861, -69.9312);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ReservationService _reservationService = ReservationService();

  // Horarios
  List<String> horariosDisponibles = [];
  bool cargandoHorarios = false;
  bool _consultoHorarios = false; // ya se intentó cargar horarios
  bool _hayHorariosFecha = false; // esa fecha tiene horarios

  // Mesas
  List<Mesa> _mesas = [];
  bool _loadingMesas = false;
  int _totalMesas = 0;
  int _mesasDisponiblesGlobal = 0;
  int _mesasDisponiblesHorario = 0;
  Set<String> _mesasOcupadasHorario = {};

  String? provincia;
  String? municipio;
  String? sector;

  bool _argsProcesados = false;

  /// ===============================================
  /// INIT + ARGUMENTOS
  /// ===============================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argsProcesados) return;
    _argsProcesados = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    // Viene desde RestaurantDetailScreen
    if (args != null && args is Map<String, dynamic>) {
      restaurantId = args["restaurantId"];
      sucursalId = args["sucursalId"];
      selectedRestaurant = args["restaurantName"];
      selectedSucursal = args["sucursalName"];
    }

    // Si ya viene con sucursal (cuando das a "Reservar en esta sucursal")
    if (restaurantId != null && sucursalId != null) {
      _loadMesas();
      _cargarDatosSucursalInicial();
    }
  }

  /// Cargar provincia/municipio/sector/lat/lng cuando llegan ids por argumentos
  Future<void> _cargarDatosSucursalInicial() async {
    if (restaurantId == null || sucursalId == null) return;

    final doc = await _db
        .collection("restaurants")
        .doc(restaurantId)
        .collection("sucursales")
        .doc(sucursalId)
        .get();

    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      provincia = data["provincia"]?.toString();
      municipio = data["municipio"]?.toString();
      sector = data["sector"]?.toString();
      mapPosition = LatLng(
        (data["lat"] ?? 0).toDouble(),
        (data["lng"] ?? 0).toDouble(),
      );
    });
  }

  /// ===============================================
  /// FECHA
  /// ===============================================

  String _fechaTextoReal(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _fechaBonita(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 30)),
      locale: const Locale('es', 'ES'),
    );

    if (picked == null) return;

    setState(() {
      fechaISO = _fechaTextoReal(picked);
      fechaCtrl.text = _fechaBonita(picked);
      selectedHorario = null;

      _consultoHorarios = false;
      _hayHorariosFecha = false;

      _mesasOcupadasHorario.clear();
      _mesasDisponiblesHorario = _mesasDisponiblesGlobal;
    });

    await _cargarHorariosDisponibles();
  }

  /// ===============================================
  /// PARSE & GENERAR HORAS
  /// ===============================================

  TimeOfDay _parseTime(String str) {
    final parts = str.split(" ");
    final hm = parts[0].split(":");

    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);
    final ampm = parts.length > 1 ? parts[1].toUpperCase() : "AM";

    if (ampm == "PM" && hour != 12) hour += 12;
    if (ampm == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  List<String> _generarHorasDisponibles(
    String apertura,
    String cierre,
    int intervalo,
  ) {
    TimeOfDay a = _parseTime(apertura);
    TimeOfDay c = _parseTime(cierre);

    int inicio = a.hour * 60 + a.minute;
    int fin = c.hour * 60 + c.minute;

    List<String> lista = [];

    while (inicio < fin) {
      int h = inicio ~/ 60;
      int m = inicio % 60;

      final time = TimeOfDay(hour: h, minute: m);
      lista.add(time.format(context)); // ej: "9:00 AM"

      inicio += intervalo;
    }

    return lista;
  }

  /// ===============================================
  /// CARGAR HORARIOS
  /// ===============================================

  Future<void> _cargarHorariosDisponibles() async {
    if (restaurantId == null || sucursalId == null || fechaISO == null) {
      setState(() {
        horariosDisponibles = [];
        selectedHorario = null;
        cargandoHorarios = false;
        _consultoHorarios = false;
        _hayHorariosFecha = false;
      });
      return;
    }

    setState(() {
      cargandoHorarios = true;
      horariosDisponibles = [];
      _consultoHorarios = false;
      _hayHorariosFecha = false;
    });

    try {
      final f = DateTime.parse(fechaISO!);
      const dias = [
        "lunes",
        "martes",
        "miercoles",
        "jueves",
        "viernes",
        "sabado",
        "domingo",
      ];
      final diaNombre = dias[f.weekday - 1];

      final doc = await _db
          .collection("restaurants")
          .doc(restaurantId)
          .collection("sucursales")
          .doc(sucursalId)
          .collection("horarios")
          .doc(diaNombre)
          .get();

      if (!doc.exists) {
        if (!mounted) return;
        setState(() {
          horariosDisponibles = [];
          selectedHorario = null;
          cargandoHorarios = false;
          _consultoHorarios = true;
          _hayHorariosFecha = false;
        });
        return;
      }

      final data = doc.data()!;
      final apertura = data["apertura"];
      final cierre = data["cierre"];
      final intervalo = data["intervalo"];

      final generados = _generarHorasDisponibles(apertura, cierre, intervalo);

      if (!mounted) return;

      setState(() {
        horariosDisponibles = generados;
        selectedHorario = null;
        cargandoHorarios = false;
        _consultoHorarios = true;
        _hayHorariosFecha = generados.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargandoHorarios = false;
        horariosDisponibles = [];
        selectedHorario = null;
        _consultoHorarios = true;
        _hayHorariosFecha = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error obteniendo horarios: $e")));
    }
  }

  /// ===============================================
  /// CARGAR MESAS
  /// ===============================================

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

    final snap = await _db
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

  /// ===============================================
  /// MESAS OCUPADAS EN FECHA + HORA
  /// ===============================================

  Future<void> _actualizarOcupacionMesas() async {
    if (sucursalId == null ||
        fechaISO == null ||
        selectedHorario == null ||
        _mesas.isEmpty) {
      return;
    }

    final snap = await _db
        .collection("reservas")
        .where("sucursalId", isEqualTo: sucursalId)
        .where("fecha", isEqualTo: fechaISO)
        .where("hora", isEqualTo: selectedHorario)
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

  /// ===============================================
  /// ASIGNAR MESA AUTOMÁTICAMENTE
  /// ===============================================

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

  /// ===============================================
  /// GOOGLE MAPS
  /// ===============================================

  Future<void> _abrirEnGoogleMaps() async {
    final url =
        "https://www.google.com/maps/search/?api=1&query=${mapPosition.latitude},${mapPosition.longitude}";
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir Google Maps")),
      );
    }
  }

  /// ===============================================
  /// WIDGET – MESAS DISPONIBLES
  /// ===============================================

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

    final textoDisponibles = selectedHorario == null
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
                  border: Border.all(color: libre ? Colors.green : Colors.red),
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

  /// ===============================================
  /// UI
  /// ===============================================

  @override
  Widget build(BuildContext context) {
    final spacing = Responsive.isMobile(context) ? 15.0 : 20.0;
    final mapHeight = Responsive.isMobile(context) ? 230.0 : 350.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Reservar Mesa")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Responsive.isMobile(context) ? 15 : 25),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // ---------------- DATOS CLIENTE ----------------
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre completo",
                  ),
                  validator: (v) => v!.isEmpty ? "Obligatorio" : null,
                ),
                SizedBox(height: spacing),

                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                  validator: (v) => v!.isEmpty ? "Obligatorio" : null,
                ),
                SizedBox(height: spacing),

                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Correo"),
                  validator: (v) => v!.isEmpty ? "Obligatorio" : null,
                ),
                SizedBox(height: spacing),

                TextFormField(
                  controller: peopleCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Cantidad de personas",
                  ),
                  validator: (v) => v!.isEmpty ? "Obligatorio" : null,
                ),
                SizedBox(height: spacing),

                // ---------------- RESTAURANTE ----------------
                StreamBuilder<QuerySnapshot>(
                  stream: _db.collection("restaurants").snapshots(),
                  builder: (_, s) {
                    if (!s.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final docs = s.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: restaurantId,
                      decoration: const InputDecoration(
                        labelText: "Restaurante",
                      ),
                      items: docs.map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: d.id,
                          child: Text(data["nombre"] ?? "Sin nombre"),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        final d = docs.firstWhere((e) => e.id == v);
                        final data = d.data() as Map<String, dynamic>;

                        setState(() {
                          restaurantId = v;
                          selectedRestaurant = data["nombre"];

                          // Reset sucursal
                          sucursalId = null;
                          selectedSucursal = null;

                          // Reset ubicación
                          provincia = null;
                          municipio = null;
                          sector = null;
                          mapPosition = const LatLng(18.4861, -69.9312);

                          // Reset fecha/horarios
                          fechaISO = null;
                          fechaCtrl.text = "";
                          horariosDisponibles = [];
                          selectedHorario = null;
                          _consultoHorarios = false;
                          _hayHorariosFecha = false;

                          // Reset mesas
                          _mesas = [];
                          _mesasDisponiblesGlobal = 0;
                          _mesasDisponiblesHorario = 0;
                          _totalMesas = 0;
                          _mesasOcupadasHorario.clear();
                        });
                      },
                      validator: (v) =>
                          v == null ? "Seleccione un restaurante" : null,
                    );
                  },
                ),
                SizedBox(height: spacing),

                // ---------------- SUCURSAL ----------------
                if (restaurantId != null)
                  StreamBuilder<QuerySnapshot>(
                    stream: _db
                        .collection("restaurants")
                        .doc(restaurantId)
                        .collection("sucursales")
                        .snapshots(),
                    builder: (_, s) {
                      if (!s.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = s.data!.docs;

                      return DropdownButtonFormField<String>(
                        value: sucursalId,
                        decoration: const InputDecoration(
                          labelText: "Sucursal",
                        ),
                        items: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: d.id,
                            child: Text(data["nombre"] ?? "Sucursal"),
                          );
                        }).toList(),
                        onChanged: (v) async {
                          if (v == null) return;

                          final d = docs.firstWhere((e) => e.id == v);
                          final data = d.data() as Map<String, dynamic>;

                          // si ya había fecha seleccionada antes de cambiar sucursal
                          final bool yaHabiaFecha = fechaISO != null;

                          setState(() {
                            sucursalId = v;
                            selectedSucursal = data["nombre"];

                            provincia = data["provincia"]?.toString();
                            municipio = data["municipio"]?.toString();
                            sector = data["sector"]?.toString();

                            mapPosition = LatLng(
                              (data["lat"] ?? 0).toDouble(),
                              (data["lng"] ?? 0).toDouble(),
                            );

                            // Reset horarios seleccionados
                            selectedHorario = null;
                            _consultoHorarios = false;
                            _hayHorariosFecha = false;

                            // Reset ocupación horario
                            _mesasOcupadasHorario.clear();
                          });

                          // Cargar mesas para esa sucursal
                          await _loadMesas();

                          // 👇 FIX IMPORTANTE:
                          // Si el usuario eligió la fecha primero (sin sucursal),
                          // y luego cambia/elige la sucursal, recargamos horarios.
                          if (yaHabiaFecha) {
                            await _cargarHorariosDisponibles();
                          }
                        },
                        validator: (v) =>
                            v == null ? "Seleccione una sucursal" : null,
                      );
                    },
                  ),
                SizedBox(height: spacing),

                // Info provincia / municipio / sector
                if ((provincia ?? "").isNotEmpty ||
                    (municipio ?? "").isNotEmpty ||
                    (sector ?? "").isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((provincia ?? "").isNotEmpty)
                        Text("Provincia: $provincia"),
                      if ((municipio ?? "").isNotEmpty)
                        Text("Municipio: $municipio"),
                      if ((sector ?? "").isNotEmpty) Text("Sector: $sector"),
                      SizedBox(height: spacing),
                    ],
                  ),

                // ---------------- FECHA ----------------
                TextFormField(
                  controller: fechaCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Fecha",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _seleccionarFecha,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Seleccione una fecha" : null,
                ),
                SizedBox(height: spacing),

                // ---------------- HORARIOS ----------------
                if (cargandoHorarios)
                  const Center(child: CircularProgressIndicator())
                else if (_consultoHorarios && !_hayHorariosFecha)
                  const Text(
                    "No hay horarios disponibles para esa fecha.",
                    style: TextStyle(color: Colors.red),
                  )
                else if (horariosDisponibles.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedHorario,
                    decoration: const InputDecoration(labelText: "Horario"),
                    items: horariosDisponibles.map((h) {
                      return DropdownMenuItem<String>(value: h, child: Text(h));
                    }).toList(),
                    onChanged: (v) async {
                      setState(() => selectedHorario = v);
                      await _actualizarOcupacionMesas();
                    },
                    validator: (v) =>
                        v == null ? "Seleccione un horario" : null,
                  ),
                SizedBox(height: spacing),

                // ---------------- MESAS ----------------
                _buildMesasInfo(),
                SizedBox(height: spacing),

                // ---------------- MAPA ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Ubicación de la sucursal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _abrirEnGoogleMaps,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("Google Maps"),
                    ),
                  ],
                ),

                Container(
                  height: mapHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      onMapCreated: (c) => mapController = c,
                      initialCameraPosition: CameraPosition(
                        target: mapPosition,
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("loc"),
                          position: mapPosition,
                          infoWindow: InfoWindow(
                            title: selectedSucursal ?? "Sucursal",
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                SizedBox(height: spacing),

                // ---------------- CONFIRMAR ----------------
                CustomButton(
                  text: "Confirmar Reserva",
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    if (restaurantId == null ||
                        sucursalId == null ||
                        fechaISO == null ||
                        selectedHorario == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Seleccione restaurante, sucursal, fecha y horario.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (!_hayHorariosFecha ||
                        horariosDisponibles.isEmpty ||
                        !horariosDisponibles.contains(selectedHorario)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "No hay horarios disponibles para esa fecha.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (_mesas.isEmpty || _mesasDisponiblesHorario <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "No hay mesas disponibles para ese horario.",
                          ),
                        ),
                      );
                      return;
                    }

                    final personas = int.parse(peopleCtrl.text);

                    final mesaAsignada = await _asignarMesaAutomatica(personas);

                    if (!mounted) return;

                    if (mesaAsignada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "No hay una mesa disponible para esa cantidad de personas en ese horario.",
                          ),
                        ),
                      );
                      return;
                    }

                    final reserva = Reserva(
                      nombre: nameCtrl.text.trim(),
                      telefono: phoneCtrl.text.trim(),
                      correo: emailCtrl.text.trim(),
                      restaurante: selectedRestaurant ?? "",
                      sucursal: selectedSucursal ?? "",
                      fecha: fechaISO!,
                      hora: selectedHorario!,
                      personas: personas,
                      restauranteId: restaurantId,
                      sucursalId: sucursalId,
                      mesaId: mesaAsignada.id,
                      mesaNumero: mesaAsignada.numero,
                    );

                    // 🔵 AQUÍ VA TODO LO DEL PDF + ID DE RESERVA
                    final reservaId = await _reservationService.crearReserva(
                      reserva,
                    );

                    // ⭐ ENVÍA EL CORREO AUTOMÁTICO CON EMAILJS
                    await EmailService.enviarCorreoReserva({
                      "nombre": reserva.nombre,
                      "correo": reserva.correo,
                      "telefono": reserva.telefono,
                      "restaurante": reserva.restaurante,
                      "sucursal": reserva.sucursal,
                      "fecha": reserva.fecha,
                      "hora": reserva.hora,
                      "personas": reserva.personas.toString(),
                      "mesa": reserva.mesaNumero.toString(),
                    });

                    // Generar PDF
                    final pdfBytes = await ReservationPDF.generarPDF(
                      reserva,
                      reservaId,
                    );

                    // Mostrar PDF
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdfBytes,
                    );

                    if (!mounted) return;

                    Navigator.pushNamed(
                      context,
                      "/reservationSuccess",
                      arguments: reserva,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
