import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../controllers/controlador_registro.dart';
import 'appointment_screen.dart';

enum _AuthSection { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerRutController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerCellPhoneController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _authService = AuthService();
  final _controladorRegistro = ControladorRegistro();
  _AuthSection _selectedSection = _AuthSection.login;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _registerNameController.dispose();
    _registerRutController.dispose();
    _registerEmailController.dispose();
    _registerCellPhoneController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final Usuario? account = _authService.autenticar(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (account == null) {
      setState(() {
        _errorMessage = 'Usuario o contraseña incorrectos.';
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AppointmentScreen(user: account),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));

    try {
      _controladorRegistro.registrarUsuario(
        fullName: _registerNameController.text,
        rut: _registerRutController.text,
        email: _registerEmailController.text,
        cellPhone: _registerCellPhoneController.text,
        password: _registerPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _selectedSection = _AuthSection.login;
        _usernameController.text = _registerEmailController.text.trim();
        _passwordController.text = _registerPasswordController.text;
        _registerNameController.clear();
        _registerRutController.clear();
        _registerEmailController.clear();
        _registerCellPhoneController.clear();
        _registerPasswordController.clear();
        _successMessage =
            'Usuario registrado con exito. Ahora puedes iniciar sesion.';
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String? _validarCorreo(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Ingresa tu correo';
    }
    if (!texto.contains('@') || !texto.contains('.')) {
      return 'Ingresa un correo valido';
    }
    return null;
  }

  String? _validarTelefono(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Ingresa tu numero de celular';
    }
    final soloDigitos = texto.replaceAll(RegExp(r'[^0-9]'), '');
    if (soloDigitos.length < 8 || soloDigitos.length > 15) {
      return 'Ingresa un numero de celular valido';
    }
    return null;
  }

  Widget _buildLoginSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Usuario, correo o RUT',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa tu usuario, correo o RUT';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu contraseña';
            }
            if (value.length < 4) {
              return 'La contraseña es demasiado corta';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _isLoading ? null : _handleLogin,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Iniciar sesion'),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _registerNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa tu nombre';
            }
            if (value.trim().length < 3) {
              return 'Ingresa un nombre valido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerRutController,
          decoration: const InputDecoration(
            labelText: 'RUT',
            prefixIcon: Icon(Icons.credit_card_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa tu RUT';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          validator: _validarCorreo,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerCellPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Numero de celular',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(),
          ),
          validator: _validarTelefono,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Crear contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Crea una contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _isLoading ? null : _handleRegister,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Registrar usuario'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7BB4), Color(0xFF7BB7C1), Color(0xFFF3F7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 14,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'Campana-Vacunacion-2026_banner-1040x220-1.png',
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Sistema de Vacunacion',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Accede para agendar citas de vacunacion.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 24),
                          SegmentedButton<_AuthSection>(
                            segments: const [
                              ButtonSegment(
                                value: _AuthSection.login,
                                label: Text('Iniciar sesion'),
                                icon: Icon(Icons.login_outlined),
                              ),
                              ButtonSegment(
                                value: _AuthSection.register,
                                label: Text('Registrarse'),
                                icon: Icon(Icons.person_add_outlined),
                              ),
                            ],
                            selected: {_selectedSection},
                            onSelectionChanged: (selection) {
                              setState(() {
                                _selectedSection = selection.first;
                                _errorMessage = null;
                                _successMessage = null;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: _selectedSection == _AuthSection.login
                                ? _buildLoginSection()
                                : _buildRegisterSection(),
                          ),
                          const SizedBox(height: 16),
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8E6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMessage!,
                                style:
                                    const TextStyle(color: Color(0xFFD6453D)),
                              ),
                            ),
                          if (_successMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F6EA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _successMessage!,
                                style:
                                    const TextStyle(color: Color(0xFF26734D)),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            'Cuentas de prueba:\n'
                            'Ciudadano: usuario / vacuna2026\n'
                            'Funcionario: funcionario / funcion2026\n'
                            'Administrador: administrador / admin2026',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF5B7280),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}