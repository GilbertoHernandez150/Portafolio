import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSucursalForm extends StatefulWidget {
  @override
  State<AdminSucursalForm> createState() => _AdminSucursalFormState();
}

class _AdminSucursalFormState extends State<AdminSucursalForm> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Controladores
  final nombreCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final provinciaCtrl = TextEditingController(); // 🔥 NUEVO
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final aperturaCtrl = TextEditingController();
  final cierreCtrl = TextEditingController();
  final mesasCtrl = TextEditingController();
  final imgCtrl = TextEditingController();

  String? restaurantId;
  String? docId;

  bool saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map) {
      restaurantId = args["restaurantId"];
      docId = args["id"];

      // Llenar campos si es edición
      nombreCtrl.text = args["nombre"] ?? "";
      direccionCtrl.text = args["direccion"] ?? "";
      provinciaCtrl.text = args["provincia"] ?? ""; // 🔥 NUEVO
      latCtrl.text = "${args["lat"] ?? ""}";
      lngCtrl.text = "${args["lng"] ?? ""}";
      aperturaCtrl.text = args["horaApertura"] ?? "";
      cierreCtrl.text = args["horaCierre"] ?? "";
      mesasCtrl.text = "${args["mesas"] ?? ""}";
      imgCtrl.text = args["imagen"] ?? "";
    }
  }

  Future<void> saveSucursal() async {
    if (saving) return;

    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: restaurantId llegó nulo")),
      );
      return;
    }

    setState(() => saving = true);

    final data = {
      "nombre": nombreCtrl.text.trim(),
      "direccion": direccionCtrl.text.trim(),
      "provincia": provinciaCtrl.text.trim(), // 🔥 NUEVO
      "lat": double.tryParse(latCtrl.text) ?? 0,
      "lng": double.tryParse(lngCtrl.text) ?? 0,
      "horaApertura": aperturaCtrl.text.trim(),
      "horaCierre": cierreCtrl.text.trim(),
      "mesas": int.tryParse(mesasCtrl.text) ?? 0,
      "imagen": imgCtrl.text.trim(),
      "creadoEl": FieldValue.serverTimestamp(),
    };

    try {
      if (docId == null) {
        await db
            .collection("restaurants")
            .doc(restaurantId)
            .collection("sucursales")
            .add(data);
      } else {
        await db
            .collection("restaurants")
            .doc(restaurantId)
            .collection("sucursales")
            .doc(docId)
            .update(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            docId == null
                ? "Sucursal creada exitosamente"
                : "Sucursal actualizada correctamente",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(docId == null ? "Registrar Sucursal" : "Editar Sucursal"),
        backgroundColor: Color(0xFF0A4D8C),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            // NOMBRE
            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: "Nombre de la Sucursal",
                hintText: "Ej: Sucursal Ágora Mall",
              ),
            ),
            SizedBox(height: 15),

            // DIRECCIÓN
            TextField(
              controller: direccionCtrl,
              decoration: InputDecoration(
                labelText: "Dirección",
                hintText: "Ej: Av. John F. Kennedy...",
              ),
            ),
            SizedBox(height: 15),

            // 🔥 NUEVO CAMPO: PROVINCIA
            TextField(
              controller: provinciaCtrl,
              decoration: InputDecoration(
                labelText: "Provincia",
                hintText: "Ej: Santo Domingo",
              ),
            ),
            SizedBox(height: 15),

            // LAT / LNG
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latCtrl,
                    decoration: InputDecoration(labelText: "Latitud"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: lngCtrl,
                    decoration: InputDecoration(labelText: "Longitud"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // HORARIOS
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: aperturaCtrl,
                    decoration: InputDecoration(labelText: "Hora apertura"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: cierreCtrl,
                    decoration: InputDecoration(labelText: "Hora cierre"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // MESAS
            TextField(
              controller: mesasCtrl,
              decoration: InputDecoration(labelText: "Número de mesas"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 15),

            // IMAGEN
            TextField(
              controller: imgCtrl,
              decoration: InputDecoration(labelText: "URL de Imagen"),
            ),

            SizedBox(height: 30),

            // BOTÓN GUARDAR
            ElevatedButton(
              onPressed: saving ? null : saveSucursal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A4D8C),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: saving
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      docId == null ? "Crear Sucursal" : "Guardar Cambios",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
