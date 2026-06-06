import '../domain/gestor_citas.dart';
import '../models/campana.dart';
import '../models/cita.dart';
import '../models/punto_vacunacion.dart';

//patron controlador-creador

//Controlador para manejar la agenda de citas de vacunacion,
//este objeto recibe las solicitudes de agendar citas desde la interfaz de usuario
// y delega la logica al gestor de citas,
//ademas de proporcionar una forma de acceder a las citas agendadas para mostrarlas en la interfaz.

class ControladorCitas {
  final GestorCitas _gestorCitas;

  ControladorCitas(this._gestorCitas);

  Cita agendarCita({
    required String persona,
    required PuntoVacunacion puntoVacunacion,
    required DateTime fecha,
    required Campana campana,
  }) {
    return _gestorCitas.crearCita(
      persona: persona,
      puntoVacunacion: puntoVacunacion,
      fecha: fecha,
      campana: campana,
    );
  }

  List<Cita> get citasAgendadas => _gestorCitas.citas;
}
