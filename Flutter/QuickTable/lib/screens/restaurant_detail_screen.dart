import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/responsive.dart';
import '../widgets/custom_button.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    // Datos por defecto
    Map<String, dynamic> data = {
      "id": null,
      "nombre": "Sin nombre",
      "ciudad": "República Dominicana",
      "imagen": null,
      "descripcion": "Sin descripción disponible.",
    };

    // Sobrescribir si llegan argumentos reales
    if (args is Map<String, dynamic>) {
      data["id"] = args["id"];
      data["nombre"] = args["nombre"] ?? "Sin nombre";
      data["ciudad"] = args["ciudad"] ?? "República Dominicana";
      data["imagen"] = args["imagen"];
      data["descripcion"] = args["descripcion"] ??
          "Restaurante reconocido en República Dominicana.";
    }

    double padding = Responsive.isMobile(context) ? 20 : 40;
    double titleSize = Responsive.isMobile(context) ? 26 : 34;
    double descSize = Responsive.isMobile(context) ? 16 : 20;

    final FirebaseFirestore db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: Text(data["nombre"])),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // IMAGEN
            data["imagen"] != null
                ? Image.network(
                    data["imagen"],
                    height: Responsive.isMobile(context) ? 220 : 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),

            // INFORMACIÓN PRINCIPAL
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["nombre"],
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    data["ciudad"],
                    style:
                        TextStyle(fontSize: descSize, color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Descripción",
                    style: TextStyle(
                      fontSize: descSize + 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    data["descripcion"],
                    style: TextStyle(fontSize: descSize),
                  ),

                  const SizedBox(height: 30),

                  CustomButton(
                    text: "Reservar en este restaurante",
                    onPressed: () {
                      final recibido =
                          (args is Map<String, dynamic>) ? args : {};

                      Navigator.pushNamed(
                        context,
                        "/reservationForm",
                        arguments: {
                          "restaurantId": recibido["id"],
                          "restaurantName": recibido["nombre"],
                          "sucursalId": null,
                          "sucursalName": null,
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // -------------------------------
                  // LISTA DE SUCURSALES (EN VIVO)
                  // -------------------------------
                  Text(
                    "Sucursales",
                    style: TextStyle(
                      fontSize: titleSize * 0.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection("restaurants")
                        .doc(data["id"])
                        .collection("sucursales")
                        .snapshots(),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Text(
                          "Este restaurante aún no tiene sucursales.",
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      return Column(
                        children: docs.map((d) {
                          final suc = d.data() as Map<String, dynamic>;

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suc["nombre"] ?? "Sucursal",
                                    style: TextStyle(
                                      fontSize: descSize + 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  if (suc["provincia"] != null)
                                    Text("Provincia: ${suc["provincia"]}"),

                                  if (suc["municipio"] != null)
                                    Text("Municipio: ${suc["municipio"]}"),

                                  if (suc["sector"] != null)
                                    Text("Sector: ${suc["sector"]}"),

                                  const SizedBox(height: 15),

                                  CustomButton(
                                    text: "Reservar en esta sucursal",
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/reservationForm",
                                        arguments: {
                                          "restaurantId": data["id"],
                                          "restaurantName": data["nombre"],
                                          "sucursalId": d.id,
                                          "sucursalName": suc["nombre"],
                                        },
                                      );
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
