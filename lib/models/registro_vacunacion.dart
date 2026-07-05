import 'campana.dart';
import 'punto_vacunacion.dart';

//representa una vacunacion ya realizada y registrada en el sistema,
//asociada a una persona, una campana y un punto de vacunacion.
//esto es lo que despues alimenta el historial de vacunacion.

class RegistroVacunacion {
  final String id;
  final String persona;
  final Campana campana;
  final PuntoVacunacion puntoVacunacion;
  final DateTime fechaAplicacion;
  final String dosis;
  final String registradoPor;

  const RegistroVacunacion({
    required this.id,
    required this.persona,
    required this.campana,
    required this.puntoVacunacion,
    required this.fechaAplicacion,
    required this.dosis,
    required this.registradoPor,
  });
}
