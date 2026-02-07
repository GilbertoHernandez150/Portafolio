import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/restaurant_card.dart';
import '../helpers/responsive.dart';

class RestaurantListScreen extends StatelessWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double padding = Responsive.isMobile(context) ? 10 : 40;

    return Scaffold(
      appBar: AppBar(title: const Text("Restaurantes")),

      body: Padding(
        padding: EdgeInsets.all(padding),

        // 🔥 Escucha en tiempo real los restaurantes
        child: StreamBuilder<QuerySnapshot>(
          stream: db.collection("restaurants").snapshots(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text("No hay restaurantes aún."));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final data = docs[i].data() as Map<String, dynamic>;

                return RestaurantCard(
                  name: data["nombre"] ?? "Sin nombre",
                  city: data["ciudad"] ?? "Sin ciudad",
                  imageUrl: data["imagen"] ?? "",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/restaurantDetails",
                      arguments: {
                        "id": docs[i].id,
                        ...data,
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
