# Guía de Integración y Pruebas en Desarrollo: SmartFarm IoT (ESP32 + Flutter)

Este documento detalla el funcionamiento de la integración entre la aplicación Flutter y el microcontrolador ESP32 DevKit V1 para la maqueta industrial de automatización pecuaria, explicando cómo probar el sistema en modo desarrollo paso a paso y cómo desplegar el sistema de forma gratuita a futuro.

---

## 1. Arquitectura de la Integración (Modo Desarrollo)

En el entorno de desarrollo, el ESP32 actúa como un **Servidor Web HTTP local** y crea su propio Punto de Acceso WiFi (Access Point). La aplicación Flutter actúa como cliente realizando peticiones HTTP/REST (peticiones GET) e interpretando respuestas en formato JSON.

```
┌─────────────────┐                 HTTP GET /status                ┌──────────────┐
│                 │ ──────────────────────────────────────────────> │              │
│ App Flutter     │ <────────────────────────────────────────────── │ ESP32 AP     │
│ (Smartphone/PC) │           JSON: {door, motion, water...}        │ (SoftAP)     │
│                 │                                                 │ 192.168.1.100│
│                 │   HTTP GET /openDoor /closeDoor /setMode ...    │              │
│                 │ ──────────────────────────────────────────────> │              │
└─────────────────┘                                                 └──────────────┘
```

### Tabla de Correspondencia Técnica de Endpoints

*   **`GET /status`**: Retorna el estado en tiempo real.
    *   *Ejemplo de Respuesta:* `{"door":"closed","motion":false,"water":"full","pump":false,"rssi":-45,"mode":"auto"}`
*   **`GET /openDoor`**: Comanda al servomotor SG90 acoplado al Pin 13 para moverse a `10°` (Puerta Abierta).
*   **`GET /closeDoor`**: Comanda al servomotor SG90 para moverse a `180°` (Puerta Cerrada).
*   **`GET /fillWater`**: Activa el `PIN_LED` (Pin 25) representando el encendido de la bomba de agua.
*   **`GET /emptyWater`**: Apaga el `PIN_LED` (Pin 25) apagando la bomba.
*   **`GET /setMode?mode=manual` o `mode=auto`**: Cambia la variable `modoOperacion` interna en el ESP32 para suspender o activar los ciclos automáticos locales basados en sensores físicos.

---

## 2. Cómo Probar en Modo Desarrollo (Paso a Paso)

