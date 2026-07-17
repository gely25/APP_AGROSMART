#include <ESP32Servo.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <WiFi.h>
#include <WebServer.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
#define SCREEN_ADDRESS 0x3C

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
Servo servoPuerta;
WebServer server(80);

//-------------------- Pines --------------------
const int PIN_SERVO = 13;
const int PIN_FLOTADOR = 27;
const int PIN_LED = 25;
const int PIN_PIR = 26;

//--------------- Ángulos puerta ----------------
const int PUERTA_CERRADA = 180;
const int PUERTA_ABIERTA = 10;

//--------------- Variables ---------------------
bool puertaAbierta = false;
String estadoPuerta = "CERRADA";
String estadoAgua = "LLENO";
String estadoMovimiento = "NO";
String modoOperacion = "auto"; // "auto" o "manual"

unsigned long tiempoPuerta = 0;
const unsigned long TIEMPO_ABIERTA = 8000;

// Configuración de Red WiFi (Estación - Conectarse a router)
const char* ssid_router = "TU_SSID_WIFI";
const char* password_router = "TU_PASSWORD_WIFI";

// Configuración de Red WiFi AP (Fallback / Punto de Acceso)
const char* ssid_ap = "SmartFarm-AP";
const char* password_ap = "";
IPAddress local_ip(192, 168, 1, 100);
IPAddress gateway(192, 168, 1, 1);
IPAddress subnet(255, 255, 255, 0);

void abrirPuerta();
void cerrarPuerta();
void actualizarPantalla();
void handleStatus();
void handleOpenDoor();
void handleCloseDoor();
void handleFillWater();
void handleEmptyWater();
void handleSetMode();

void setup() {
  Serial.begin(115200);
  Wire.begin(21, 22);

  pinMode(PIN_FLOTADOR, INPUT_PULLUP);
  pinMode(PIN_LED, OUTPUT);
  pinMode(PIN_PIR, INPUT);

  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println("Error OLED");
    while (true);
  }

  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);

  servoPuerta.setPeriodHertz(50);
  servoPuerta.attach(PIN_SERVO);
  servoPuerta.write(PUERTA_CERRADA);
  puertaAbierta = false;
  estadoPuerta = "CERRADA";

  // Intentar conectar a la red WiFi del router
  WiFi.begin(ssid_router, password_router);
  Serial.print("Conectando a WiFi ");
  Serial.println(ssid_router);

  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println("Conectando WiFi...");
  display.println(ssid_router);
  display.display();

  int intentos = 0;
  while (WiFi.status() != WL_CONNECTED && intentos < 20) {
    delay(500);
    Serial.print(".");
    intentos++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nConectado a WiFi");
    Serial.print("IP: ");
    Serial.println(WiFi.localIP());

    display.clearDisplay();
    display.setCursor(0, 0);
    display.println("WiFi Conectado!");
    display.print("IP: ");
    display.println(WiFi.localIP().toString());
    display.display();
    delay(3000);
  } else {
    // Fallback a modo Access Point si no se conecta
    Serial.println("\nFallo conexion WiFi. Iniciando AP...");
    WiFi.disconnect();
    WiFi.softAPConfig(local_ip, gateway, subnet);
    WiFi.softAP(ssid_ap, password_ap);

    display.clearDisplay();
    display.setCursor(0, 0);
    display.println("Fallo WiFi Router.");
    display.println("Iniciando AP:");
    display.println(ssid_ap);
    display.println("IP: 192.168.1.100");
    display.display();
    delay(3000);
  }

  // Configurar rutas del Servidor Web
  server.on("/status", HTTP_GET, handleStatus);
  server.on("/openDoor", HTTP_GET, handleOpenDoor);
  server.on("/closeDoor", HTTP_GET, handleCloseDoor);
  server.on("/fillWater", HTTP_GET, handleFillWater);
  server.on("/emptyWater", HTTP_GET, handleEmptyWater);
  server.on("/setMode", HTTP_GET, handleSetMode);
  server.begin();
  Serial.println("Servidor HTTP iniciado");

  Serial.println("Esperando PIR...");
  delay(30000);

  actualizarPantalla();
  Serial.println("Sistema listo");
}

