import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSucursalesScreen extends StatelessWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  AdminSucursalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ============================================
    //  RECIBIR ARGUMENTOS DE LA RUTA
    // ============================================
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String restaurantId = args["restaurantId"] ?? "";
    final String restaurantName = args["nombre"] ?? args["restaurantName"] ?? "Restaurante";

    return Scaffold(
      appBar: AppBar(
        title: Text("Sucursales de $restaurantName"),
        backgroundColor: const Color(0xFF0A4D8C),
        centerTitle: true,
      ),

      // ============================================
      //  BOTÓN AGREGAR SUCURSAL
      // ============================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A4D8C),
        child: const Icon(Icons.add_location_alt),
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/adminSucursalForm",
            arguments: {
              "restaurantId": restaurantId,
              "restaurantName": restaurantName,
            },
          );
        },
      ),

      // ============================================
      //  STREAM BUILDER - LISTA DE SUCURSALES
      // ============================================
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection("restaurants")
            .doc(restaurantId)
            .collection("sucursales")
            .orderBy("provincia", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No hay sucursales registradas",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final sucursalId = docs[index].id;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ============================================
                      //  INFORMACIÓN DE SUCURSAL
                      // ============================================
                      ListTile(
                        contentPadding: EdgeInsets.zero,

                        leading: const Icon(
                          Icons.location_on,
                          size: 32,
                          color: Color(0xFF0A4D8C),
                        ),

                        title: Text(
                          data["nombre"] ?? "Sucursal sin nombre",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        subtitle: Text(
                          data["direccion"] ??
                              "${data["sector"] ?? ""}, ${data["municipio"] ?? ""}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),

                        trailing: PopupMenuButton(
                          onSelected: (value) async {
                            if (value == "edit") {
                              Navigator.pushNamed(
                                context,
                                "/adminSucursalForm",
                                arguments: {
                                  "restaurantId": restaurantId,
                                  "restaurantName": restaurantName,
                                  "id": sucursalId,
                                  ...data,
                                },
                              );
                            } else if (value == "delete") {
                              await db
                                  .collection("restaurants")
                                  .doc(restaurantId)
                                  .collection("sucursales")
                                  .doc(sucursalId)
                                  .delete();
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: "edit",
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 10),
                                  Text("Editar"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: "delete",
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.red, size: 18),
                                  SizedBox(width: 10),
                                  Text("Eliminar"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ============================================
                      //  BOTONES: MESAS & HORARIOS
                      // ============================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // === MESAS ===
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/adminMesas",
                                arguments: {
                                  "restaurantId": restaurantId,
                                  "sucursalId": sucursalId,
                                  "sucursalName": data["nombre"] ?? "",
                                },
                              );
                            },
                            icon: const Icon(Icons.table_restaurant),
                            label: const Text("Mesas"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[50],
                              foregroundColor: const Color(0xFF0A4D8C),
                            ),
                          ),

                          // === HORARIOS ===
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/adminHorarios",
                                arguments: {
                                  "restaurantId": restaurantId,
                                  "sucursalId": sucursalId,
                                  "sucursalName": data["nombre"] ?? "",
                                },
                              );
                            },
                            icon: const Icon(Icons.access_time),
                            label: const Text("Horarios"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[50],
                              foregroundColor: const Color(0xFF0A4D8C),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
