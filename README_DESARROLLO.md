# SmartFarm - Guía de Ejecución en Desarrollo (IoT & Mobile)

Este documento detalla los pasos para ejecutar la aplicación móvil **SmartFarm** en modo desarrollo sincronizada con el firmware ESP32 actual, integrando las últimas optimizaciones físicas y lógicas del hardware real.

---

## 🛠️ Arquitectura Física del Proyecto

La aplicación interactúa con un hardware simplificado en el ESP32:
* **Sensor de nivel (Boya/Flotador):** Dos estados discretos: `LLENO` / `SIN AGUA`.
* **Servomotor de puerta:** Controlado dinámicamente mediante los endpoints `/openDoor` y `/closeDoor`.
* **Bomba de Agua (USB externa):** Alimentada por conexión directa USB. **No** se controla desde el ESP32.

---

## 🚀 Requisitos Previos

1. **Flutter SDK:** Asegúrate de tener instalado Flutter en su versión estable.
2. **Dispositivo/Emulador:** Un teléfono Android conectado con la depuración USB activa o un emulador en ejecución.
3. **Red WiFi Común:** El dispositivo móvil y el ESP32 deben estar conectados a la misma red local para comunicarse vía HTTP.

---

## 📦 Configuración Inicial

Antes de correr el proyecto, instala las dependencias (incluyendo las librerías del generador de íconos adaptativos):

```bash
flutter pub get
```

---

## ⚡ Ejecución en Desarrollo

Para compilar y arrancar la aplicación móvil en tu terminal o IDE:

```bash
flutter run
```

### Comandos útiles en consola durante la ejecución:
* Press **`r`**: Hot Reload (aplica cambios de interfaz instantáneos).
* Press **`R`**: Hot Restart (reinicia el estado global de la app).
* Press **`q`**: Detiene y cierra la aplicación.

---

## 🎨 Ajustes Clave del Sistema Integrados

### 1. Parámetros e IP Dinámica (Ajustes)
* Puedes cambiar la dirección IP del ESP32 en tiempo real desde la pestaña de **Ajustes** (presionando el botón engranaje en la esquina superior derecha del Dashboard).
* La aplicación reconfigurará la URL de peticiones HTTP instantáneamente sin requerir reiniciar.

### 2. Control de Puerta Inteligente y Seguro
* La interfaz móvil deshabilita los botones de forma inteligente para evitar peticiones HTTP innecesarias al ESP32:
  * Si el estado es `Abierta`, el botón **Abrir** estará deshabilitado.
  * Si el estado es `Cerrada`, el botón **Cerrar** estará deshabilitado.

### 3. Programación Horaria Local Activa
* Las tareas programadas (`Abrir puerta` o `Cerrar puerta`) se ejecutan contrastando el reloj del teléfono en tiempo real con las programaciones.
* Al ejecutarse un horario, recibirás una **notificación nativa en el dispositivo** (`⏰ Horario cumplido: Se abrió la puerta para cumplir con el horario establecido`) y se almacenará en el historial.

### 4. Datos Reales Sin Simulación
* Eliminadas métricas estimadas o inventadas (porcentajes intermedios, litros consumidos y eventos estimados). El bebedero reporta fielmente el estado binario del sensor flotador del corral.

---

## 🔧 Generación del Ícono de la App (Opcional)

Si cambias la imagen base en `assets/icons/app_icon.png`, puedes regenerar los recursos del instalador usando:

```bash
dart run flutter_launcher_icons
```
