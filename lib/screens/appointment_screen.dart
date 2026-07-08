import 'package:flutter/material.dart';
import '../controllers/controlador_campanas.dart';
import '../controllers/controlador_citas.dart';
import '../controllers/controlador_vacunaciones.dart';
import '../controllers/controlador_puntos_vacunacion.dart';
import '../domain/gestor_campanas.dart';
import '../domain/gestor_citas.dart';
import '../domain/gestor_vacunaciones.dart';
import '../domain/gestor_puntos_vacunacion.dart';
import '../domain/permisos.dart';
import '../models/campana.dart';
import '../models/cita.dart';
import '../models/punto_vacunacion.dart';
import '../models/rol.dart';
import '../models/usuario.dart';
import '../services/notification_service.dart';
import 'admin_campanas_screen.dart';
import 'admin_puntos_screen.dart';
import 'ficha_screen.dart';
import 'historial_vacunacion_screen.dart';
import 'login_screen.dart';
import 'seguimiento_citas_screen.dart';

class AppointmentScreen extends StatefulWidget {
  final Usuario user;
  const AppointmentScreen({super.key, required this.user});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _gestorCitas = GestorCitas();
  final _notificationService = NotificationService();
  late final ControladorCitas _controladorCitas;

  final _gestorVacunaciones = GestorVacunaciones();
  late final ControladorVacunaciones _controladorVacunaciones;

  final _gestorCampanas = GestorCampanas();
  late final ControladorCampanas _controladorCampanas;

  final _gestorPuntos = GestorPuntosVacunacion();
  late final ControladorPuntosVacunacion _controladorPuntos;

  Campana? _campanaSeleccionada;
  PuntoVacunacion? _puntoSeleccionado;
  late final List<DateTime> _fechasDisponibles;
  late final List<TimeOfDay> _horariosDisponibles;

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  String? _mensaje;
  bool _esError = false;

  @override
  void initState() {
    super.initState();
    _controladorCitas = ControladorCitas(_gestorCitas, _notificationService);
    _controladorVacunaciones = ControladorVacunaciones(_gestorVacunaciones);
    _controladorCampanas = ControladorCampanas(_gestorCampanas);
    _controladorPuntos = ControladorPuntosVacunacion(_gestorPuntos);

    // Inicializar dinámicamente según controlador principal
    _controladorPuntos.inicializarOfertas(_controladorCampanas.campanas);

    _fechasDisponibles = _generarFechasDisponibles();
    _horariosDisponibles = _generarHorariosDisponibles();
  }

  List<Campana> get _campanas => _controladorCampanas.campanas;

  @override
  void dispose() {
    super.dispose();
  }

  List<DateTime> _generarFechasDisponibles() {
    final fechas = <DateTime>[];
    var fecha = DateTime.now();
    while (fechas.length < 20) {
      if (fecha.weekday >= DateTime.monday && fecha.weekday <= DateTime.friday) {
        fechas.add(DateTime(fecha.year, fecha.month, fecha.day));
      }
      fecha = fecha.add(const Duration(days: 1));
    }
    return fechas;
  }

  List<TimeOfDay> _generarHorariosDisponibles() {
    final horarios = <TimeOfDay>[];
    for (var hora = 9; hora <= 17; hora++) {
      horarios.add(TimeOfDay(hour: hora, minute: 0));
      if (hora != 17) {
        horarios.add(TimeOfDay(hour: hora, minute: 30));
      }
    }
    return horarios;
  }

  bool get _puedeElegirFechaHora => _campanaSeleccionada != null && _puntoSeleccionado != null;

  String _formatoFechaCorta(DateTime fecha) {
    const dias = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final diaSemana = dias[fecha.weekday - 1];
    return '$diaSemana ${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatoHora(TimeOfDay hora) {
    final horaTexto = hora.hour.toString().padLeft(2, '0');
    final minutoTexto = hora.minute.toString().padLeft(2, '0');
    return '$horaTexto:$minutoTexto';
  }

  void _actualizarFechaHoraInicial() {
    if (_fechaSeleccionada == null) _fechaSeleccionada = _fechasDisponibles.first;
    if (_horaSeleccionada == null) _horaSeleccionada = _horariosDisponibles.first;
  }

