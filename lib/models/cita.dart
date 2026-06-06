import 'campana.dart';
import 'punto_vacunacion.dart';

class Cita {
  final String persona;
  final PuntoVacunacion puntoVacunacion;
  final DateTime fecha;
  final Campana campana;
  final DateTime creadaEn;

  const Cita({
    required this.persona,
    required this.puntoVacunacion,
    required this.fecha,
    required this.campana,
    required this.creadaEn,
  });
}
