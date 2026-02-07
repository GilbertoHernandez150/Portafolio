import 'package:flutter/material.dart';
import '../helpers/responsive.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  bool animate = false;

  @override
  void initState() {
    super.initState();

    // Iniciar animación 
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        animate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double padding = Responsive.isMobile(context) ? 20 : 40;
    double titleSize = Responsive.isMobile(context) ? 28 : 36;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // FONDO GRADIENTE
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A4D8C),
              Color(0xFF0A7DD8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              // --------------------------
              // TITULO ANIMADO
              // --------------------------
              AnimatedOpacity(
                duration: Duration(milliseconds: 900),
                opacity: animate ? 1 : 0,
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  duration: Duration(milliseconds: 900),
                  offset: animate ? Offset(0, 0) : Offset(0, -0.3),
                  curve: Curves.easeOut,
                  child: Column(
                    children: [
                      Text(
                        "QuickTable",
                        style: TextStyle(
                          fontSize: titleSize + 6,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 12,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(2, 3),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Bienvenido",
                        style: TextStyle(
                          fontSize: titleSize,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 60),

              // --------------------------
              // BOTONES ANIMADOS
              // --------------------------
              AnimatedOpacity(
                duration: Duration(milliseconds: 1000),
                opacity: animate ? 1 : 0,
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  duration: Duration(milliseconds: 1000),
                  offset: animate ? Offset(0, 0) : Offset(0, 0.4),
                  curve: Curves.easeOut,
                  child: Column(
                    children: [

                      // BOTÓN 1 - Ver Restaurantes
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF0A4D8C),
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.isMobile(context) ? 15 : 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: Icon(Icons.restaurant_menu, size: 26),
                          label: Text(
                            "Ver Restaurantes",
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 18 : 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, "/restaurants"),
                        ),
                      ),

                      SizedBox(height: 20),

                      // BOTÓN 2 - Mis Reservas
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF0A4D8C),
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.isMobile(context) ? 15 : 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: Icon(Icons.list_alt, size: 26),
                          label: Text(
                            "Mis Reservas",
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 18 : 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, "/myReservations"),
                        ),
                      ),

                      SizedBox(height: 20),

                      // 🔧 BOTÓN 3 - Panel Administrativo
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.isMobile(context) ? 15 : 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: Icon(Icons.admin_panel_settings, size: 26),
                          label: Text(
                            "Panel Administrativo",
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 18 : 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, "/admin"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
