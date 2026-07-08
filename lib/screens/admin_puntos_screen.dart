import 'package:flutter/material.dart';
import '../controllers/controlador_puntos_vacunacion.dart';
import '../controllers/controlador_campanas.dart';
import '../models/campana.dart';
import '../models/punto_vacunacion.dart';

class AdminPuntosScreen extends StatefulWidget {
  final ControladorPuntosVacunacion controladorPuntos;
  final ControladorCampanas controladorCampanas;

  const AdminPuntosScreen({
    super.key,
    required this.controladorPuntos,
    required this.controladorCampanas,
  });

  @override
  State<AdminPuntosScreen> createState() => _AdminPuntosScreenState();
}

class _AdminPuntosScreenState extends State<AdminPuntosScreen> {
  final _nombrePuntoController = TextEditingController();
  final _capacidadController = TextEditingController();

  Campana? _campanaSeleccionada;
  PuntoVacunacion? _puntoSeleccionado;

  String? _mensajePunto;
  bool _esErrorPunto = false;

  String? _mensajeAsociacion;
  bool _esErrorAsociacion = false;

  @override
  void dispose() {
    _nombrePuntoController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  void _agregarPunto() {
    try {
      final capacidad = int.tryParse(_capacidadController.text) ?? 0;
      widget.controladorPuntos.agregarPunto(
        nombre: _nombrePuntoController.text,
        capacidadDiaria: capacidad,
      );
      setState(() {
        _mensajePunto = 'Centro de vacunación agregado con éxito.';
        _esErrorPunto = false;
        _nombrePuntoController.clear();
        _capacidadController.clear();
      });
    } catch (e) {
      setState(() {
        _mensajePunto = e.toString().replaceFirst('Exception: ', '');
        _esErrorPunto = true;
      });
    }
  }

  void _asociarCampana() {
    if (_campanaSeleccionada == null || _puntoSeleccionado == null) {
      setState(() {
        _mensajeAsociacion = 'Selecciona una campaña y un centro de vacunación.';
        _esErrorAsociacion = true;
      });
      return;
    }

    try {
      widget.controladorPuntos.asociarCampana(
        punto: _puntoSeleccionado!,
        campana: _campanaSeleccionada!,
      );
      setState(() {
        _mensajeAsociacion = 'Campaña asociada con éxito al centro de vacunación.';
        _esErrorAsociacion = false;
        _campanaSeleccionada = null;
        _puntoSeleccionado = null;
      });
    } catch (e) {
      setState(() {
        _mensajeAsociacion = e.toString().replaceFirst('Exception: ', '');
        _esErrorAsociacion = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final puntos = widget.controladorPuntos.puntos;
    final campanas = widget.controladorCampanas.campanas;
    final ofertas = widget.controladorPuntos.ofertas;

    return Scaffold(
      appBar: AppBar(title: const Text('Centros y Asociaciones')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Agregar Centro de Vacunación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nombrePuntoController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del centro',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _capacidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad diaria de citas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _agregarPunto,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Agregar centro'),
                    ),
                    if (_mensajePunto != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _esErrorPunto ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _mensajePunto!,
                          style: TextStyle(color: _esErrorPunto ? Colors.red.shade700 : Colors.green.shade800),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Asociar Campaña a Centro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Campana>(
                      value: _campanaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Campaña',
                        border: OutlineInputBorder(),
                      ),
                      items: campanas.map((c) => DropdownMenuItem(value: c, child: Text(c.nombre))).toList(),
                      onChanged: (v) => setState(() => _campanaSeleccionada = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PuntoVacunacion>(
                      value: _puntoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Centro de vacunación',
                        border: OutlineInputBorder(),
                      ),
                      items: puntos.map((p) => DropdownMenuItem(value: p, child: Text(p.nombre))).toList(),
                      onChanged: (v) => setState(() => _puntoSeleccionado = v),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _asociarCampana,
                      icon: const Icon(Icons.link),
                      label: const Text('Asociar campaña'),
                    ),
                    if (_mensajeAsociacion != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _esErrorAsociacion ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _mensajeAsociacion!,
                          style: TextStyle(color: _esErrorAsociacion ? Colors.red.shade700 : Colors.green.shade800),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Campañas Disponibles por Centro (${ofertas.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (ofertas.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aún no hay asociaciones registradas.'),
                ),
              )
            else
              ...ofertas.map((oferta) => Card(
                child: ListTile(
                  leading: const Icon(Icons.vaccines_outlined),
                  title: Text(oferta.puntoVacunacion.nombre),
                  subtitle: Text('Campaña: ${oferta.campana.nombre}'),
                ),
              )),
          ],
        ),
      ),
    );
  }
}