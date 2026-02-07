import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panel Administrativo")),

      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _item(context, "Gestionar Restaurantes", "/adminRestaurants", Icons.restaurant),
        ],
      ),
    );
  }

  Widget _item(BuildContext ctx, String title, String route, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(ctx, route),
      ),
    );
  }
}
