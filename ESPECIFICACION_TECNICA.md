# Especificacion Tecnica - SmartFarm Flutter

## 1. Resumen del proyecto

SmartFarm es una aplicacion movil nativa Android desarrollada en Flutter 3.44.5. Fue migrada desde un prototipo de interfaz de usuario construido con React y Next.js usando el editor v0 de Vercel. La migracion conservo fielmente el diseno visual, colores, animaciones y experiencia de usuario del prototipo original.

---

## 2. Tecnologias implementadas

### 2.1 Flutter y Dart

- **Flutter 3.44.5** - Framework de desarrollo multiplataforma de Google.
- **Dart 3.12.2** - Lenguaje de programacion compilado a codigo nativo Android.
- **Material Design 3** - Sistema de diseno de Google implementado mediante `ThemeData` con `useMaterial3: true`.

Flutter permite compilar codigo Dart directamente a bytecode nativo ARM, lo que resulta en una aplicacion de alto rendimiento sin puente JavaScript como en React Native.

### 2.2 Provider (gestion de estado)

- **Paquete:** `provider: ^6.1.2`
- **Equivalente React:** Context API + useState + useEffect

El estado global de la aplicacion se gestiona mediante un `ChangeNotifier` llamado `FarmProvider`. Cuando el estado cambia, todos los widgets suscritos se reconstruyen automaticamente usando `Consumer<FarmProvider>`.

```dart
// Declaracion del provider en main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => FarmProvider()),
  ],
  child: const SmartFarmApp(),
)

// Consumo en cualquier widget
Consumer<FarmProvider>(
  builder: (_, provider, __) {
    final s = provider.state;
    return Text(s.connected ? 'Conectado' : 'Offline');
  },
)
```

### 2.3 HTTP (comunicacion IoT)

- **Paquete:** `http: ^1.2.1`
- **Proposito:** Enviar comandos y recibir el estado del ESP32 via peticiones GET sobre WiFi local.

El servicio `Esp32Service` encapsula todos los endpoints de la API REST del ESP32. Cada accion del usuario (abrir puerta, llenar agua, etc.) dispara una peticion GET al microcontrolador.

```dart
// Ejemplo de llamada HTTP
static Future<FarmState> getStatus() async {
  final response = await http.get(Uri.parse('$baseUrl/status'))
      .timeout(const Duration(seconds: 5));
  return _parseStatus(jsonDecode(response.body));
}
```

### 2.4 Google Fonts

- **Paquete:** `google_fonts: ^6.2.1`
- **Fuente usada:** Inter

La tipografia Inter fue seleccionada por ser identica a la fuente usada en el prototipo React original (`--font-inter` en globals.css).

### 2.5 intl (internacionalizacion)

- **Paquete:** `intl: ^0.19.0`
- **Uso:** Formateo de la fecha de ultima actualizacion en formato `HH:mm:ss`.

```dart
DateFormat('HH:mm:ss').format(s.lastUpdate)
```

---

## 3. Arquitectura del codigo

La arquitectura sigue el patron **Provider + Repository**, organizado en capas:

```
Presentacion (screens, widgets)
       |
Estado (providers)
       |
Servicios (services)
       |
Modelos (models)
```

### 3.1 Capa de modelos - `lib/models/`

**`farm_state.dart`** define la estructura de datos del sistema:

- Enums `DoorState`, `FeederState`, `WaterState` para representar estados discretos con seguridad de tipos.
- Clase `FarmState` inmutable con metodo `copyWith()` para actualizaciones parciales sin mutar el estado.
- Clase `FarmEvent` para el historial de eventos del corral.

```dart
enum DoorState { closed, open }
enum WaterState { empty, filling, full }

class FarmState {
  final bool connected;
  final DoorState doorState;
  final WaterState waterState;
  final DateTime lastUpdate;
  // ...
}
```

### 3.2 Capa de servicios - `lib/services/`

