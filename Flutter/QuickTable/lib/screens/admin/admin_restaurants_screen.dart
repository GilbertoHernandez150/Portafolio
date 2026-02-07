import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRestaurantsScreen extends StatefulWidget {
  @override
  _AdminRestaurantsScreenState createState() => _AdminRestaurantsScreenState();
}

class _AdminRestaurantsScreenState extends State<AdminRestaurantsScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar Restaurantes"),
        backgroundColor: Color(0xFF0A4D8C),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0A4D8C),
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, "/adminRestauranteForm"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("restaurants").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("No hay restaurantes registrados"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: data["imagen"] != null
                            ? NetworkImage(data["imagen"])
                            : null,
                        child: data["imagen"] == null
                            ? Icon(Icons.restaurant)
                            : null,
                      ),
                      title: Text(data["nombre"] ?? "Sin nombre"),
                      subtitle: Text(data["descripcion"] ?? ""),

                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == "edit") {
                            Navigator.pushNamed(
                              context,
                              "/adminRestauranteForm",
                              arguments: {"id": id, ...data},
                            );
                          } else if (value == "delete") {
                            db.collection("restaurants").doc(id).delete();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "edit",
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 10),
                                Text("Editar"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "delete",
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 10),
                                Text("Eliminar"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // VER SUCURSALES
                    Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/adminSucursales",
                              arguments: {
                                "restaurantId": id, // 🔥 el nombre correcto de la ruta
                                "nombre": data["nombre"], // 🔥 está correcto
                              },
                            );
                          },
                          child: Text("Ver sucursales"),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