void loop() {
  server.handleClient();

  //---------------- PIR y Flotador ------------------
  // LOW = hay movimiento (PIR), HIGH = no hay movimiento
  bool movimiento = (digitalRead(PIN_PIR) == LOW);
  estadoMovimiento = movimiento ? "SI" : "NO";

  bool sinAgua = (digitalRead(PIN_FLOTADOR) == LOW);

  //---------------- Control de Lógica -----------------
  if (modoOperacion == "auto") {
    // Lógica Automática de Agua
    if (sinAgua) {
      estadoAgua = "SIN AGUA";
      digitalWrite(PIN_LED, HIGH);
    } else {
      estadoAgua = "LLENO";
      digitalWrite(PIN_LED, LOW);
    }

    // Lógica Automática de Puerta
    if (movimiento && !puertaAbierta) {
      Serial.println("Movimiento detectado (Auto)");
      abrirPuerta();
      tiempoPuerta = millis();
    }

    if (puertaAbierta) {
      if (millis() - tiempoPuerta >= TIEMPO_ABIERTA) {
        cerrarPuerta();
        delay(1000); // Espera antes de volver a detectar
      }
    }
  } else {
    // Lógica Manual (solo reporta estados físicos)
    estadoAgua = sinAgua ? "SIN AGUA" : "LLENO";
  }

  actualizarPantalla();
  delay(50);
}

//=====================================================
void abrirPuerta() {
  Serial.println("Abriendo puerta");
  for (int i = PUERTA_CERRADA; i >= PUERTA_ABIERTA; i--) {
    servoPuerta.write(i);
    delay(15);
  }
  puertaAbierta = true;
  estadoPuerta = "ABIERTA";
  actualizarPantalla();
  delay(100);
}

void cerrarPuerta() {
  Serial.println("Cerrando puerta");
  for (int i = PUERTA_ABIERTA; i <= PUERTA_CERRADA; i++) {
    servoPuerta.write(i);
    delay(15);
  }
  puertaAbierta = false;
  estadoPuerta = "CERRADA";
  actualizarPantalla();
  delay(100);
}

void actualizarPantalla() {
  display.clearDisplay();
  display.setTextSize(2);
  display.setCursor(0, 0);
  display.println("PUERTA");
  display.setTextSize(1);
  display.setCursor(0, 20);
  display.print("Estado: ");
  display.println(estadoPuerta);
  display.setCursor(0, 32);
  display.print("Agua: ");
  display.println(estadoAgua);
  display.setCursor(0, 44);
  display.print("Mov: ");
  display.println(estadoMovimiento);
  display.setCursor(0, 56);
  if (WiFi.status() == WL_CONNECTED) {
    display.print("IP: ");
    display.println(WiFi.localIP().toString());
  } else {
    display.print("AP: ");
    display.print(WiFi.softAPIP().toString());
    display.print(" (");
    display.print(WiFi.softAPgetStationNum());
    display.println(")");
  }
  display.display();
}

//================ Servidor Web Handlers ================
void handleStatus() {
  // Construir JSON manualmente para evitar dependencias
  String json = "{";
  json += "\"door\":\"" + String(puertaAbierta ? "open" : "closed") + "\",";
  json += "\"motion\":" + String(estadoMovimiento == "SI" ? "true" : "false") + ",";
  json += "\"water\":\"" + String(estadoAgua == "LLENO" ? "full" : "empty") + "\",";
  json += "\"pump\":" + String(digitalRead(PIN_LED) == HIGH ? "true" : "false") + ",";
  json += "\"rssi\":" + String(WiFi.RSSI()) + ",";
  json += "\"mode\":\"" + modoOperacion + "\"";
  json += "}";
  server.send(200, "application/json", json);
}

void handleOpenDoor() {
  abrirPuerta();
  server.send(200, "text/plain", "OK");
}

void handleCloseDoor() {
  cerrarPuerta();
  server.send(200, "text/plain", "OK");
}

void handleFillWater() {
  digitalWrite(PIN_LED, HIGH);
  estadoAgua = "SIN AGUA"; // Cambia estado reportado para simular llenado
  server.send(200, "text/plain", "OK");
}

void handleEmptyWater() {
  digitalWrite(PIN_LED, LOW);
  estadoAgua = "LLENO";
  server.send(200, "text/plain", "OK");
}

void handleSetMode() {
  if (server.hasArg("mode")) {
    modoOperacion = server.arg("mode");
    server.send(200, "text/plain", "OK");
  } else {
    server.send(400, "text/plain", "Bad Request");
  }
}