**`esp32_service.dart`** es una clase estatica que centraliza toda la comunicacion HTTP con el ESP32:

- Un unico campo estatico `baseUrl` configura la IP del microcontrolador.
- Metodo `getStatus()` convierte el JSON de respuesta en un objeto `FarmState`.
- Timeout de 5 segundos en cada peticion para no bloquear la UI si el ESP32 no responde.
- Todos los endpoints de control son peticiones GET simples segun la especificacion del firmware.

### 3.3 Capa de estado - `lib/providers/`

**`farm_provider.dart`** extiende `ChangeNotifier` y replica la logica del `SmartFarmProvider` de React:

- Inicializa el estado con valores por defecto al arrancar la aplicacion.
- Lanza un `Timer.periodic` cada 5 segundos para simular el refresco del sensor de presencia animal (en modo demo sin ESP32 real).
- El metodo `fillWater()` lanza un `Timer` de 2600 ms para simular la transicion automatica de `filling` a `full`, igual que el `setTimeout` del prototipo React.
- Llama a `notifyListeners()` despues de cada cambio de estado para disparar la reconstruccion de los widgets.

### 3.4 Capa de tema - `lib/theme/`

**`app_theme.dart`** centraliza toda la identidad visual:

- La clase `AppColors` define constantes de color extraidas de las variables CSS del archivo `globals.css` del prototipo React, convirtiendo valores OKLCH a RGB hexadecimal.
- La clase `AppTheme` construye un `ThemeData` de Material Design 3 con el `ColorScheme` completo, estilos de botones, cards, AppBar y BottomNavigationBar.

Ejemplo de conversion de color:
```
React:  --primary: oklch(0.52 0.12 150)
Flutter: static const Color primary = Color(0xFF3D8B5E);
```

### 3.5 Animaciones - `lib/animations/`

Las tres animaciones de los modulos de control son los componentes mas complejos. Todas usan `AnimationController` con `SingleTickerProviderStateMixin`.

**`door_animation.dart` - Puerta automatica**

La animacion de apertura de puerta en el prototipo React usaba CSS `transform: rotateY(-88deg)` con `transformStyle: preserve-3d`. En Flutter se replica usando `Transform` con `Matrix4`:

```dart
Transform(
  alignment: Alignment.centerLeft,
  transform: Matrix4.identity()
    ..setEntry(3, 2, 0.001) // perspectiva
    ..rotateY(_angle.value),   // rotacion de bisagra
  child: const _Gate(),
)
```

- La animacion pasa por las fases: `closed → opening → open → closing → closed`.
- La sombra de la puerta en el suelo se anima con `Transform.scale` en el eje X.
- La duracion es de 1000 ms con curva `Curves.easeInOut`.

**`feeder_animation.dart` - Comedero inteligente**

La tapa del comedero usa `Matrix4.rotateX` para simular la apertura en perspectiva:

```dart
Transform(
  alignment: Alignment.bottomCenter,
  transform: Matrix4.identity()
    ..setEntry(3, 2, 0.001)
    ..rotateX(_lidAngle.value), // -1.26 radianes = 72 grados
  child: _Lid(),
)
```

- Mientras la tapa se abre, aparece un stream de grano animado con `AnimatedOpacity`.
- El comedero inferior muestra los pellets con `AnimatedSlide` al abrirse.

**`water_animation.dart` - Bebedero inteligente**

El nivel de agua se anima con `AnimationController` que controla la altura del contenedor:

```dart
AnimationController _levelCtrl; // 0.0 a 1.0
// nivel: 0.04 = vacio, 0.50 = llenandose, 0.82 = lleno
```

- La valvula de suministro usa `AnimatedRotation` mientras el estado es `filling`.
- Las burbujas son instancias de `_Bubble` con `AnimationController` independiente y delay escalonado.

### 3.6 Widgets base - `lib/widgets/`

