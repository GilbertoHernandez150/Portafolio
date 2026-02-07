import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  // Posición inicial: Santo Domingo
  final LatLng initialPosition = const LatLng(18.4861, -69.9312);

  // Marcadores (puedes añadir más luego)
  final Set<Marker> markers = {
    const Marker(
      markerId: MarkerId("naco"),
      position: LatLng(18.4746, -69.9397),
      infoWindow: InfoWindow(
        title: "Restaurante Ejemplo",
        snippet: "Sucursal Naco",
      ),
    ),
  };

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de Restaurantes"),
        centerTitle: true,
      ),
      body: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 13.5,
        ),
        mapType: MapType.normal,
        markers: markers,
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
