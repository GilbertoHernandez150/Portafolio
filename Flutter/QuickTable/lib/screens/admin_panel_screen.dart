import 'package:flutter/material.dart';
import '../helpers/responsive.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  bool animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() => animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    double titleSize = Responsive.isMobile(context) ? 26 : 34;
    double buttonFont = Responsive.isMobile(context) ? 18 : 24;
    double spacing = Responsive.isMobile(context) ? 18 : 26;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Administrativo"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A4D8C),
      ),

      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 20 : 40),

        child: AnimatedOpacity(
          opacity: animate ? 1 : 0,
          duration: Duration(milliseconds: 600),
          child: AnimatedSlide(
            offset: animate ? Offset(0, 0) : Offset(0, 0.1),
            duration: Duration(milliseconds: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 TÍTULO PRINCIPAL
                Text(
                  "Administrar QuickTable",
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Color(0xFF0A4D8C),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: spacing + 10),

                // 🔵 BOTONES DEL PANEL
                Expanded(
                  child: ListView(
                    children: [
                      _adminButton(
                        icon: Icons.store,
                        text: "Gestionar Restaurantes",
                        color: Colors.deepPurple,
                        fontSize: buttonFont,
                        onTap: () {
                          Navigator.pushNamed(context, "/adminRestaurantes");
                        },
                      ),

                      SizedBox(height: spacing),

                      _adminButton(
                        icon: Icons.schedule,
                        text: "Horarios del Restaurante",
                        color: Colors.blue,
                        fontSize: buttonFont,
                        onTap: () {
                          Navigator.pushNamed(context, "/adminHorarios");
                        },
                      ),

                      SizedBox(height: spacing),

                      _adminButton(
                        icon: Icons.table_bar,
                        text: "Mesas y Capacidad",
                        color: Colors.teal,
                        fontSize: buttonFont,
                        onTap: () {
                          Navigator.pushNamed(context, "/adminMesas");
                        },
                      ),

                      SizedBox(height: spacing),

                      _adminButton(
                        icon: Icons.analytics,
                        text: "Reportes de Reservas",
                        color: Colors.orange,
                        fontSize: buttonFont,
                        onTap: () {
                          Navigator.pushNamed(context, "/adminReportes");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // WIDGET REUTILIZABLE PARA LOS BOTONES DEL PANEL
  // -----------------------------------------------------
  Widget _adminButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 32, color: color),
          ],
        ),
      ),
    );
  }
}
