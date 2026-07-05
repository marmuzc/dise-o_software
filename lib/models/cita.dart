import 'campana.dart';
import 'punto_vacunacion.dart';

//estado de una cita, para poder distinguir citas agendadas,
//reprogramadas y canceladas en el seguimiento de citas.
enum EstadoCita { agendada, reprogramada, cancelada }

class Cita {
  final String id;
  final String persona;
  final PuntoVacunacion puntoVacunacion;
  final DateTime fecha;
  final Campana campana;
  final DateTime creadaEn;
  final EstadoCita estado;

  const Cita({
    required this.id,
    required this.persona,
    required this.puntoVacunacion,
    required this.fecha,
    required this.campana,
    required this.creadaEn,
    this.estado = EstadoCita.agendada,
  });

  //permite crear una copia de la cita con la fecha y/o estado
  //actualizados, sin perder el resto de los datos originales.
  Cita copyWith({DateTime? fecha, EstadoCita? estado}) {
    return Cita(
      id: id,
      persona: persona,
      puntoVacunacion: puntoVacunacion,
      fecha: fecha ?? this.fecha,
      campana: campana,
      creadaEn: creadaEn,
      estado: estado ?? this.estado,
    );
  }
}
