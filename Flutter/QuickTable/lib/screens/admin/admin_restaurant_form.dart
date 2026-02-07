import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRestaurantForm extends StatefulWidget {
  @override
  _AdminRestaurantFormState createState() => _AdminRestaurantFormState();
}

class _AdminRestaurantFormState extends State<AdminRestaurantForm> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Controladores
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final imgCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final countryCtrl = TextEditingController();

  String? docId; // Para saber si estamos editando
  Future<DocumentSnapshot>? _futureRestaurant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    // Si venimos desde EDITAR
    if (args != null && args is Map && args["id"] != null) {
      docId = args["id"];

      // Cargar el documento real desde Firestore
      _futureRestaurant =
          db.collection("restaurants").doc(docId).get();
    }
  }

  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty ||
        descCtrl.text.trim().isEmpty ||
        cityCtrl.text.trim().isEmpty ||
        countryCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Todos los campos son obligatorios.")),
      );
      return;
    }

    final data = {
      "nombre": nameCtrl.text.trim(),
      "descripcion": descCtrl.text.trim(),
      "imagen": imgCtrl.text.trim(),
      "ciudad": cityCtrl.text.trim(),      // localidad general dentro del país
      "pais": countryCtrl.text.trim(),     // país
      "creadoEl": FieldValue.serverTimestamp(),
    };

    // Crear o actualizar
    if (docId == null) {
      await db.collection("restaurants").add(data);
    } else {
      await db.collection("restaurants").doc(docId).update(data);
    }

    Navigator.pop(context); // Cerrar formulario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(docId == null
            ? "Registrar Restaurante"
            : "Editar Restaurante"),
        backgroundColor: Color(0xFF0A4D8C),
      ),

      body: docId == null
          ? _buildForm() // Nuevo registro
          : FutureBuilder<DocumentSnapshot>(
              future: _futureRestaurant,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data =
                    snap.data!.data() as Map<String, dynamic>;

                // Llenar campos con lo guardado en Firestore
                nameCtrl.text = data["nombre"] ?? "";
                descCtrl.text = data["descripcion"] ?? "";
                imgCtrl.text = data["imagen"] ?? "";
                cityCtrl.text = data["ciudad"] ?? "";
                countryCtrl.text = data["pais"] ?? "";

                return _buildForm();
              },
            ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ListView(
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: "Nombre del Restaurante",
            ),
          ),
          SizedBox(height: 20),

          TextField(
            controller: descCtrl,
            decoration: InputDecoration(labelText: "Descripción"),
            maxLines: 3,
          ),
          SizedBox(height: 20),

          TextField(
            controller: imgCtrl,
            decoration: InputDecoration(
              labelText: "URL de Imagen",
              hintText: "https://...",
            ),
          ),
          SizedBox(height: 20),

          TextField(
            controller: cityCtrl,
            decoration: InputDecoration(
              labelText: "Ciudad o Localidad General",
              hintText: "Ej: Zona Metropolitana, Cibao, Este, etc.",
            ),
          ),
          SizedBox(height: 20),

          TextField(
            controller: countryCtrl,
            decoration: InputDecoration(
              labelText: "País",
              hintText: "Ej: República Dominicana",
            ),
          ),
          SizedBox(height: 40),

          ElevatedButton(
            onPressed: save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0A4D8C),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              docId == null ? "Crear Restaurante" : "Guardar Cambios",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
