import 'package:flutter/material.dart';
import '../helpers/responsive.dart';
import '../widgets/custom_button.dart';

class ReservationSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double iconSize = Responsive.isMobile(context) ? 100 : 160;
    double textSize = Responsive.isMobile(context) ? 24 : 32;

    return Scaffold(
      appBar: AppBar(title: Text("Reserva Exitosa")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.isMobile(context) ? 20 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: iconSize),
              SizedBox(height: 20),

              Text(
                "¡Reserva realizada con éxito!",
                style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              CustomButton(
                text: "Volver al inicio",
                onPressed: () => Navigator.pushNamed(context, "/"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
