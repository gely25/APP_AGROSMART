# SmartFarm - Sistema Industrial de Monitoreo y Control IoT Pecuario

## Descripción

SmartFarm es una aplicación móvil de grado comercial desarrollada en Flutter para la administración, monitoreo técnico y control en tiempo real de corrales pecuarios automatizados. Mediante comunicación HTTP/REST con microcontroladores ESP32 y sensores embebidos, permite operar infraestructura crítica, gestionar automatizaciones y analizar diagnósticos de hardware directamente en el campo.

Este proyecto evolucionó desde una maqueta conceptual hacia un sistema completo con flujos lógicos comerciales, microinteracciones avanzadas y arquitectura de telemetría robusta.

---

## Nombre del Proyecto

SmartFarm - Sistema de Gestión Pecuaria Industrial

## Versión

1.0.0

## Plataforma Objetivo

Android (Soporte responsivo optimizado para móviles y tablets industriales)

---

## Arquitectura de Navegación y Pantallas

La aplicación consta de un flujo de navegación completo diseñado para entornos de producción agropecuaria:

1. **Splash Screen**: Pantalla de carga con animación de marca.
2. **Inicio de Sesión (Autenticado)**: Pantalla de login premium con credenciales de operador.
3. **Mis Corrales**: Panel de administración central que permite buscar, filtrar, agregar, editar y eliminar corrales. Muestra una vista previa de la telemetría, RSSI, firmware y disponibilidad de cada corral.
4. **Agregar Corral (Asistente de 5 pasos)**:
   - *Paso 1*: Información general y descripción.
   - *Paso 2*: Escaneo dinámico y búsqueda del ESP32 en red WiFi local con animación.
   - *Paso 3*: Despliegue de metadatos del dispositivo (MAC, IP, Firmware, RSSI).
   - *Paso 4*: Test de verificación de conexión en tiempo real de 4 etapas.
   - *Paso 5*: Confirmación y guardado del corral.
5. **Dashboard**: Centro de mando con **Centro de Decisiones** asistido por sugerencias automáticas, KPIs de actividad (aperturas, movimiento, nivel de agua, SLA), telemetría del ESP32 y gráficas minimalistas de consumo y presencia.
6. **Panel SCADA de Control**:
   - **Selector de Modo de Operación**: *Manual*, *Automático*, y *Human in the Loop (HITL)*.
   - **Puerta Inteligente**: Control de apertura/cierre, métricas de conteo de ciclos, tiempo de apertura y operario responsable.
   - **Sensor PIR**: Panel dinámico que alerta con bordes y banners rojos vibrantes ante la detección de movimiento, habilitando acciones rápidas (*Ignorar*, *Abrir puerta*, *Activar alarma*, *Registrar incidente*).
   - **Bebedero**: Nivel ultrasónico preciso, consumo estimado en litros, autonomía restante en horas y estado de la válvula solenoide. Soporte para aprobaciones interactivas en modo HITL.
7. **Monitoreo Técnico**: Panel de diagnóstico de hardware en tiempo real con semáforo físico de tres luces, métricas de CPU, RAM, temperatura del chip, estabilidad del enlace de red y voltajes.
8. **Auditoría**: Línea de tiempo cronológica de eventos del sistema que registra la acción, detalle, usuario ejecutor, origen (Manual, Auto, HITL, Sensor), duración y estado de éxito de cada proceso.
9. **Automatización**: Constructor de reglas condicionales "SI / ENTONCES" con interruptores independientes de HITL y planificador de horarios semanales.
10. **Centro de Notificaciones**: Bandeja dedicada para categorizar, filtrar y marcar como leídas las alertas críticas del sistema.
11. **Configuración**: Panel para gestionar alertas sonoras/vibración, actualizar firmware (simulado), reiniciar hardware y acceder a licencias y políticas de privacidad local de datos.

---

## Estructura de Carpetas

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
│   │   ├── login_screen.dart
│   │   ├── corrales_screen.dart
│   │   ├── agregar_corral_wizard.dart
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── control_screen.dart
│   │   ├── monitoring_screen.dart
│   │   ├── audit_screen.dart
│   │   ├── automation_screen.dart
│   │   ├── notifications_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── status_card.dart
│   │   ├── alarm_card.dart
│   │   └── connection_badge.dart
│   └── animations/
│       ├── door_animation.dart
│       ├── pir_sensor_animation.dart
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

## Dependencias Principales

| Paquete | Versión | Uso |
|---|---|---|
| provider | ^6.1.2 | Gestión de estado global y de simulación reactiva |
| http | ^1.2.1 | Comunicación HTTP/REST con el hardware ESP32 |
| google_fonts | ^6.2.1 | Tipografía profesional Inter |
| intl | ^0.19.0 | Localización, formateo de fechas y registros cronológicos |

---

## Configuración de la IP del ESP32

Para realizar la vinculación con el hardware físico, edite el archivo:

```
lib/services/esp32_service.dart
```

Modifique la dirección IP del dispositivo ESP32 asignada en su red local:

```dart
static String baseUrl = 'http://192.168.1.100';
```

---

## Compilación para Producción

Para generar el paquete instalable optimizado para dispositivos Android:

```bash
flutter build apk --release
```

El binario compilado estará ubicado en:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Repositorio

https://github.com/gely25/APP_AGROSMART

---

## Licencia y Privacidad
- **Licencia**: Licencia Comercial Propietaria. Todos los derechos reservados por SmartFarm Technologies.
- **Privacidad**: Toda la transmisión de datos se realiza de forma local dentro de la red del usuario (LAN). La aplicación no almacena registros en servidores de terceros externos.