### Paso 1: Preparación del ESP32
1. Abra el archivo [arduino.ino](file:///c:/Users/Samira/Downloads/smartfarm_flutter/arduino.ino) en el IDE de Arduino.
2. Asegúrese de tener instalada la biblioteca **ESP32Servo** (por Kevin Harrington) en el IDE de Arduino.
3. Conecte la placa ESP32 DevKit V1 al puerto USB de su computadora.
4. Seleccione la placa `DOIT ESP32 DEVKIT V1` y el puerto COM correcto.
5. Suba el código. En el Monitor Serie (115200 baudios), observará el mensaje de inicio del Punto de Acceso WiFi:
   `WiFi AP Iniciado. SSID: SmartFarm-AP, IP: 192.168.1.100`

### Paso 2: Conexión de Red
1. En su smartphone o computadora donde ejecutará la aplicación Flutter, abra la configuración de redes WiFi.
2. Conéctese a la red llamada **`SmartFarm-AP`** (es una red abierta sin contraseña).
3. Espere a que se asigne dirección IP (su dispositivo obtendrá una IP del rango `192.168.1.X`).

### Paso 3: Ejecución de la App Flutter
1. Desde su terminal en el directorio del proyecto, corra la aplicación:
   ```bash
   flutter run
   ```
2. La app iniciará y buscará al controlador en la IP predeterminada `http://192.168.1.100`.
3. Verifique en el **Dashboard** o en la pestaña **Monitoreo Técnico** que la tarjeta de conexión muestre "Operativo" y registre la latencia en milisegundos.

---

## 3. Control Detallado de Opciones desde la Interfaz

La pantalla **Control** (`lib/screens/control_screen.dart`) reaccionará de la siguiente forma según la opción seleccionada:

### A. Selector de Modo de Operación
*   **Automático (Auto):** El ESP32 tiene el control total físico. Si el sensor PIR detecta presencia, abrirá la puerta por 8 segundos y luego la cerrará. Si el flotador detecta nivel bajo de agua, encenderá la bomba automáticamente.
*   **Manual:** El ESP32 detiene las reglas locales físicas de automatización y espera las órdenes de la app Flutter.

### B. Módulo de Puerta (SG90)
*   **Botón "Abrir":** Envía `GET /openDoor`. El servo gira al ángulo abierto (`10°`). En pantalla, el estado cambia a "Abriendo..." y luego a "Abierta" una vez confirmada la lectura.
*   **Botón "Cerrar":** Envía `GET /closeDoor`. El servo gira al ángulo de cierre (`180°`).

### C. Módulo de Bebedero (Bomba / LED)
*   **Botón "Llenar":** Envía `GET /fillWater`. Activa el relé/transistor de la bomba (representado por el LED físico encendido).
*   **Botón "Vaciar":** Envía `GET /emptyWater`. Apaga el LED/bomba.

### D. Sensor de Presencia (PIR)
*   Muestra el estado físico en pantalla ("Movimiento detectado" o "Tranquilo"). Al simular movimiento cruzando una mano frente al PIR, la app generará de inmediato una notificación push en la pestaña **Notificaciones** y registrará la entrada de auditoría en la pestaña **Auditoría**.

---

## 4. Estrategia de Despliegue a Futuro Gratuito (Producción)

Dado que se ha restringido el uso de MQTT, WebSockets o servicios en la nube de pago, la mejor estrategia para controlar su corral de forma remota desde cualquier parte del mundo (fuera de la red local) de manera 100% gratuita es:

### Alternativa A: Servidor Seguro Túnel (Ngrok) - *Recomendado para Pruebas Remotas*
1. **Qué es:** Ngrok permite exponer el puerto local `80` del ESP32 a una URL pública cifrada `https` de forma gratuita.
2. **Cómo implementarlo:**
   - Puede conectar el ESP32 a la red WiFi del hogar (cambiando `softAP` por `WiFi.begin(ssid, password)` en el firmware).
   - Inicie un cliente local en su red doméstica (por ejemplo, una Raspberry Pi, una PC vieja o inclusive un script en la propia red local):
     ```bash
     ngrok http 192.168.1.100:80
     ```
   - Ngrok generará una URL aleatoria segura (Ej: `https://abcd-123.ngrok-free.app`).
   - Introduzca esa dirección en la configuración de la IP del Corral en la aplicación Flutter, y podrá controlarlo remotamente desde redes móviles.

### Alternativa B: DDNS Gratuito (DuckDNS) + Port Forwarding (Redirección de Puertos)
1. **Qué es:** Mapear su IP pública residencial a un subdominio gratuito e ingresar al router de su hogar para redireccionar el puerto de entrada.
2. **Cómo implementarlo:**
   - Configure una cuenta gratuita en [DuckDNS](https://www.duckdns.org/) (Ej: `mi-corral.duckdns.org`).
   - Configure el cliente DDNS gratuito en su router o configure el propio ESP32 para que actualice la IP pública en DuckDNS enviando una petición HTTP periódica.
   - En la página de administración de su router, configure un mapeo de puertos: redireccione el puerto externo `8080` (o similar) hacia el puerto local `80` en la IP privada estática del ESP32 (`192.168.1.100`).
   - En la aplicación Flutter, configure la IP/URL del corral con el valor: `http://mi-corral.duckdns.org:8080`.
