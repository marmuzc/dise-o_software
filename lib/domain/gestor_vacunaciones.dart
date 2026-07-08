import '../models/campana.dart';
import '../models/punto_vacunacion.dart';
import '../models/registro_vacunacion.dart';

//patron controlador-creador, en la misma linea que GestorCitas.

//gestor de vacunaciones, se encarga de registrar las vacunaciones
//realizadas (asociadas a persona, campana y punto de vacunacion)
//y de exponer el historial de vacunacion de una persona, que sirve
//para validar las dosis que ya recibio.

class GestorVacunaciones {
  static final List<RegistroVacunacion> _registros = [];
  static int _contadorId = 0;

  List<RegistroVacunacion> get registros => List.unmodifiable(_registros);

  RegistroVacunacion registrarVacunacion({
    required String persona,
    required Campana campana,
    required PuntoVacunacion puntoVacunacion,
    required DateTime fechaAplicacion,
    required String dosis,
    required String registradoPor,
  }) {
    final personaValida = persona.trim();
    if (personaValida.isEmpty) {
      throw Exception('Debes indicar la persona vacunada.');
    }

    final dosisValida = dosis.trim();
    if (dosisValida.isEmpty) {
      throw Exception('Debes indicar la dosis aplicada.');
    }

    _contadorId++;

    final registro = RegistroVacunacion(
      id: 'reg_$_contadorId',
      persona: personaValida,
      campana: campana,
      puntoVacunacion: puntoVacunacion,
      fechaAplicacion: fechaAplicacion,
      dosis: dosisValida,
      registradoPor: registradoPor,
    );

    _registros.add(registro);
    return registro;
  }

  //historial de vacunacion de una persona, ordenado del mas
  //reciente al mas antiguo, para validar las dosis recibidas.
  List<RegistroVacunacion> historialDePersona(String persona) {
    final valorBuscado = persona.trim().toLowerCase();
    final propios = _registros
        .where((r) => r.persona.trim().toLowerCase() == valorBuscado)
        .toList();
    propios.sort((a, b) => b.fechaAplicacion.compareTo(a.fechaAplicacion));
    return propios;
  }
}
