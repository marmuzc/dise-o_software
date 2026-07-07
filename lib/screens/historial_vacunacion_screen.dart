import 'package:flutter/material.dart';

import '../controllers/controlador_vacunaciones.dart';
import '../models/campana.dart';
import '../models/punto_vacunacion.dart';
import '../models/usuario.dart';

//pantalla de historial de vacunacion: permite consultar las dosis
//que una persona ya recibio, y permite al funcionario registrar
//una vacunacion realizada (asociada a persona, campana y centro).

class HistorialVacunacionScreen extends StatefulWidget {
  final Usuario usuarioActual;
  final ControladorVacunaciones controladorVacunaciones;
  final List<Campana> campanas;
  final List<PuntoVacunacion> puntosVacunacion;
  final bool puedeConsultarOtros;
  final bool puedeRegistrarVacunacion;

  const HistorialVacunacionScreen({
    super.key,
    required this.usuarioActual,
    required this.controladorVacunaciones,
    required this.campanas,
    required this.puntosVacunacion,
    required this.puedeConsultarOtros,
    required this.puedeRegistrarVacunacion,
  });

  @override
  State<HistorialVacunacionScreen> createState() =>
      _HistorialVacunacionScreenState();
}

class _HistorialVacunacionScreenState
    extends State<HistorialVacunacionScreen> {
  final _busquedaController = TextEditingController();
  final _dosisController = TextEditingController();
  Campana? _campanaSeleccionada;
  PuntoVacunacion? _puntoSeleccionado;
  DateTime _fechaAplicacion = DateTime.now();
  String? _mensaje;
  bool _esError = false;

  @override
  void initState() {
    super.initState();
    _busquedaController.text = widget.usuarioActual.fullName;
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _dosisController.dispose();
    super.dispose();
  }

  void _registrarVacunacion() {
    if (!widget.puedeRegistrarVacunacion) {
      return;
    }

    if (_busquedaController.text.trim().isEmpty) {
      setState(() {
        _mensaje = 'Indica la persona vacunada.';
        _esError = true;
      });
      return;
    }

    if (_campanaSeleccionada == null || _puntoSeleccionado == null) {
      setState(() {
        _mensaje = 'Selecciona campana y punto de vacunacion.';
        _esError = true;
      });
      return;
    }

    try {
      widget.controladorVacunaciones.registrarVacunacion(
        persona: _busquedaController.text,
        campana: _campanaSeleccionada!,
        puntoVacunacion: _puntoSeleccionado!,
        fechaAplicacion: _fechaAplicacion,
        dosis: _dosisController.text,
        registradoPor: widget.usuarioActual.username,
      );

      setState(() {
        _mensaje = 'Vacunacion registrada con exito.';
        _esError = false;
        _dosisController.clear();
      });
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
        _esError = true;
      });
    }
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaAplicacion,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fechaAplicacion = fecha);
    }
  }

  String _formatoFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final historial =
        widget.controladorVacunaciones.historialDe(_busquedaController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de vacunacion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _busquedaController,
              enabled: widget.puedeConsultarOtros,
              decoration: InputDecoration(
                labelText: 'Persona (nombre completo)',
                prefixIcon: const Icon(Icons.person_search_outlined),
                border: const OutlineInputBorder(),
                helperText: widget.puedeConsultarOtros
                    ? null
                    : 'Tu rol solo puede ver su propio historial.',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              'Dosis registradas (${historial.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (historial.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay dosis registradas para esta persona.'),
                ),
              )
            else
              ...historial.map(
                (registro) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.vaccines_outlined),
                    title: Text(
                        '${registro.dosis} - ${registro.campana.nombre}'),
                    subtitle: Text(
                      '${registro.puntoVacunacion.nombre}\n'
                      'Fecha: ${_formatoFecha(registro.fechaAplicacion)}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            if (widget.puedeRegistrarVacunacion) ...[
              const SizedBox(height: 24),
              Text(
                'Registrar vacunacion realizada',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<Campana>(
                        initialValue: _campanaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Campana',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.campanas
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c.nombre)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _campanaSeleccionada = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PuntoVacunacion>(
                        initialValue: _puntoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Centro de vacunacion',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.puntosVacunacion
                            .map((p) => DropdownMenuItem(
                                value: p, child: Text(p.nombre)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _puntoSeleccionado = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _dosisController,
                        decoration: const InputDecoration(
                          labelText: 'Dosis (ej: 1ra dosis, Refuerzo)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                                'Fecha: ${_formatoFecha(_fechaAplicacion)}'),
                          ),
                          TextButton(
                            onPressed: _elegirFecha,
                            child: const Text('Cambiar fecha'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _registrarVacunacion,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Registrar vacunacion'),
                      ),
                      if (_mensaje != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _esError
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _mensaje!,
                            style: TextStyle(
                              color: _esError
                                  ? Colors.red.shade700
                                  : Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}