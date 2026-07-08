import '../domain/gestor_puntos_vacunacion.dart';
import '../models/campana.dart';
import '../models/punto_vacunacion.dart';
import '../models/oferta_vacunacion.dart';

class ControladorPuntosVacunacion {
  final GestorPuntosVacunacion _gestor;

  ControladorPuntosVacunacion(this._gestor);

  void inicializarOfertas(List<Campana> campanas) {
    _gestor.inicializarOfertas(campanas);
  }

  List<PuntoVacunacion> get puntos => _gestor.puntos;
  List<OfertaVacunacion> get ofertas => _gestor.ofertas;

  PuntoVacunacion agregarPunto({required String nombre, required int capacidadDiaria}) {
    return _gestor.agregarPunto(nombre: nombre, capacidadDiaria: capacidadDiaria);
  }

  OfertaVacunacion asociarCampana({required PuntoVacunacion punto, required Campana campana}) {
    return _gestor.asociarCampana(punto: punto, campana: campana);
  }

  List<PuntoVacunacion> puntosPorCampana(Campana campana) {
    return ofertas
        .where((o) => o.campana.id == campana.id)
        .map((o) => o.puntoVacunacion)
        .toList();
  }
}