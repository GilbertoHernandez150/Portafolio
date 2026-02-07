import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String serviceId = "service_yjqbuql";
  static const String templateId = "template_ndd5qdm";
  static const String publicKey = "IUbCYmJh7p6cuEF5e";

  static Future<void> enviarCorreoReserva(Map<String, dynamic> data) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": data,
      }),
    );

    print("EMAILJS RESPONSE: ${response.statusCode} - ${response.body}");
  }
}
