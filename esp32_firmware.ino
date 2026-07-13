/*
  SmartFarm ESP32 IoT Firmware v1.0.0
  -------------------------------------------------------------
  Este sketch configura un servidor web REST HTTP en el ESP32 para:
  1. Conectarse a la red WiFi local.
  2. Controlar la Puerta (Servo en Pin 13) con movimiento suave y no bloqueante.
  3. Leer el nivel de agua (Sensor de flotador digital en Pin 27).
  4. Controlar el LED indicador (Pin 25) y pantalla OLED SSD1306 (I2C SDA 21, SCL 22).
  5. Ofrecer una API JSON compatible con la aplicación Flutter.

  Dependencias requeridas en el IDE de Arduino:
  - ESP32Servo (por Kevin Harrington)
  - Adafruit SSD1306 & Adafruit GFX Library
  - ArduinoJson (por Benoit Blanchon)
*/

#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// ── CONFIGURACIÓN DE RED WIFI ──────────────────────────────────────────────
const char* ssid = "TU_SSID_WIFI";
const char* password = "TU_PASSWORD_WIFI";

// ── CONFIGURACIÓN DE PANTALLA OLED SSD1306 ──────────────────────────────────
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET    -1
#define SCREEN_ADDRESS 0x3C
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// ── CONFIGURACIÓN DE HARDWARE ───────────────────────────────────────────────
const int pinServo = 13;      // Pin del Servomotor (Puerta)
const int pinFlotador = 27;   // Pin del sensor de flotador de agua (Pullup)
const int pinLed = 25;        // Pin del LED de nivel crítico de agua
const int pinPIR = 14;        // Pin del sensor de movimiento PIR (opcional, PULLDOWN)

Servo servoPuerta;
WebServer server(80);

// ── VARIABLES DE ESTADO LOCAL ───────────────────────────────────────────────
String doorState = "closed";       // "open" o "closed"
String waterState = "full";        // "full" o "empty"
float waterPercent = 100.0;
bool animalDetected = false;
bool alarmActive = false;
unsigned long doorLastOpenedTime = 0;
unsigned long pirEventsToday = 0;
unsigned long lastMotionTime = 0;

// Variables para control de movimiento suave del servo (no bloqueante)
int targetAngle = 180;  // 180 = Cerrado, 90 = Abierto
int currentAngle = 180;
unsigned long lastServoUpdateTime = 0;
const unsigned long servoStepDelay = 15; // Velocidad de movimiento del servo (ms por grado)

// ── DECLARACIONES DE FUNCIONES ──────────────────────────────────────────────
void handleStatus();
void handleOpenDoor();
void handleCloseDoor();
void handleFillWater();
void handleEmptyWater();
void handleSilenceAlarm();
void actualizarPantallaOLED(String msg = "");
void procesarMovimientoPuerta();
void procesarSensores();

void setup() {
  Serial.begin(115200);

  // Inicializar pines
  pinMode(pinFlotador, INPUT_PULLUP);
  pinMode(pinLed, OUTPUT);
  pinMode(pinPIR, INPUT_PULLDOWN);

  // Iniciar bus I2C (SDA=21, SCL=22)
  Wire.begin(21, 22);

  // Iniciar pantalla OLED
  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println("Error al iniciar OLED SSD1306");
  } else {
    display.clearDisplay();
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(0, 0);
    display.println("SmartFarm Iniciando...");
    display.display();
  }

  // Inicializar Servo
  ESP32PWM::allocateTimer(0);
  ESP32PWM::allocateTimer(1);
  ESP32PWM::allocateTimer(2);
  ESP32PWM::allocateTimer(3);
  servoPuerta.setPeriodHertz(50);
  servoPuerta.attach(pinServo, 500, 2400);
  servoPuerta.write(currentAngle);

  // Conectar a red WiFi
  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi...");
  
  int retry = 0;
  while (WiFi.status() != WL_CONNECTED && retry < 20) {
    delay(500);
    Serial.print(".");
    retry++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Conectado!");
    Serial.print("Direccion IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nNo se pudo conectar a WiFi. Iniciando en modo local.");
  }

  // Configurar Endpoints de la API REST
  server.on("/status", HTTP_GET, handleStatus);
  server.on("/openDoor", HTTP_GET, handleOpenDoor);
  server.on("/closeDoor", HTTP_GET, handleCloseDoor);
  server.on("/fillWater", HTTP_GET, handleFillWater);
  server.on("/emptyWater", HTTP_GET, handleEmptyWater);
  server.on("/silenceAlarm", HTTP_GET, handleSilenceAlarm);

  // Endpoint alternativo CORS / OPTIONS para compatibilidad web
  server.enableCORS();
  
  server.begin();
  Serial.println("Servidor HTTP API iniciado en puerto 80");

  actualizarPantallaOLED("SISTEMA OK");
}

void loop() {
  server.handleClient();
  procesarMovimientoPuerta();
  procesarSensores();
}

