import '../models/rol.dart';
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
      rol: Rol.usuario,
    ),
    'funcionario': Usuario(
      username: 'funcionario',
      fullName: 'Pedro Soto',
      rut: '22.222.222-2',
      email: 'funcionario@vacunacion.cl',
      cellPhone: '922345678',
      password: 'funcion2026',
      rol: Rol.funcionario,
    ),
    'administrador': Usuario(
      username: 'administrador',
      fullName: 'Ana Rojas',
      rut: '33.333.333-3',
      email: 'admin.sistema@vacunacion.cl',
      cellPhone: '932345678',
      password: 'admin2026',
      rol: Rol.administrador,
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

  //busca una persona usuaria registrada por username, correo, rut
  //o nombre completo, sin exigir contrasena. Se usa para que
  //Funcionario/Administrador puedan consultar la ficha de una persona.
  //Quien llama a este metodo debe validar antes, con Permisos, que el
  //rol del usuario autenticado tenga permiso para consultar a otros.
  Usuario? buscarUsuario(String query) {
    final valorBuscado = _normalizar(query);
    if (valorBuscado.isEmpty) {
      return null;
    }

    for (final account in _usuarios.values) {
      final coincide = _normalizar(account.username) == valorBuscado ||
          _normalizar(account.email) == valorBuscado ||
          _normalizar(account.rut) == valorBuscado ||
          _normalizar(account.fullName) == valorBuscado;

      if (coincide) {
        return account;
      }
    }

    return null;
  }

  //el autoregistro desde la pantalla de login siempre crea una cuenta
  //con rol Usuario/Ciudadano. Las cuentas de Funcionario y
  //Administrador se aprovisionan aparte (no son autoregistrables),
  //para que el ingreso de personal autorizado no dependa de un
  //formulario publico.
  //actualiza el correo y celular de una persona usuaria ya
  //registrada, usado desde la ficha para modificar sus datos de
  //contacto. Se busca por username (que no cambia aunque cambie el
  //correo) y se valida que el nuevo correo no este siendo usado por
  //otra persona.
  Usuario actualizarContacto({
    required String username,
    required String nuevoCorreo,
    required String nuevoCelular,
  }) {
    final key = _normalizar(username);
    final actual = _usuarios[key];
    if (actual == null) {
      throw Exception('No se encontro la persona usuaria.');
    }

    final correo = nuevoCorreo.trim();
    if (correo.isEmpty || !correo.contains('@') || !correo.contains('.')) {
      throw Exception('Ingresa un correo valido.');
    }

    final celular = nuevoCelular.trim();
    final digitos = celular.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length < 8 || digitos.length > 15) {
      throw Exception('Ingresa un numero de celular valido.');
    }

    final correoNormalizado = _normalizar(correo);
    final correoUsadoPorOtro = _usuarios.entries.any(
      (entry) =>
          entry.key != key &&
          _normalizar(entry.value.email) == correoNormalizado,
    );
    if (correoUsadoPorOtro) {
      throw Exception('Ese correo ya esta siendo usado por otra persona.');
    }

    final actualizado = actual.copyWith(email: correo, cellPhone: celular);
    _usuarios[key] = actualizado;
    return actualizado;
  }

  Usuario registrarUsuario({
    required String fullName,
    required String rut,
    required String email,
    required String cellPhone,
    required String password,
  }) {
    final nuevo = Usuario(
      username: _normalizar(email),
      fullName: fullName.trim(),
      rut: rut.trim(),
      email: email.trim(),
      cellPhone: cellPhone.trim(),
      password: password,
      rol: Rol.usuario,
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
