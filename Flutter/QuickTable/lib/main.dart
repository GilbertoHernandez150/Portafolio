import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// IMPORTAR TODAS LAS SCREENS
import 'screens/home_screen.dart';
import 'screens/restaurant_list_screen.dart';
import 'screens/restaurant_detail_screen.dart';
import 'screens/reservation_form_screen.dart';
import 'screens/reservation_success_screen.dart';
import 'screens/my_reservations_screen.dart';
import 'screens/map_screen.dart';
import 'screens/edit_reservation_screen.dart';

import 'screens/admin_panel_screen.dart';
import 'screens/admin/admin_restaurants_screen.dart';
import 'screens/admin/admin_restaurant_form.dart';
import 'screens/admin/sucursales/admin_sucursal_form.dart';
import 'screens/admin/sucursales/admin_sucursales_screen.dart';
import 'screens/admin/admin_horarios_screen.dart';
import 'screens/admin/admin_mesas_screen.dart';

import 'routes/custom_page_route.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ReservasApp());
}

class ReservasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Reservas RD",

      // 🟢 LOCALIZACIÓN
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      initialRoute: "/",

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/":
            return SlideFadeRoute(page: HomeScreen(), settings: settings);

          case "/restaurants":
            return SlideFadeRoute(
              page: RestaurantListScreen(),
              settings: settings,
            );

          case "/restaurantDetails":
            return SlideFadeRoute(
              page: RestaurantDetailScreen(),
              settings: settings,
            );

          case "/reservationForm":
            return SlideFadeRoute(
              page: ReservationFormScreen(),
              settings: settings,
            );

          case "/reservationSuccess":
            return SlideFadeRoute(
              page: ReservationSuccessScreen(),
              settings: settings,
            );

          case "/myReservations":
            return SlideFadeRoute(
              page: MyReservationsScreen(),
              settings: settings,
            );

          case "/editReservation":
            return SlideFadeRoute(
              page: EditReservationScreen(),
              settings: settings,
            );

          case "/map":
            return SlideFadeRoute(page: MapScreen(), settings: settings);

          // 🔵 PANEL ADMIN
          case "/admin":
            return SlideFadeRoute(page: AdminPanelScreen(), settings: settings);

          case "/adminRestaurantes":
            return SlideFadeRoute(
              page: AdminRestaurantsScreen(),
              settings: settings,
            );

          case "/adminRestauranteForm":
            return SlideFadeRoute(
              page: AdminRestaurantForm(),
              settings: settings,
            );

          case "/adminSucursales":
            return SlideFadeRoute(
              page: AdminSucursalesScreen(),
              settings: settings,
            );

          case "/adminSucursalForm":
            return SlideFadeRoute(
              page: AdminSucursalForm(),
              settings: settings,
            );

          case "/adminHorarios":
            return SlideFadeRoute(
              page: AdminHorariosScreen(),
              settings: settings,
            );

          case "/adminMesas":
            return SlideFadeRoute(
              page: const AdminMesasScreen(),
              settings: settings,
            );

          default:
            return SlideFadeRoute(page: HomeScreen(), settings: settings);
        }
      },
    );
  }
}
