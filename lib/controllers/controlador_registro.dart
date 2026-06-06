import '../models/usuario.dart';
import '../services/auth_service.dart';

//siguiendo el diagrama comunicacional factory:
/// ControladorRegistro actua como una farica (Factory) de Usuario.
/// Se encarga de validar y crear la instancia del modelo `Usuario` y
/// delega la persistencia en AuthService ().
class ControladorRegistro {
  final AuthService _authService = AuthService();

  /// Crea (factory) un objeto usuario a partir de los datos proporcionados.
  Usuario crearUsuario({
    required String fullName,
    required String rut,
    required String email,
    required String cellPhone,
    required String password,
  }) {
    final nombre = fullName.trim();
    if (nombre.isEmpty || nombre.length < 3) {
      throw Exception('Ingresa un nombre valido');
    }

    final rutTrim = rut.trim();
    if (rutTrim.isEmpty) {
      throw Exception('Ingresa tu RUT');
    }

    final correo = email.trim();
    if (correo.isEmpty || !correo.contains('@') || !correo.contains('.')) {
      throw Exception('Ingresa un correo valido');
    }

    final celular = cellPhone.trim();
    final digitos = celular.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length < 8 || digitos.length > 15) {
      throw Exception('Ingresa un numero de celular valido');
    }

    if (password.isEmpty || password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    final username = correo.toLowerCase();

    return Usuario(
      username: username,
      fullName: nombre,
      rut: rutTrim,
      email: correo,
      cellPhone: celular,
      password: password,
    );
  }

  /// Valida y crea la instancia, luego la persiste delegando en `AuthService`.
  Usuario registrarUsuario({
    required String fullName,
    required String rut,
    required String email,
    required String cellPhone,
    required String password,
  }) {
    final usuario = crearUsuario(
      fullName: fullName,
      rut: rut,
      email: email,
      cellPhone: cellPhone,
      password: password,
    );

    return _authService.guardarUsuario(usuario);
  }
}