**`status_card.dart`**
Tarjeta reutilizable con cuatro tonos de estado (`success`, `alert`, `info`, `neutral`). Usa `AnimatedContainer` para transiciones suaves de color al cambiar de estado.

**`alarm_card.dart`**
Tarjeta de alarma con dos modos visuales. Cuando la alarma esta activa:
- El fondo cambia a rojo con un `BoxShadow` animado que pulsa.
- El icono de campana oscila con `AnimationController` usando `rotateY` entre -0.22 y +0.22 radianes.

**`realtime_row.dart`**
Fila de la pantalla de tiempo real con punto indicador pulsante. Cuando el valor cambia, aplica un flash de fondo azul usando `AnimatedContainer`.

**`connection_badge.dart`**
Badge de conexion del encabezado. Usa `AnimatedContainer` para transicion suave entre estado conectado (verde) y desconectado (rojo).

### 3.7 Pantallas - `lib/screens/`

**`splash_screen.dart`**
- Logo con `ScaleTransition` desde 0.6 hasta 1.0 en 600 ms (replica `animate-[pop_600ms]` de React).
- Tres puntos de carga con `AnimationController` independiente cada uno, con delay escalonado de 150 ms entre si.
- Navegacion automatica a `HomeScreen` a los 2200 ms mediante `Timer`.

**`home_screen.dart`**
- Shell principal con `AppBar` personalizado (sin el widget por defecto).
- Navegacion inferior construida manualmente con `GestureDetector` y `AnimatedContainer` para el pill del item activo.
- `IndexedStack` para preservar el estado de cada pantalla al cambiar de tab, identico al comportamiento del prototipo React.

**`dashboard_screen.dart`**
- Imagen hero del corral con `Stack` y gradiente superpuesto.
- Grid de 6 `StatusCard` en `GridView.count` con 2 columnas.

**`control_screen.dart`**
- Tres modulos de control (`_ControlModule`) en columna, cada uno con cabecera, animacion, y botones de accion.
- La `AlarmCard` aparece siempre en la parte superior.

**`realtime_screen.dart`**
- Banner de sincronizacion con icono `sensors_rounded` pulsante.
- Lista de `RealtimeRow` dentro de un `Container` con bordes redondeados y divisores.
- Boton de simulacion de alarma visible solo cuando la alarma no esta activa (modo demo).

**`info_screen.dart`**
- Tarjeta central con logo, nombre de la aplicacion y numero de version.
- Cuatro bloques de informacion: descripcion, universidad, integrantes y tecnologias.
- Chips de tecnologias usando `Wrap` con icono y etiqueta.

---

## 4. Flujo de datos

```
Usuario toca boton "Abrir puerta"
        |
FarmProvider.openDoor()
        |
[Modo demo] Estado local: doorState = DoorState.open
[Modo real] Esp32Service.openDoor() -> GET /openDoor -> ESP32
        |
notifyListeners()
        |
Consumer<FarmProvider> reconstruye DoorAnimation
        |
AnimationController.forward() -> rotacion de puerta 0 -> -1.52 rad
```

---

## 5. Modo demo vs modo real ESP32

La aplicacion funciona en dos modos sin necesidad de cambiar codigo:

| Modo | Descripcion |
|---|---|
| Demo | FarmProvider simula el estado localmente. No requiere ESP32. Util para demostraciones y desarrollo. |
| Real | Esp32Service envia peticiones HTTP reales. Requiere ESP32 en la misma red WiFi con la IP configurada. |

Para activar el modo real, unicamente se necesita que el ESP32 este encendido y conectado a la misma red WiFi que el telefono Android.

---

## 6. Compilacion y despliegue

### Debug (desarrollo con hot reload)
```bash
flutter run
```

### Release (APK instalable)
```bash
flutter build apk --release
```

### Ubicacion del APK generado
```
build/app/outputs/flutter-apk/app-release.apk
```

### Peso del APK generado
48.0 MB (incluye engine Flutter, assets e iconos tree-shaken)
