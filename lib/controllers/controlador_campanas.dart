import '../domain/gestor_campanas.dart';
import '../models/campana.dart';

class ControladorCampanas {
  final GestorCampanas _gestorCampanas;

  ControladorCampanas(this._gestorCampanas);

  Campana definirCampana({
    required String nombre,
    required String descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    return _gestorCampanas.definirCampana(
      nombre: nombre,
      descripcion: descripcion,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
  }

  Campana actualizarVigencia({
    required String campanaId,
    required DateTime nuevaFechaInicio,
    required DateTime nuevaFechaFin,
  }) {
    return _gestorCampanas.actualizarVigencia(
      campanaId: campanaId,
      nuevaFechaInicio: nuevaFechaInicio,
      nuevaFechaFin: nuevaFechaFin,
    );
  }

  Campana actualizarEstado({
    required String campanaId,
    required bool nuevoEstado,
  }) {
    return _gestorCampanas.actualizarEstado(
      campanaId: campanaId,
      nuevoEstado: nuevoEstado,
    );
  }

  List<Campana> get campanas => _gestorCampanas.campanas;
}
