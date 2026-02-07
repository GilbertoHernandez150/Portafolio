List<String> generarHorarios(
    String apertura, String cierre, int intervalosMin) {
  // Convertir horas en DateTime
  DateTime abrir = _parseHora(apertura);
  DateTime cerrar = _parseHora(cierre);

  List<String> horarios = [];

  while (abrir.isBefore(cerrar)) {
    horarios.add(_formatoHora(abrir));
    abrir = abrir.add(Duration(minutes: intervalosMin));
  }

  return horarios;
}

DateTime _parseHora(String h) {
  return DateTime.parse("2025-01-01 " + _to24(h) + ":00");
}

String _to24(String hora12) {
  final parts = hora12.split(" ");
  final hm = parts[0].split(":");
  int hour = int.parse(hm[0]);
  int minute = int.parse(hm[1]);

  if (parts[1] == "PM" && hour != 12) hour += 12;
  if (parts[1] == "AM" && hour == 12) hour = 0;

  return "$hour:$minute";
}

String _formatoHora(DateTime dt) {
  return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
}
