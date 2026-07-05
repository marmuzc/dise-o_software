class PuntoVacunacion {
  final String id;
  final String nombre;
  final int capacidadDiaria;
  final Map<String, int> citasPorDia;

//patron experto, punto de vacunacion se encarga de determinar si existe
//disponibilidad para una fecha dada, y de registrar las citas agendadas

  PuntoVacunacion({
    required this.id,
    required this.nombre,
    required this.capacidadDiaria,
    Map<String, int>? citasPorDia,
  }) : citasPorDia = citasPorDia ?? {};

  String _claveFecha(DateTime fecha) {
    return '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }

  bool hayDisponibilidad(DateTime fecha) {
    final clave = _claveFecha(fecha);
    final citasActuales = citasPorDia[clave] ?? 0;
    return citasActuales < capacidadDiaria;
  }

  void registrarCita(DateTime fecha) {
    final clave = _claveFecha(fecha);
    citasPorDia[clave] = (citasPorDia[clave] ?? 0) + 1;
  }

  //libera un cupo previamente registrado para una fecha, usado
  //al cancelar una cita o al reprogramarla a otra fecha, para que
  //el cupo antiguo quede disponible nuevamente.
  void liberarCita(DateTime fecha) {
    final clave = _claveFecha(fecha);
    final actual = citasPorDia[clave] ?? 0;
    if (actual > 0) {
      citasPorDia[clave] = actual - 1;
    }
  }
}
