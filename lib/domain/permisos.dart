import '../models/rol.dart';

//Clase utilitaria que centraliza las reglas de control de acceso por
//rol (control de acceso por roles). Por ahora cubre los permisos que
//usan las pantallas ya existentes (ficha, historial y seguimiento de
//citas). Cuando se agreguen las pantallas de administracion (campanas,
//centros, avance de campana, padron de personas) este mismo archivo
//debe extenderse con esos permisos, en vez de repartir "if (rol == ...)"
//sueltos por toda la interfaz.

class Permisos {
  //el Usuario/Ciudadano solo puede ver su propia ficha, historial y
  //citas, para proteger los datos personales de las demas personas
  //usuarias. Funcionario y Administrador si pueden consultar los
  //datos de otras personas.
  static bool puedeConsultarDatosDeOtros(Rol rol) {
    return rol == Rol.funcionario || rol == Rol.administrador;
  }

  //registrar una vacunacion realizada es responsabilidad del
  //Funcionario segun el enunciado del proyecto.
  static bool puedeRegistrarVacunacion(Rol rol) {
    return rol == Rol.funcionario;
  }

  //gestionar citas de otras personas (asignar, reprogramar o cancelar
  //a nombre de otra persona) es tarea de Funcionario/Administrador.
  static bool puedeGestionarCitasDeOtros(Rol rol) {
    return rol == Rol.funcionario || rol == Rol.administrador;
  }

  //definir campañas de vacunación (nombre, descripción, fechas) es
  //responsabilidad exclusiva del Administrador, no del Funcionario.
  static bool puedeDefinirCampanas(Rol rol) {
    return rol == Rol.administrador;
  }

  //definir centros de vacunación (nombre, dirección, horarios) es
  //responsabilidad exclusiva del Administrador, no del Funcionario.
  static bool puedeGestionarPuntosVacunacion(Rol rol) {
    return rol == Rol.administrador;
  }
}
