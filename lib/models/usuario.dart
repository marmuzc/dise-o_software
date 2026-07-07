import 'rol.dart';

class Usuario {
  final String username;
  final String fullName;
  final String rut;
  final String email;
  final String cellPhone;
  final String password;
  final Rol rol;

  const Usuario({
    required this.username,
    required this.fullName,
    required this.rut,
    required this.email,
    required this.cellPhone,
    required this.password,
    required this.rol,
  });

  //permite crear una copia del usuario con el correo y/o celular
  //actualizados, sin perder el resto de los datos originales. Se usa
  //para que la persona pueda modificar sus datos de contacto desde
  //la ficha.
  Usuario copyWith({String? email, String? cellPhone}) {
    return Usuario(
      username: username,
      fullName: fullName,
      rut: rut,
      email: email ?? this.email,
      cellPhone: cellPhone ?? this.cellPhone,
      password: password,
      rol: rol,
    );
  }
}
