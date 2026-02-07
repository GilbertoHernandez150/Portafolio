import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMesasScreen extends StatefulWidget {
  const AdminMesasScreen({super.key});

  @override
  State<AdminMesasScreen> createState() => _AdminMesasScreenState();
}

class _AdminMesasScreenState extends State<AdminMesasScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String? selectedRestaurantId;
  String? selectedSucursalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurar Mesas"),
        backgroundColor: const Color(0xFF0A4D8C),
      ),

      floatingActionButton: (selectedSucursalId != null)
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0A4D8C),
              child: const Icon(Icons.add),
              onPressed: () => _openMesaForm(),
            )
          : null,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -------------------------------------------------------
            // SELECCIONAR RESTAURANTE
            // -------------------------------------------------------
            StreamBuilder<QuerySnapshot>(
              stream: db.collection("restaurants").snapshots(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedRestaurantId,
                  decoration: const InputDecoration(
                    labelText: "Seleccione un restaurante",
                  ),
                  items: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: d.id,
                      child: Text(data["nombre"]),
                    );
                  }).toList(),
                  onChanged: (id) {
                    setState(() {
                      selectedRestaurantId = id;
                      selectedSucursalId = null; // reset
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------------
            // SELECCIONAR SUCURSAL
            // -------------------------------------------------------
            if (selectedRestaurantId != null)
              StreamBuilder<QuerySnapshot>(
                stream: db
                    .collection("restaurants")
                    .doc(selectedRestaurantId)
                    .collection("sucursales")
                    .snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: selectedSucursalId,
                    decoration:
                        const InputDecoration(labelText: "Seleccione una sucursal"),
                    items: docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: d.id,
                        child: Text(data["nombre"]),
                      );
                    }).toList(),
                    onChanged: (id) {
                      setState(() {
                        selectedSucursalId = id;
                      });
                    },
                  );
                },
              ),

            const SizedBox(height: 20),

            // -------------------------------------------------------
            // LISTA DE MESAS
            // -------------------------------------------------------
            if (selectedRestaurantId == null || selectedSucursalId == null)
              const Text(
                "Seleccione restaurante y sucursal para ver las mesas.",
                style: TextStyle(fontSize: 16),
              )
            else
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection("restaurants")
                      .doc(selectedRestaurantId)
                      .collection("sucursales")
                      .doc(selectedSucursalId)
                      .collection("mesas")
                      .orderBy("numero", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No hay mesas registradas",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (_, index) {
                        final data =
                            docs[index].data() as Map<String, dynamic>;
                        final mesaId = docs[index].id;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                data["numero"].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A4D8C),
                                ),
                              ),
                            ),
                            title: Text("Mesa #${data["numero"]}"),
                            subtitle: Text(
                              "Capacidad: ${data["capacidad"]} personas\n"
                              "Estado: ${data["disponible"] ? "Disponible" : "Ocupada"}",
                            ),

                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == "edit") {
                                  _openMesaForm(
                                    mesaId: mesaId,
                                    data: data,
                                  );
                                } else if (value == "delete") {
                                  db
                                      .collection("restaurants")
                                      .doc(selectedRestaurantId)
                                      .collection("sucursales")
                                      .doc(selectedSucursalId)
                                      .collection("mesas")
                                      .doc(mesaId)
                                      .delete();
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: "edit",
                                  child: Text("Editar"),
                                ),
                                const PopupMenuItem(
                                  value: "delete",
                                  child: Text("Eliminar"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // 🌟 FORMULARIO (CREAR / EDITAR) MESA
  // ========================================================================
  void _openMesaForm({String? mesaId, Map<String, dynamic>? data}) {
    final numeroCtrl = TextEditingController(text: data?["numero"]?.toString());
    final capacidadCtrl =
        TextEditingController(text: data?["capacidad"]?.toString());

    bool disponible = data?["disponible"] ?? true;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(mesaId == null ? "Agregar Mesa" : "Editar Mesa"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numeroCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Número de mesa"),
              ),
              TextField(
                controller: capacidadCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Capacidad (personas)"),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Text("Disponible: "),
                  Switch(
                    value: disponible,
                    activeColor: Colors.green,
                    onChanged: (v) {
                      disponible = v;
                      setState(() {});
                    },
                  )
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Guardar"),
              onPressed: () {
                final numero = int.tryParse(numeroCtrl.text) ?? 0;
                final capacidad = int.tryParse(capacidadCtrl.text) ?? 0;

                final newData = {
                  "numero": numero,
                  "capacidad": capacidad,
                  "disponible": disponible,
                };

                final ref = db
                    .collection("restaurants")
                    .doc(selectedRestaurantId)
                    .collection("sucursales")
                    .doc(selectedSucursalId)
                    .collection("mesas");

                if (mesaId == null) {
                  ref.add(newData);
                } else {
                  ref.doc(mesaId).update(newData);
                }

                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
