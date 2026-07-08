import 'package:flutter/material.dart';

import '../controllers/controlador_citas.dart';
import '../controllers/controlador_vacunaciones.dart';
import '../models/campana.dart';
import '../models/cita.dart';
import '../models/punto_vacunacion.dart';
import '../models/usuario.dart';
import 'historial_vacunacion_screen.dart';
import '../services/auth_service.dart';

//pantalla de seguimiento de citas: permite consultar las citas de
//vacunacion propias, reprogramarlas para ajustar el turno ante
//imprevistos, y cancelarlas para liberar el cupo en el sistema.

class SeguimientoCitasScreen extends StatefulWidget {
  final Usuario usuarioActual;
  final ControladorCitas controladorCitas;
  final ControladorVacunaciones controladorVacunaciones;
  final List<Campana> campanas;
  final List<PuntoVacunacion> puntosVacunacion;
  final bool puedeGestionarOtros;

  const SeguimientoCitasScreen({
    super.key,
    required this.usuarioActual,
    required this.controladorCitas,
    required this.controladorVacunaciones,
    required this.campanas,
    required this.puntosVacunacion,
    required this.puedeGestionarOtros,
  });

  @override
  State<SeguimientoCitasScreen> createState() => _SeguimientoCitasScreenState();
}

class _SeguimientoCitasScreenState extends State<SeguimientoCitasScreen> {
  final _authService = AuthService();
  final _busquedaController = TextEditingController();
  String? _mensaje;
  bool _esError = false;

  @override
  void initState() {
    super.initState();
    _busquedaController.text = widget.usuarioActual.rut;
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

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

  String _normalizar(String value) {
    return value.trim().toLowerCase();
  }

  Usuario? _resolverPersonaDeCita(Cita cita) {
    return _authService.buscarUsuario(cita.persona);
  }

  void _atenderCita(Cita cita) {
    final persona = _resolverPersonaDeCita(cita);
    if (persona == null) {
      setState(() {
        _mensaje = 'No se encontro la persona asociada a esta cita.';
        _esError = true;
      });
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistorialVacunacionScreen(
          usuarioActual: widget.usuarioActual,
          personaInicial: persona,
          citaInicial: cita,
          controladorVacunaciones: widget.controladorVacunaciones,
          campanas: widget.campanas,
          puntosVacunacion: widget.puntosVacunacion,
          puedeConsultarOtros: widget.puedeGestionarOtros,
          puedeRegistrarVacunacion: widget.puedeGestionarOtros,
        ),
      ),
    );
  }

  List<Cita> _citasParaConsulta(String query) {
    final valorBuscado = query.trim();
    if (valorBuscado.isEmpty) {
      return [];
    }

    final usuario = _authService.buscarUsuario(valorBuscado);
    final valoresPermitidos = <String>{_normalizar(valorBuscado)};

    if (usuario != null) {
      valoresPermitidos.addAll({
        _normalizar(usuario.username),
        _normalizar(usuario.email),
        _normalizar(usuario.rut),
        _normalizar(usuario.fullName),
      });
    }

    final citas = widget.controladorCitas.citasAgendadas
        .where((cita) => valoresPermitidos.contains(_normalizar(cita.persona)))
        .toList();

    citas.sort((a, b) => b.fecha.compareTo(a.fecha));
    return citas;
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
    final persona = widget.puedeGestionarOtros
        ? _busquedaController.text
        : widget.usuarioActual.rut;
    final citas = _citasParaConsulta(persona);

    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento de citas')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.puedeGestionarOtros) ...[
              TextField(
                controller: _busquedaController,
                decoration: const InputDecoration(
                  labelText: 'RUT de la persona',
                  prefixIcon: Icon(Icons.person_search_outlined),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],
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
                                      if (widget.puedeGestionarOtros)
                                        FilledButton.icon(
                                          onPressed: () => _atenderCita(cita),
                                          icon: const Icon(Icons.assignment_outlined),
                                          label: const Text('Atender cita'),
                                        ),
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
