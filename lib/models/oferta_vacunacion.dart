import 'campana.dart';
import 'punto_vacunacion.dart';

//representa la oferta de vacunación disponible en un punto de vacunación para una campaña específica.

class OfertaVacunacion {
  final PuntoVacunacion puntoVacunacion;
  final Campana campana;

  const OfertaVacunacion({
    required this.puntoVacunacion,
    required this.campana,
  });

  String get etiqueta => '${puntoVacunacion.nombre} | ${campana.nombre}';
}
