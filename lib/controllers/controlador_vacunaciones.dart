import '../domain/gestor_vacunaciones.dart';
import '../models/campana.dart';
import '../models/punto_vacunacion.dart';
import '../models/registro_vacunacion.dart';

//patron controlador-creador, en la misma linea que ControladorCitas.

//Controlador para manejar el registro de vacunaciones realizadas,
//este objeto recibe las solicitudes desde la interfaz de usuario
//y delega la logica al gestor de vacunaciones.

class ControladorVacunaciones {
  final GestorVacunaciones _gestorVacunaciones;

  ControladorVacunaciones(this._gestorVacunaciones);

  RegistroVacunacion registrarVacunacion({
    required String persona,
    required Campana campana,
    required PuntoVacunacion puntoVacunacion,
    required DateTime fechaAplicacion,
    required String dosis,
    required String registradoPor,
  }) {
    return _gestorVacunaciones.registrarVacunacion(
      persona: persona,
      campana: campana,
      puntoVacunacion: puntoVacunacion,
      fechaAplicacion: fechaAplicacion,
      dosis: dosis,
      registradoPor: registradoPor,
    );
  }

  List<RegistroVacunacion> historialDe(String persona) {
    return _gestorVacunaciones.historialDePersona(persona);
  }

  List<RegistroVacunacion> get todosLosRegistros =>
      _gestorVacunaciones.registros;
}
