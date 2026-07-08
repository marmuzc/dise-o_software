import '../models/campana.dart';
import '../models/cita.dart';
import '../models/punto_vacunacion.dart';

//patron controlador-creador

//gestor de citas para manejar la logica de agendar citas de vacunacion,
//este objeto se encarga de validar la disponibilidad del punto de vacunacion y la campana
//ademas de registrar las citas agendadas en una lista interna, que
//puede ser accedida por el controlador de citas para mostrarlas en la interfaz.

class GestorCitas {
  static final List<Cita> _citas = [];
  static int _contadorId = 0;

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

    _contadorId++;

    final cita = Cita(
      id: 'cita_$_contadorId',
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

  //busca la cita por su id dentro de la lista interna, lanzando
  //una excepcion si no existe, para evitar operar sobre una cita
  //que no pertenece al gestor.
  int _indiceDeCita(String citaId) {
    final indice = _citas.indexWhere((c) => c.id == citaId);
    if (indice == -1) {
      throw Exception('No se encontro la cita indicada.');
    }
    return indice;
  }

  //reprograma una cita existente a una nueva fecha, liberando el cupo
  //antiguo en el punto de vacunacion y registrando el cupo nuevo,
  //siempre que exista disponibilidad y la campana siga activa.
  Cita reprogramarCita({
    required String citaId,
    required DateTime nuevaFecha,
  }) {
    final indice = _indiceDeCita(citaId);
    final citaActual = _citas[indice];

    if (citaActual.estado == EstadoCita.cancelada) {
      throw Exception('No se puede reprogramar una cita cancelada.');
    }

    if (!citaActual.puntoVacunacion.hayDisponibilidad(nuevaFecha)) {
      throw Exception(
          'No hay disponibilidad en el punto de vacunacion para la nueva fecha.');
    }

    if (!citaActual.campana.estaActiva(nuevaFecha)) {
      throw Exception('La campana no se encuentra activa para la nueva fecha.');
    }

    citaActual.puntoVacunacion.liberarCita(citaActual.fecha);
    citaActual.puntoVacunacion.registrarCita(nuevaFecha);

    final citaActualizada = citaActual.copyWith(
      fecha: nuevaFecha,
      estado: EstadoCita.reprogramada,
    );

    _citas[indice] = citaActualizada;
    return citaActualizada;
  }

  //cancela una cita existente, liberando el cupo que tenia reservado
  //en el punto de vacunacion para que quede disponible nuevamente.
  Cita cancelarCita(String citaId) {
    final indice = _indiceDeCita(citaId);
    final citaActual = _citas[indice];

    if (citaActual.estado == EstadoCita.cancelada) {
      throw Exception('La cita ya se encuentra cancelada.');
    }

    citaActual.puntoVacunacion.liberarCita(citaActual.fecha);

    final citaCancelada = citaActual.copyWith(estado: EstadoCita.cancelada);
    _citas[indice] = citaCancelada;
    return citaCancelada;
  }

  //filtra las citas asociadas a una persona en particular, usado
  //para que cada usuario/funcionario vea solo sus propias citas
  //o las de la persona consultada.
  List<Cita> citasDePersona(String persona) {
    final valorBuscado = persona.trim().toLowerCase();
    return _citas
        .where((c) => c.persona.trim().toLowerCase() == valorBuscado)
        .toList();
  }
}
