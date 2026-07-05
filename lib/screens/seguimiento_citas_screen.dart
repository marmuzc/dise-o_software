import 'package:flutter/material.dart';

import '../controllers/controlador_citas.dart';
import '../models/cita.dart';
import '../models/usuario.dart';

//pantalla de seguimiento de citas: permite consultar las citas de
//vacunacion propias, reprogramarlas para ajustar el turno ante
//imprevistos, y cancelarlas para liberar el cupo en el sistema.

class SeguimientoCitasScreen extends StatefulWidget {
  final Usuario usuarioActual;
  final ControladorCitas controladorCitas;

  const SeguimientoCitasScreen({
    super.key,
    required this.usuarioActual,
    required this.controladorCitas,
  });

  @override
  State<SeguimientoCitasScreen> createState() => _SeguimientoCitasScreenState();
}

class _SeguimientoCitasScreenState extends State<SeguimientoCitasScreen> {
  String? _mensaje;
  bool _esError = false;

  String _formatoFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _etiquetaEstado(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.agendada:
        return 'Agendada';
      case EstadoCita.reprogramada:
        return 'Reprogramada';
      case EstadoCita.cancelada:
        return 'Cancelada';
    }
  }

  Future<void> _reprogramar(Cita cita) async {
    final nuevaFechaBase = await showDatePicker(
      context: context,
      initialDate: cita.fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (nuevaFechaBase == null || !mounted) return;

    final nuevaHora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(cita.fecha),
    );
    if (nuevaHora == null || !mounted) return;

    final nuevaFecha = DateTime(
      nuevaFechaBase.year,
      nuevaFechaBase.month,
      nuevaFechaBase.day,
      nuevaHora.hour,
      nuevaHora.minute,
    );

    try {
      widget.controladorCitas.reprogramarCita(
        citaId: cita.id,
        nuevaFecha: nuevaFecha,
      );
      setState(() {
        _mensaje = 'Cita reprogramada con exito.';
        _esError = false;
      });
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
        _esError = true;
      });
    }
  }

  Future<void> _cancelar(Cita cita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: Text(
          '¿Deseas cancelar la cita del ${_formatoFecha(cita.fecha)} '
          'en ${cita.puntoVacunacion.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Si, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      widget.controladorCitas.cancelarCita(cita.id);
      setState(() {
        _mensaje = 'Cita cancelada. El cupo fue liberado.';
        _esError = false;
      });
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
        _esError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final citas =
        widget.controladorCitas.citasDe(widget.usuarioActual.fullName);

    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento de citas')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_mensaje != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _esError ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _mensaje!,
                  style: TextStyle(
                    color:
                        _esError ? Colors.red.shade700 : Colors.green.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: citas.isEmpty
                  ? const Center(child: Text('No tienes citas registradas.'))
                  : ListView.builder(
                      itemCount: citas.length,
                      itemBuilder: (context, index) {
                        final cita = citas[index];
                        final cancelada = cita.estado == EstadoCita.cancelada;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cita.puntoVacunacion.nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('Campana: ${cita.campana.nombre}'),
                                Text('Fecha: ${_formatoFecha(cita.fecha)}'),
                                Text(
                                  'Estado: ${_etiquetaEstado(cita.estado)}',
                                  style: TextStyle(
                                    color: cancelada
                                        ? Colors.red.shade700
                                        : Colors.green.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!cancelada)
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _reprogramar(cita),
                                        icon: const Icon(
                                            Icons.edit_calendar_outlined),
                                        label: const Text('Reprogramar'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _cancelar(cita),
                                        icon: const Icon(Icons.cancel_outlined),
                                        label: const Text('Cancelar'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
