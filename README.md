# sistema_vacunacion

Sistema de vacunacion en Flutter para login, registro de usuarios y agendamiento de citas.

## Requisitos previos

- Flutter SDK instalado
- Dart SDK incluido con Flutter

## Ejecutar el proyecto

1. Abrir una terminal en la carpeta raiz del proyecto.
2. Descargar las dependencias:

```bash
flutter pub get
```

3. Verificar que Flutter detecta el entorno correctamente:

```bash
flutter doctor
```

4. Ejecutar la aplicacion:

```bash
flutter run
```

## Ejecutar en navegador web

para correr en web, primero habilitar la plataforma y luego ejecutar:

```bash
flutter config --enable-web
flutter run -d chrome
```

## Ejecutar el backend del servicio externo de notificaciones
Requiere node.js y npm configurado en el Path
1. Crear un archivo .env en la carpeta backend con la siguiente información
```bash
MAILERSEND_API_KEY=(AQUI VA API KEY DE MAILERSEND)
FROM_EMAIL=(AQUI VA EMAIL REMITENTE)
FROM_NAME=Vacunación
PORT=3000
```
2. Abrir una terminal en la misma carpeta
3. Instalar el servicio
```bash
npm install express
```
4. Ejecutar el servicio
```bash
npm start
```
## Credenciales de prueba

Usuario:

- Usuario, correo o RUT: `usuario`
- Contraseña: `vacuna2026`

Funcionario:

- Usuario, correo o RUT: `funcionario`
- Contraseña: `funcion2026`

Usuario:

- Usuario, correo o RUT: `administrador`
- Contraseña: `admin2026`
