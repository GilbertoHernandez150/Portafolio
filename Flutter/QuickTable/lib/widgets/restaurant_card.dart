import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final String name;
  final String city;
  final String imageUrl;
  final VoidCallback onTap;

  RestaurantCard({
    required this.name,
    required this.city,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(city, style: TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
