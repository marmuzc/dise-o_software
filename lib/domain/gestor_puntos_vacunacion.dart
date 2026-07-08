import '../models/campana.dart';
import '../models/punto_vacunacion.dart';
import '../models/oferta_vacunacion.dart';

class GestorPuntosVacunacion {
  static final List<PuntoVacunacion> _puntos = [
    PuntoVacunacion(id: 'pv1', nombre: 'Hospital de Higueras', capacidadDiaria: 2),
    PuntoVacunacion(id: 'pv2', nombre: 'Hospital regional de Concepción', capacidadDiaria: 3),
    PuntoVacunacion(id: 'pv3', nombre: 'Cesfam Víctor Manuel Fernández', capacidadDiaria: 1),
  ];
  static int _contadorIdPuntos = 3;

  static final List<OfertaVacunacion> _ofertas = [];
  static bool _inicializado = false;

  List<PuntoVacunacion> get puntos => List.unmodifiable(_puntos);
  List<OfertaVacunacion> get ofertas => List.unmodifiable(_ofertas);

  void inicializarOfertas(List<Campana> campanasIniciales) {
    if (!_inicializado && campanasIniciales.isNotEmpty) {
      _ofertas.add(OfertaVacunacion(puntoVacunacion: _puntos[0], campana: campanasIniciales[0]));
      if (campanasIniciales.length > 1) {
        _ofertas.add(OfertaVacunacion(puntoVacunacion: _puntos[1], campana: campanasIniciales[1]));
      }
      _ofertas.add(OfertaVacunacion(puntoVacunacion: _puntos[2], campana: campanasIniciales[0]));
      _inicializado = true;
    }
  }

  PuntoVacunacion agregarPunto({required String nombre, required int capacidadDiaria}) {
    if (nombre.trim().isEmpty) throw Exception('Ingresa el nombre del centro de vacunación.');
    if (capacidadDiaria <= 0) throw Exception('La capacidad diaria debe ser mayor a cero.');
    
    final nombreExiste = _puntos.any((p) => p.nombre.toLowerCase() == nombre.trim().toLowerCase());
    if (nombreExiste) throw Exception('Ya existe un centro con ese nombre.');

    _contadorIdPuntos++;
    final nuevo = PuntoVacunacion(
      id: 'pv_$_contadorIdPuntos',
      nombre: nombre.trim(),
      capacidadDiaria: capacidadDiaria,
    );
    _puntos.add(nuevo);
    return nuevo;
  }

  OfertaVacunacion asociarCampana({required PuntoVacunacion punto, required Campana campana}) {
    final existe = _ofertas.any((o) => o.puntoVacunacion.id == punto.id && o.campana.id == campana.id);
    if (existe) {
      throw Exception('La campaña "${campana.nombre}" ya está asociada al centro "${punto.nombre}".');
    }
    final nuevaOferta = OfertaVacunacion(puntoVacunacion: punto, campana: campana);
    _ofertas.add(nuevaOferta);
    return nuevaOferta;
  }
}