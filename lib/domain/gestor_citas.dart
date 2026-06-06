import '../models/campana.dart';
import '../models/cita.dart';
import '../models/punto_vacunacion.dart';

//patron controlador-creador

//gestor de citas para manejar la logica de agendar citas de vacunacion,
//este objeto se encarga de validar la disponibilidad del punto de vacunacion y la campana
//ademas de registrar las citas agendadas en una lista interna, que
//puede ser accedida por el controlador de citas para mostrarlas en la interfaz.

class GestorCitas {
  final List<Cita> _citas = [];

  List<Cita> get citas => List.unmodifiable(_citas);

  Cita crearCita({
    required String persona,
    required PuntoVacunacion puntoVacunacion,
    required DateTime fecha,
    required Campana campana,
  }) {
    if (!puntoVacunacion.hayDisponibilidad(fecha)) {
      throw Exception(
          'No hay disponibilidad en el punto de vacunacion seleccionado.');
    }

    if (!campana.estaActiva(fecha)) {
      throw Exception(
          'La campana no se encuentra activa para la fecha seleccionada.');
    }

    final cita = Cita(
      persona: persona,
      puntoVacunacion: puntoVacunacion,
      fecha: fecha,
      campana: campana,
      creadaEn: DateTime.now(),
    );

    puntoVacunacion.registrarCita(fecha);
    _citas.add(cita);
    return cita;
  }
}