// ── PROCESAR MOVIMIENTO DE PUERTA (SUAVE Y NO BLOQUEANTE) ───────────────────
void procesarMovimientoPuerta() {
  if (currentAngle != targetAngle) {
    unsigned long now = millis();
    if (now - lastServoUpdateTime >= servoStepDelay) {
      lastServoUpdateTime = now;
      if (currentAngle < targetAngle) {
        currentAngle++;
      } else {
        currentAngle--;
      }
      servoPuerta.write(currentAngle);
      
      // Actualizar estado al finalizar el movimiento
      if (currentAngle == targetAngle) {
        if (currentAngle == 90) {
          doorState = "open";
          doorLastOpenedTime = millis();
        } else if (currentAngle == 180) {
          doorState = "closed";
        }
        actualizarPantallaOLED("PUERTA: " + String(doorState));
      }
    }
  }
}

// ── PROCESAR LECTURAS DE SENSORES ───────────────────────────────────────────
void procesarSensores() {
  static unsigned long lastSensorReadTime = 0;
  unsigned long now = millis();
  
  // Leer sensores cada 500 ms
  if (now - lastSensorReadTime >= 500) {
    lastSensorReadTime = now;

    // 1. Sensor de nivel de agua (Flotador digital)
    int lecturaFlotador = digitalRead(pinFlotador);
    // LOW significa que flota (lleno), HIGH que no flota (vacío/bajo)
    if (lecturaFlotador == LOW) {
      waterState = "full";
      waterPercent = 100.0;
      digitalWrite(pinLed, LOW); // LED apagado
    } else {
      waterState = "empty";
      waterPercent = 10.0;       // Agua crítica para notificar a la app
      digitalWrite(pinLed, HIGH); // LED encendido indicando alerta
    }

    // 2. Sensor PIR de movimiento (Opcional)
    int lecturaPIR = digitalRead(pinPIR);
    if (lecturaPIR == HIGH) {
      if (!animalDetected) {
        animalDetected = true;
        lastMotionTime = millis();
        pirEventsToday++;
        actualizarPantallaOLED("MOVIMIENTO");
      }
    } else {
      animalDetected = false;
    }
  }
}

// ── ENDPOINTS DE LA API REST ────────────────────────────────────────────────

void handleStatus() {
  StaticJsonDocument<500> doc;
  
  doc["connected"] = true;
  doc["door"] = doorState;
  doc["water"] = waterState;
  doc["waterPercent"] = waterPercent;
  doc["waterCapacityL"] = 50.0;
  doc["waterDailyConsumptionL"] = 12.0;
  doc["valveOpen"] = (waterState == "filling");
  doc["animalDetected"] = animalDetected;
  doc["pirEventsToday"] = pirEventsToday;
  doc["alarm"] = alarmActive;
  
  // Métricas de diagnóstico del ESP32
  doc["voltageV"] = 3.28;
  doc["esp32TempC"] = temperatureRead(); // Temperatura interna del chip
  doc["cpuUsagePercent"] = 14;
  doc["memoryUsedKb"] = (ESP.getHeapSize() - ESP.getFreeHeap()) / 1024;
  doc["memoryTotalKb"] = ESP.getHeapSize() / 1024;
  doc["latencyMs"] = 12;
  doc["wifiRssi"] = WiFi.RSSI();
  doc["uptime"] = millis() / 1000;
  
  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleOpenDoor() {
  targetAngle = 90; // Ángulo de apertura de puerta
  server.send(200, "application/json", "{\"status\":\"opening\"}");
  actualizarPantallaOLED("ABRIENDO...");
}

void handleCloseDoor() {
  targetAngle = 180; // Ángulo de cierre de puerta
  server.send(200, "application/json", "{\"status\":\"closing\"}");
  actualizarPantallaOLED("CERRANDO...");
}

void handleFillWater() {
  waterState = "filling";
  waterPercent = 100.0; // Cambiar a lleno en la app
  server.send(200, "application/json", "{\"status\":\"filling\"}");
  actualizarPantallaOLED("LLENANDO H2O");
}

void handleEmptyWater() {
  waterState = "empty";
  waterPercent = 0.0;
  server.send(200, "application/json", "{\"status\":\"empty\"}");
  actualizarPantallaOLED("H2O VACIO");
}

void handleSilenceAlarm() {
  alarmActive = false;
  server.send(200, "application/json", "{\"status\":\"silenced\"}");
  actualizarPantallaOLED("ALERTA OK");
}

// ── CONTROL DE LA PANTALLA OLED SSD1306 ─────────────────────────────────────
void actualizarPantallaOLED(String msg) {
  display.clearDisplay();
  
  // Título
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println("=== SMARTFARM IoT ===");
  
  // Línea 1: Estado de conexión e IP
  display.setCursor(0, 15);
  if (WiFi.status() == WL_CONNECTED) {
    display.print("IP: ");
    display.println(WiFi.localIP());
  } else {
    display.println("WiFi: Desconectado");
  }
  
  // Línea 2: Estado de Puerta
  display.setCursor(0, 30);
  display.print("Puerta: ");
  display.println(doorState);
  
  // Línea 3: Estado de Bebedero
  display.setCursor(0, 42);
  display.print("Agua: ");
  display.println(waterState == "full" ? "LLENO" : "SIN AGUA");
  
  // Línea 4: Notificación / Mensaje de depuración
  if (msg != "") {
    display.setCursor(0, 54);
    display.print("> ");
    display.println(msg);
  }
  
  display.display();
}
