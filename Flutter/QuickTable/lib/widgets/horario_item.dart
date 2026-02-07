import 'package:flutter/material.dart';

class HorarioItem extends StatelessWidget {
  final String hora;
  final bool disponible;
  final bool casiLleno;
  final VoidCallback? onTap;

  HorarioItem({
    required this.hora,
    required this.disponible,
    required this.casiLleno,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disponible ? onTap : null,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: disponible
              ? (casiLleno ? Colors.orange[100] : Colors.green[100])
              : Colors.red[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              hora,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: disponible ? Colors.black : Colors.white),
            ),
            Spacer(),
            if (!disponible)
              Text("Lleno", style: TextStyle(color: Colors.white)),
            if (casiLleno)
              Text("Pocas mesas", style: TextStyle(color: Colors.orange[900])),
            if (disponible && !casiLleno)
              Text("Disponible", style: TextStyle(color: Colors.green[800])),
          ],
        ),
      ),
    );
  }
}
