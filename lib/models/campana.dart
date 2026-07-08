class Campana {
  final String id;
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String descripcion;
  final bool estado;

//campaña representa una campaña de vacunación
//con un nombre y un rango de fechas en el que está activa.

//campaña actua como experto, pues puede determinar si
//está activa en una fecha dada,
//lo que es crucial para validar las citas agendadas en el gestor de citas.
  const Campana({
    required this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.descripcion,
    required this.estado,
  });

  bool estaActiva(DateTime fecha) {
    if (!estado) {
      return false;
    }
    final soloFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final inicio =
        DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);
    final fin = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);
    return !soloFecha.isBefore(inicio) && !soloFecha.isAfter(fin);
  }

  //permite crear una copia de la campaña con nombre, descripcion,
  //fechas o estado actualizados, sin perder el resto de los datos.
  //Se usa para que el Administrador pueda actualizar la vigencia y
  //el estado de una campaña ya existente.
  Campana copyWith({
    String? nombre,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? estado,
  }) {
    return Campana(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
    );
  }
}
