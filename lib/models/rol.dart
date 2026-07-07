//roles disponibles en el sistema, usados para el control de acceso.
//cada pantalla debe consultar el rol del usuario autenticado (a traves
//de Permisos) antes de habilitar funcionalidades internas.
enum Rol { usuario, funcionario, administrador }

extension RolExtension on Rol {
  String get etiqueta {
    switch (this) {
      case Rol.usuario:
        return 'Usuario/Ciudadano';
      case Rol.funcionario:
        return 'Funcionario';
      case Rol.administrador:
        return 'Administrador';
    }
  }
}