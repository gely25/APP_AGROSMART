# SmartFarm - Corral Pecuario Inteligente

## Descripcion

SmartFarm es una aplicacion movil desarrollada en Flutter para el monitoreo y control en tiempo real de un corral pecuario automatizado. La aplicacion permite operar la puerta principal, el comedero y el bebedero del corral, ademas de recibir alertas del sistema mediante un microcontrolador ESP32 conectado por red WiFi.

Este proyecto es el resultado de la migracion de un prototipo de interfaz de usuario desarrollado en React/Next.js hacia una aplicacion movil nativa Android compilada con Flutter.

---

## Nombre del proyecto

SmartFarm - Corral Pecuario Inteligente

## Version

1.0.0

## Plataforma objetivo

Android

---

## Funcionalidades principales

- Visualizacion del estado de conexion con el ESP32
- Control de puerta automatica con animacion de apertura y cierre
- Control de comedero inteligente con animacion de tapa y flujo de alimento
- Control de bebedero inteligente con animacion de nivel de agua
- Sistema de alarma automatica recibida desde el ESP32
- Pantalla de monitoreo en tiempo real con actualizacion cada 5 segundos
- Historial de eventos del sistema
- Informacion del proyecto y tecnologias utilizadas

---

## Estructura de carpetas

```
smartfarm_flutter/
├── lib/
│   ├── main.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── models/
│   │   └── farm_state.dart
│   ├── services/
│   │   └── esp32_service.dart
│   ├── providers/
│   │   └── farm_provider.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── control_screen.dart
│   │   ├── realtime_screen.dart
│   │   └── info_screen.dart
│   ├── widgets/
│   │   ├── status_card.dart
│   │   ├── alarm_card.dart
│   │   ├── realtime_row.dart
│   │   └── connection_badge.dart
│   └── animations/
│       ├── door_animation.dart
│       ├── feeder_animation.dart
│       └── water_animation.dart
├── assets/
│   └── images/
│       ├── smartfarm_logo.png
│       ├── corral_illustration.png
│       └── splash_bg.png
├── android/
├── pubspec.yaml
└── test/
    └── widget_test.dart
```

---

## Dependencias principales

| Paquete | Version | Uso |
|---|---|---|
| provider | ^6.1.2 | Gestion de estado global |
| http | ^1.2.1 | Comunicacion HTTP con ESP32 |
| google_fonts | ^6.2.1 | Tipografia Inter |
| intl | ^0.19.0 | Formateo de fechas y horas |

---

## Configuracion de la IP del ESP32

Antes de conectar la aplicacion con el hardware real, editar el archivo:

```
lib/services/esp32_service.dart
```

Cambiar la siguiente linea con la IP del ESP32 en la red WiFi local:

```dart
static String baseUrl = 'http://192.168.1.100';
```

---

## Compilar APK

```bash
flutter build apk --release
```

El archivo generado se encuentra en:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Repositorio

https://github.com/gely25/APP_AGROSMART

---

## Proyecto academico

Universidad - Ingenieria
Proyecto IoT - Corral Pecuario Inteligente
