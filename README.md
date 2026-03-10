# Moments! - Álbumes de Recuerdos Compartidos

**Moments!** es una aplicación móvil diseñada para capturar y compartir recuerdos grupales de manera organizada mediante **álbumes digitales geolocalizados**.  
Los usuarios pueden crear eventos, invitar a otros mediante **claves privadas** y colaborar subiendo **fotografías en tiempo real**.

---

# Tecnologías y Librerías

El proyecto está construido con el ecosistema de **Flutter**, priorizando la eficiencia y una experiencia de usuario fluida.

## Core

- **Framework:** Flutter (Lenguaje **Dart**)
- **Gestión de Estado:** Provider para el manejo de sesiones de usuario y notificaciones globales
- **Persistencia de Datos:** sqflite (**SQLite**) para el almacenamiento local de usuarios, álbumes y fotos

## Librerías Clave

- **Mapas:** `flutter_map` con datos de **OpenStreetMap** para una solución de geolocalización gratuita
- **Imágenes:** `image_picker` para la selección de fotos desde la galería o cámara
- **Geometría:** `latlong2` para el manejo de coordenadas geográficas

---

# Roles de Usuario y Permisos

## Super Administrador
- Tiene visibilidad total de los álbumes en la plataforma
- Permisos de gestión global

## Usuario / Creador
- Puede crear sus propios álbumes
- Gestionar miembros
- Editar la información del evento

## Miembro
- Accede a álbumes existentes mediante una clave
- Visualiza la galería
- Puede subir sus propias fotos

---

# Funcionalidades Principales

## Perfil Dinámico
Edición de datos personales y carga de foto de perfil con persistencia local.

## Creación de Álbumes
Formulario completo que incluye:
- Título
- Fecha del evento
- Dirección
- Ubicación interactiva en el mapa

## Seguridad por Claves
Acceso restringido a álbumes mediante **títulos y claves privadas**.

## Galería Colaborativa
- Visualización de fotos en **cuadrícula de 3 columnas**
- Soporte para **vista ampliada a pantalla completa**

## Geolocalización
Integración de mapas que muestran la **ubicación exacta** de cada momento compartido.

---

# Estructura del Proyecto

```
lib/
├── models/
├── services/
│   ├── database.dart
│   └── notifier.dart
├── pages/
└── routes.dart
```

---

# Fragmentos Clave

## Tabla relacional

```dart
await db.execute('''
CREATE TABLE usuario_album (
  usuario_id INTEGER,
  album_id INTEGER,
  PRIMARY KEY (usuario_id, album_id)
)
''');
```

## OpenStreetMap

```dart
TileLayer(
  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
  userAgentPackageName: 'com.example.app',
)
```

---

# Ejecutar el proyecto

## Dependencias
```
flutter pub get
```

## Limpiar build
```
flutter clean
```

## Ejecutar
```
flutter run
```

---

# Diseño UI

Paleta:
`Color.fromARGB(255,255,242,221)`

Componentes:
- BorderRadius.circular(30)
- Tarjetas con elevación
