import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  //  Ngrok URL para exponer el backend local a internet
  final String baseUrl = 'https://likely-exit-rifling.ngrok-free.dev';

  Future<void> enviarConfirmacionCita({
    required String telefono,
    required String persona,
    required String puntoVacunacion,
    required DateTime fecha,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/notificar-cita');
      
      // Limpiamos el número eliminando caracteres no numéricos
      final String numeroLimpio = telefono.replaceAll(RegExp(r'[^0-9]'), '');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telefono': numeroLimpio,
          'persona': persona,
          'puntoVacunacion': puntoVacunacion,
          'fecha': fecha.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print("Petición de SMS enviada al servidor con éxito.");
      } else {
        print("Error en el servidor backend: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión con el servicio de notificaciones: $e");
    }
  }
}