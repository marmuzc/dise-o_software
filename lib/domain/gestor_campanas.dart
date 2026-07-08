import '../models/campana.dart';

class GestorCampanas {
  static final List<Campana> _campanas = [
    Campana(
      id: 'c1',
      nombre: 'Campaña Influenza 2026',
      fechaInicio: DateTime.now().subtract(const Duration(days: 5)),
      fechaFin: DateTime.now().add(const Duration(days: 30)),
      descripcion: 'Campaña de vacunación contra la influenza 2026',
      estado: true,
    ),
    Campana(
      id: 'c2',
      nombre: 'Campaña COVID-19 Refuerzo',
      fechaInicio: DateTime.now().subtract(const Duration(days: 15)),
      fechaFin: DateTime.now().add(const Duration(days: 15)),
      descripcion: 'Campaña de vacunación de refuerzo contra COVID-19',
      estado: true,
    ),
  ];

  static int _contadorId = _campanas.length;

  List<Campana> get campanas => List.unmodifiable(_campanas);

  //el Administrador define una nueva campaña de vacunación con
  //nombre, descripcion y el rango de fechas en que estara vigente,
  //para organizar los periodos de inmunizacion.
  Campana definirCampana({
    required String nombre,
    required String descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) {
    final nombreValido = nombre.trim();
    if (nombreValido.isEmpty) {
      throw Exception('Ingresa el nombre de la campaña.');
    }

    final descripcionValida = descripcion.trim();
    if (descripcionValida.isEmpty) {
      throw Exception('Ingresa una descripcion para la campaña.');
    }

    if (fechaFin.isBefore(fechaInicio)) {
      throw Exception(
          'La fecha de termino no puede ser anterior a la de inicio.');
    }

    _contadorId++;

    final campana = Campana(
      id: 'campana_$_contadorId',
      nombre: nombreValido,
      descripcion: descripcionValida,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      estado: true,
    );

    _campanas.add(campana);
    return campana;
  }

  int _indiceDeCampana(String campanaId) {
    final indice = _campanas.indexWhere((c) => c.id == campanaId);
    if (indice == -1) {
      throw Exception('No se encontro la campaña indicada.');
    }
    return indice;
  }

  //actualiza el rango de fechas (vigencia) de una campaña existente,
  //para que el Administrador mantenga el sistema sincronizado con la
  //realidad sanitaria.
  Campana actualizarVigencia({
    required String campanaId,
    required DateTime nuevaFechaInicio,
    required DateTime nuevaFechaFin,
  }) {
    if (nuevaFechaFin.isBefore(nuevaFechaInicio)) {
      throw Exception(
          'La fecha de termino no puede ser anterior a la de inicio.');
    }

    final indice = _indiceDeCampana(campanaId);
    final actualizada = _campanas[indice].copyWith(
      fechaInicio: nuevaFechaInicio,
      fechaFin: nuevaFechaFin,
    );

    _campanas[indice] = actualizada;
    return actualizada;
  }

  //actualiza el estado (activa/inactiva) de una campaña existente.
  //este estado es independiente de la vigencia por fecha: una
  //campaña puede estar dentro de su rango de fechas pero desactivada
  //manualmente por el Administrador.
  Campana actualizarEstado({
    required String campanaId,
    required bool nuevoEstado,
  }) {
    final indice = _indiceDeCampana(campanaId);
    final actualizada = _campanas[indice].copyWith(estado: nuevoEstado);
    _campanas[indice] = actualizada;
    return actualizada;
  }
}
