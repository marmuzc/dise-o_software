import 'package:flutter/material.dart';

import '../controllers/controlador_citas.dart';
import '../controllers/controlador_vacunaciones.dart';
import '../models/cita.dart';
import '../models/registro_vacunacion.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

//pantalla para que el funcionario/usuario consulte la ficha de una
//persona usuaria y verifique sus antecedentes registrados: datos
//personales, citas asociadas y dosis de vacunacion aplicadas.

class FichaScreen extends StatefulWidget {
  final Usuario usuarioActual;
  final ControladorCitas controladorCitas;
  final ControladorVacunaciones controladorVacunaciones;

  const FichaScreen({
    super.key,
    required this.usuarioActual,
    required this.controladorCitas,
    required this.controladorVacunaciones,
  });

  @override
  State<FichaScreen> createState() => _FichaScreenState();
}

class _FichaScreenState extends State<FichaScreen> {
  final _authService = AuthService();
  final _busquedaController = TextEditingController();
  Usuario? _personaConsultada;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    _busquedaController.text = widget.usuarioActual.fullName;
    _personaConsultada = widget.usuarioActual;
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _consultarFicha() {
    final texto = _busquedaController.text.trim();
    if (texto.isEmpty) {
      setState(() {
        _mensaje = 'Ingresa un nombre, RUT o correo para buscar.';
        _personaConsultada = null;
      });
      return;
    }

    final encontrado = _authService.buscarUsuario(texto);

    setState(() {
      _personaConsultada = encontrado;
      _mensaje = encontrado == null
          ? 'No se encontro ninguna persona usuaria con esos datos.'
          : null;
    });
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

  @override
  Widget build(BuildContext context) {
    final persona = _personaConsultada;
    final List<Cita> citas = persona == null
        ? []
        : widget.controladorCitas.citasDe(persona.fullName);
    final List<RegistroVacunacion> historial = persona == null
        ? []
        : widget.controladorVacunaciones.historialDe(persona.fullName);
    final citasActivas =
        citas.where((c) => c.estado != EstadoCita.cancelada).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Ficha de la persona usuaria')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busquedaController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre, RUT o correo',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _consultarFicha(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _consultarFicha,
                  child: const Text('Consultar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_mensaje != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _mensaje!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (persona != null)
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              persona.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('RUT: ${persona.rut}'),
                            Text('Correo: ${persona.email}'),
                            Text('Celular: ${persona.cellPhone}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Antecedentes registrados',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.event_note_outlined),
                        title: Text('Citas registradas: ${citas.length}'),
                        subtitle: Text('Activas: $citasActivas'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.vaccines_outlined),
                        title: Text('Dosis aplicadas: ${historial.length}'),
                      ),
                    ),
                    if (citas.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Detalle de citas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...citas.map(
                        (cita) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.local_hospital_outlined),
                            title: Text(cita.puntoVacunacion.nombre),
                            subtitle: Text(
                              'Campana: ${cita.campana.nombre}\n'
                              'Estado: ${_etiquetaEstado(cita.estado)}',
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