  void _agendarCita() {
    if (!_puedeElegirFechaHora || _fechaSeleccionada == null || _horaSeleccionada == null) {
      setState(() {
        _mensaje = 'Selecciona campaña, punto, fecha y hora antes de agendar.';
        _esError = true;
      });
      return;
    }

    try {
      final fechaHora = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      final Cita cita = _controladorCitas.agendarCita(
        persona: widget.user.fullName,
        puntoVacunacion: _puntoSeleccionado!,
        fecha: fechaHora,
        campana: _campanaSeleccionada!,
        email: widget.user.email,
      );

      setState(() {
        _mensaje = 'Cita agendada con éxito para ${cita.persona} en ${cita.puntoVacunacion.nombre}';
        _esError = false;
      });
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
        _esError = true;
      });
    }
  }

  void _abrirFicha() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FichaScreen(
          usuarioActual: widget.user,
          controladorCitas: _controladorCitas,
          controladorVacunaciones: _controladorVacunaciones,
          puedeConsultarOtros: Permisos.puedeConsultarDatosDeOtros(widget.user.rol),
        ),
      ),
    );
  }

  void _abrirHistorialVacunacion() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistorialVacunacionScreen(
          usuarioActual: widget.user,
          controladorVacunaciones: _controladorVacunaciones,
          campanas: _campanas,
          puntosVacunacion: _controladorPuntos.puntos,
          puedeConsultarOtros: Permisos.puedeConsultarDatosDeOtros(widget.user.rol),
          puedeRegistrarVacunacion: Permisos.puedeRegistrarVacunacion(widget.user.rol),
        ),
      ),
    );
  }

  void _abrirSeguimientoCitas() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => SeguimientoCitasScreen(
            usuarioActual: widget.user,
            controladorCitas: _controladorCitas,
            puedeGestionarOtros: Permisos.puedeGestionarCitasDeOtros(widget.user.rol),
          ),
        ))
        .then((_) => setState(() {}));
  }

  void _abrirAdminCampanas() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => AdminCampanasScreen(
            controladorCampanas: _controladorCampanas,
          ),
        ))
        .then((_) => setState(() {}));
  }

  void _abrirAdminPuntos() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => AdminPuntosScreen(
            controladorPuntos: _controladorPuntos,
            controladorCampanas: _controladorCampanas,
          ),
        ))
        .then((_) => setState(() {
              _campanaSeleccionada = null;
              _puntoSeleccionado = null;
              _fechaSeleccionada = null;
              _horaSeleccionada = null;
            }));
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: Text('¿Deseas cerrar la sesión de ${widget.user.fullName} (${widget.user.rol.etiqueta})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sí, cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _construirEnlaceHeader(String texto, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final citasAgendadas = _controladorCitas.citasAgendadas.where((cita) => cita.estado != EstadoCita.cancelada).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Agendar cita de vacunación'),
              const SizedBox(width: 20),
              _construirEnlaceHeader('Historial de vacunaciones', _abrirHistorialVacunacion),
              const SizedBox(width: 8),
              _construirEnlaceHeader('Seguimiento de citas', _abrirSeguimientoCitas),
              if (Permisos.puedeDefinirCampanas(widget.user.rol)) ...[
                const SizedBox(width: 8),
                _construirEnlaceHeader('Campañas de vacunación', _abrirAdminCampanas),
              ],
              if (Permisos.puedeGestionarPuntosVacunacion(widget.user.rol)) ...[
                const SizedBox(width: 8),
                _construirEnlaceHeader('Centros de vacunación', _abrirAdminPuntos),
              ],
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Ficha de usuario',
            icon: const Icon(Icons.badge_outlined),
            onPressed: _abrirFicha,
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'Campana-Vacunacion-2026_banner-1040x220-1.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7BB4), Color(0xFF7BB7C1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, ${widget.user.fullName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.user.rol.etiqueta,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seleccione la campaña y el punto de vacunación para agendar su cita.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Campana>(
                      value: _campanaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Campaña',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.campaign_outlined),
                      ),
                      items: _campanas.map((campana) => DropdownMenuItem(value: campana, child: Text(campana.nombre))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _campanaSeleccionada = value;
                          _puntoSeleccionado = null;
                          _fechaSeleccionada = null;
                          _horaSeleccionada = null;
                          _mensaje = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PuntoVacunacion>(
                      value: _puntoSeleccionado,
                      decoration: InputDecoration(
                        labelText: _campanaSeleccionada == null ? 'Seleccione primero la campaña' : 'Punto de vacunación',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                      ),
                      items: _campanaSeleccionada == null
                          ? const []
                          : _controladorPuntos.puntosPorCampana(_campanaSeleccionada!)
                              .map((punto) => DropdownMenuItem(value: punto, child: Text(punto.nombre)))
                              .toList(),
                      onChanged: _campanaSeleccionada == null
                          ? null
                          : (value) {
                              setState(() {
                                _puntoSeleccionado = value;
                                _fechaSeleccionada = null;
                                _horaSeleccionada = null;
                                _mensaje = null;
                              });
                              _actualizarFechaHoraInicial();
                            },
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _puedeElegirFechaHora
                          ? Column(
                              key: const ValueKey('fechaHoraSection'),
                              children: [
                                DropdownButtonFormField<DateTime>(
                                  value: _fechaSeleccionada,
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha disponible',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_month_outlined),
                                  ),
                                  items: _fechasDisponibles.map((fecha) => DropdownMenuItem(value: fecha, child: Text(_formatoFechaCorta(fecha)))).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _fechaSeleccionada = value;
                                      _mensaje = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<TimeOfDay>(
                                  value: _horaSeleccionada,
                                  decoration: const InputDecoration(
                                    labelText: 'Horario disponible',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.schedule_outlined),
                                  ),
                                  items: _horariosDisponibles.map((hora) => DropdownMenuItem(value: hora, child: Text(_formatoHora(hora)))).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _horaSeleccionada = value;
                                      _mensaje = null;
                                    });
                                  },
                                ),
                              ],
                            )
                          : Container(
                              key: const ValueKey('fechaHoraHint'),
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Selecciona la campaña y el punto de vacunación para habilitar la fecha y hora.',
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _puedeElegirFechaHora ? _agendarCita : null,
                      icon: const Icon(Icons.event_available_outlined),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Agendar cita'),
                      ),
                    ),
                    if (_mensaje != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _esError ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _mensaje!,
                          style: TextStyle(
                            color: _esError ? Colors.red.shade700 : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Citas agendadas (${citasAgendadas.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            if (citasAgendadas.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Aún no hay citas registradas.'),
                ),
              )
            else
              ...citasAgendadas.map(
                (cita) => Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'Campana-Vacunacion-2026_banner-1040x220-1.png',
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(cita.persona),
                    subtitle: Text(
                      '${cita.puntoVacunacion.nombre}\nCampaña: ${cita.campana.nombre}\nFecha: ${_formatoFechaCorta(cita.fecha)}\nHora: ${_formatoHora(TimeOfDay.fromDateTime(cita.fecha))}'
                      '${cita.estado == EstadoCita.reprogramada ? '\n(Reprogramada)' : ''}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
