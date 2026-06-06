import '../models/usuario.dart';

class AuthService {
  static final Map<String, Usuario> _usuarios = {
    'usuario': Usuario(
      username: 'usuario',
      fullName: 'Maria Perez',
      rut: '11.111.111-1',
      email: 'admin@vacunacion.cl',
      cellPhone: '912345678',
      password: 'vacuna2026',
    ),
  };

  Usuario? autenticar({required String username, required String password}) {
    final valorBuscado = _normalizar(username);

    for (final account in _usuarios.values) {
      final coincideCredencial =
          _normalizar(account.username) == valorBuscado ||
              _normalizar(account.email) == valorBuscado ||
              _normalizar(account.rut) == valorBuscado;

      if (coincideCredencial && account.password == password.trim()) {
        return account;
      }
    }

    return null;
  }

  Usuario registrarUsuario({
    required String fullName,
    required String rut,
    required String email,
    required String cellPhone,
    required String password,
  }) {
    // Mantener compatibilidad: construir el Usuario y delegar en guardarUsuario
    final nuevo = Usuario(
      username: _normalizar(email),
      fullName: fullName.trim(),
      rut: rut.trim(),
      email: email.trim(),
      cellPhone: cellPhone.trim(),
      password: password,
    );

    return guardarUsuario(nuevo);
  }

  /// Guarda un [Usuario] ya construido, validando duplicados.
  Usuario guardarUsuario(Usuario usuario) {
    final emailNormalizado = _normalizar(usuario.email);
    final rutNormalizado = _normalizar(usuario.rut);

    final emailExiste = _usuarios.values.any(
      (account) => _normalizar(account.email) == emailNormalizado,
    );
    if (emailExiste) {
      throw Exception('Ya existe un usuario registrado con ese correo.');
    }

    final rutExiste = _usuarios.values.any(
      (account) => _normalizar(account.rut) == rutNormalizado,
    );
    if (rutExiste) {
      throw Exception('Ya existe un usuario registrado con ese RUT.');
    }

    final key = _normalizar(usuario.username);
    _usuarios[key] = usuario;
    return usuario;
  }

  String _normalizar(String value) {
    return value.trim().toLowerCase();
  }
}
