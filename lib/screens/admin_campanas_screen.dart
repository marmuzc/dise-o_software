import 'package:flutter/material.dart';

import '../controllers/controlador_campanas.dart';
import '../models/campana.dart';

//pantalla exclusiva del Administrador: permite definir nuevas
//campanas de vacunacion (nombre, descripcion, fechas) y actualizar
//la vigencia y el estado de las campanas ya existentes.

class AdminCampanasScreen extends StatefulWidget {
  final ControladorCampanas controladorCampanas;

  const AdminCampanasScreen({
    super.key,
    required this.controladorCampanas,
  });

  @override
  State<AdminCampanasScreen> createState() => _AdminCampanasScreenState();
}

class _AdminCampanasScreenState extends State<AdminCampanasScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(days: 30));
  String? _mensaje;
  bool _esError = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  String _formatoFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  Future<void> _elegirFecha({required bool esInicio}) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (fecha == null) return;

    setState(() {
      if (esInicio) {
        _fechaInicio = fecha;
      } else {
        _fechaFin = fecha;
      }
    });
  }

  void _definirCampana() {
    try {
      widget.controladorCampanas.definirCampana(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      );

      setState(() {
        _mensaje = 'Campana definida con exito.';
        _esError = false;
        _nombreController.clear();
        _descripcionController.clear();
      });
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
        _esError = true;
      });
    }
  }

  Future<void> _editarVigencia(Campana campana) async {
    var nuevaFechaInicio = campana.fechaInicio;
    var nuevaFechaFin = campana.fechaFin;

    final inicio = await showDatePicker(
      context: context,
      initialDate: campana.fechaInicio,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (inicio == null || !mounted) return;
    nuevaFechaInicio = inicio;

    final fin = await showDatePicker(
      context: context,
      initialDate: campana.fechaFin,
      firstDate: nuevaFechaInicio,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (fin == null || !mounted) return;
    nuevaFechaFin = fin;

    try {
      widget.controladorCampanas.actualizarVigencia(
        campanaId: campana.id,
        nuevaFechaInicio: nuevaFechaInicio,
        nuevaFechaFin: nuevaFechaFin,
      );
      setState(() {
        _mensaje = 'Vigencia de "${campana.nombre}" actualizada.';
        _esError = false;
      });
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
        _esError = true;
      });
    }
  }

  void _cambiarEstado(Campana campana, bool nuevoEstado) {
    try {
      widget.controladorCampanas.actualizarEstado(
        campanaId: campana.id,
        nuevoEstado: nuevoEstado,
      );
      setState(() {
        _mensaje = nuevoEstado
            ? '"${campana.nombre}" fue activada.'
            : '"${campana.nombre}" fue desactivada.';
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
    final campanas = widget.controladorCampanas.campanas;

    return Scaffold(
      appBar: AppBar(title: const Text('Campanas de vacunacion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Definir nueva campana',
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
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la campana',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descripcionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _elegirFecha(esInicio: true),
                            child:
                                Text('Inicio: ${_formatoFecha(_fechaInicio)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _elegirFecha(esInicio: false),
                            child: Text('Fin: ${_formatoFecha(_fechaFin)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _definirCampana,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Definir campana'),
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
            const SizedBox(height: 24),
            Text(
              'Campanas registradas (${campanas.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (campanas.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aun no hay campanas registradas.'),
                ),
              )
            else
              ...campanas.map(
                (campana) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                campana.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Switch(
                              value: campana.estado,
                              onChanged: (valor) =>
                                  _cambiarEstado(campana, valor),
                            ),
                          ],
                        ),
                        Text(campana.descripcion),
                        const SizedBox(height: 4),
                        Text(
                          'Vigencia: ${_formatoFecha(campana.fechaInicio)} '
                          '- ${_formatoFecha(campana.fechaFin)}',
                        ),
                        Text(
                          campana.estado
                              ? 'Estado: Activa'
                              : 'Estado: Inactiva',
                          style: TextStyle(
                            color: campana.estado
                                ? Colors.green.shade800
                                : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _editarVigencia(campana),
                          icon: const Icon(Icons.edit_calendar_outlined),
                          label: const Text('Actualizar vigencia'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
