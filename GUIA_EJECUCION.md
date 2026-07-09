# Guia de ejecucion y emulacion - SmartFarm

Esta guia explica paso a paso todas las alternativas disponibles para ejecutar, visualizar y depurar la aplicacion SmartFarm en tu computadora con Windows.

---

## Requisitos previos

Antes de comenzar, verifica que tengas instalado lo siguiente:

| Herramienta | Ruta de instalacion verificada |
|---|---|
| Flutter SDK | `C:\src\flutter\flutter\bin\flutter.bat` |
| Android Studio | Instalado en el sistema |
| Android SDK | `C:\Users\Samira\AppData\Local\Android\Sdk` |
| JDK (incluido con Android Studio) | Automatico con Android Studio |

Para verificar que todo este correcto, abre PowerShell y ejecuta:

```powershell
C:\src\flutter\flutter\bin\flutter.bat doctor
```

Si aparece una marca verde en Flutter, Android SDK y Android Studio, ya estas lista para continuar.

---

## Alternativa 1 - Emulador Android en Android Studio (recomendada para desarrollo)

Esta es la opcion mas comoda para hacer ajustes visuales. Es el equivalente al navegador en desarrollo web.

### Paso 1 - Crear un dispositivo virtual (AVD)

1. Abre **Android Studio**
2. En el menu superior ve a **Tools** → **Device Manager** (o haz clic en el icono de telefono en la barra lateral derecha)
3. Haz clic en el boton **Create Virtual Device** (o el boton "+")
4. Selecciona la categoria **Phone**
5. Elige el modelo **Pixel 6** y haz clic en **Next**
6. En la pantalla de imagen del sistema:
   - Selecciona la pestana **Recommended**
   - Elige **API Level 34 (Android 14)** — descargalo si aparece la flecha de descarga
   - Haz clic en **Next**
7. En la pantalla de configuracion:
   - Deja el nombre por defecto o cambialo
   - Haz clic en **Finish**

### Paso 2 - Iniciar el emulador

1. En Device Manager, busca el dispositivo que acabas de crear
2. Haz clic en el boton **Play** (triangulo) al lado del dispositivo
3. Espera que el emulador arranque completamente (puede tardar 1-2 minutos la primera vez)

### Paso 3 - Ejecutar la aplicacion

Abre PowerShell y navega al proyecto:

```powershell
cd C:\Users\Samira\Downloads\smartfarm_flutter
C:\src\flutter\flutter\bin\flutter.bat run
```

Flutter detecta automaticamente el emulador y despliega la aplicacion en el.

### Paso 4 - Hacer cambios con hot reload

Mientras la aplicacion esta corriendo en el emulador:

- Edita cualquier archivo Dart en tu editor (VS Code o Android Studio)
- Guarda el archivo con **Ctrl + S**
- En la terminal donde corre Flutter, presiona la tecla **r** para hacer hot reload

El cambio se refleja en el emulador en menos de 1 segundo, sin reiniciar la aplicacion ni perder el estado actual.

| Tecla en terminal | Accion |
|---|---|
| `r` | Hot reload (actualiza UI sin perder estado) |
| `R` | Hot restart (reinicia la app completamente) |
| `p` | Mostrar/ocultar guias de layout (rectangulos de widgets) |
| `q` | Cerrar la aplicacion y terminar |

---

## Alternativa 2 - Dispositivo Android fisico por cable USB

Esta opcion ejecuta la aplicacion directamente en tu telefono Android. Tiene la ventaja de ver el comportamiento real en hardware fisico, incluyendo rendimiento y animaciones exactas.

### Paso 1 - Activar depuracion USB en el telefono

1. En tu telefono Android, ve a **Ajustes** (Settings)
2. Baja hasta **Acerca del telefono** (About phone)
3. Busca el campo **Numero de compilacion** (Build number)
4. Toca ese campo **7 veces seguidas** — aparecera el mensaje "Ahora eres desarrollador"
5. Regresa a **Ajustes** → ahora aparece una nueva opcion llamada **Opciones de desarrollador** (Developer options)
6. Entra en **Opciones de desarrollador**
7. Activa el interruptor **Depuracion USB** (USB debugging)

### Paso 2 - Conectar el telefono

1. Conecta tu telefono a la computadora con un cable USB
2. En el telefono aparecera un mensaje preguntando si confias en esta computadora
3. Toca **Permitir** o **Aceptar**

### Paso 3 - Verificar que Flutter detecta el dispositivo

```powershell
C:\src\flutter\flutter\bin\flutter.bat devices
```

Debe aparecer tu telefono en la lista, por ejemplo:
```
SAMSUNG SM-A155F (mobile) • RF8N413F2CJ • android-arm64 • Android 14
```

### Paso 4 - Ejecutar la aplicacion

```powershell
cd C:\Users\Samira\Downloads\smartfarm_flutter
C:\src\flutter\flutter\bin\flutter.bat run
```

Hot reload funciona de la misma manera que con el emulador: presiona **r** en la terminal despues de guardar cambios.

---

## Alternativa 3 - Vista previa en Chrome (modo web rapido)

Flutter puede compilar y correr en el navegador Google Chrome. Es la opcion mas rapida para revisar cambios de diseño ya que no requiere emulador ni telefono.

> Nota: Las animaciones 3D de la puerta y el comedero pueden verse ligeramente diferentes en Chrome porque el motor de renderizado web difiere del motor nativo Android. Para revision de colores, tipografia y layout, esta opcion es completamente valida.

### Paso 1 - Habilitar soporte web en Flutter (si no esta habilitado)

```powershell
C:\src\flutter\flutter\bin\flutter.bat config --enable-web
```

### Paso 2 - Ejecutar en Chrome

```powershell
cd C:\Users\Samira\Downloads\smartfarm_flutter
C:\src\flutter\flutter\bin\flutter.bat run -d chrome
```

La aplicacion se abre directamente en Google Chrome. Hot reload funciona igual: presiona **r** en la terminal.

---

## Alternativa 4 - Instalar el APK directamente en el telefono

Esta opcion es para instalar la version final de produccion sin necesitar cables ni configuracion de desarrollo. Util para mostrar la aplicacion a otras personas.

### El APK ya compilado esta en:

```
C:\Users\Samira\Downloads\SmartFarm_v1.0.0.apk
```

### Opcion A - Por cable USB

1. Conecta el telefono a la computadora por USB
2. En el telefono, selecciona **Transferencia de archivos** (File Transfer / MTP) al conectar
3. Copia el archivo `SmartFarm_v1.0.0.apk` al almacenamiento del telefono
4. En el telefono, abre el explorador de archivos
5. Navega hasta donde copiaste el APK
6. Toca el archivo para instalar

Si aparece el mensaje "Aplicacion bloqueada" o "Fuentes desconocidas":
- Ve a **Ajustes** → **Seguridad** → **Instalar aplicaciones desconocidas**
- Activa el permiso para tu explorador de archivos
- Vuelve a intentar la instalacion

### Opcion B - Por Google Drive, WhatsApp o Telegram

1. Sube el archivo `SmartFarm_v1.0.0.apk` a Google Drive, envialo por WhatsApp a ti mismo, o por Telegram
2. En tu telefono, descarga el archivo
3. Toca el archivo descargado para instalarlo
4. Si aparece la advertencia de fuentes desconocidas, siguel los pasos descritos en Opcion A

### Compilar una nueva APK si haces cambios

Cada vez que hagas cambios al codigo y quieras una nueva APK:

```powershell
cd C:\Users\Samira\Downloads\smartfarm_flutter
C:\src\flutter\flutter\bin\flutter.bat build apk --release
```

El nuevo APK se genera en:
```
C:\Users\Samira\Downloads\smartfarm_flutter\build\app\outputs\flutter-apk\app-release.apk
```

---

## Tabla de comparacion de alternativas

| Alternativa | Velocidad de inicio | Hot reload | Fidelidad visual | Requiere |
|---|---|---|---|---|
| Emulador Android Studio | Media (1-2 min) | Si | Alta | Android Studio + AVD |
| Dispositivo fisico USB | Rapida | Si | Exacta | Cable USB + Depuracion USB |
| Chrome (web) | Muy rapida | Si | Media | Google Chrome |
| APK instalada | Inmediata | No | Exacta | Ninguno adicional |

### Recomendacion por situacion

- Para desarrollo diario y ajustes de UI: usa el **emulador Android Studio** o **dispositivo fisico**
- Para revision rapida de colores y layout: usa **Chrome**
- Para mostrar la app terminada a otras personas: usa el **APK instalado**
- Para presentaciones o demostraciones: usa el **APK en el telefono fisico**

---

## Agregar Flutter al PATH del sistema (opcional pero recomendado)

Actualmente el comando de Flutter requiere la ruta completa. Para usar simplemente `flutter` en cualquier terminal:

1. Abre el menu inicio y busca **Variables de entorno**
2. Haz clic en **Editar las variables de entorno del sistema**
3. En la ventana que se abre, haz clic en **Variables de entorno...**
4. En la seccion **Variables del sistema**, selecciona la variable **Path** y haz clic en **Editar**
5. Haz clic en **Nuevo** y escribe:
   ```
   C:\src\flutter\flutter\bin
   ```
6. Haz clic en **Aceptar** en todas las ventanas
7. Cierra y vuelve a abrir PowerShell

Despues de esto, puedes usar simplemente:
```powershell
flutter run
flutter build apk --release
flutter doctor
```

---

## Preguntas frecuentes

**El emulador esta muy lento, que hago?**
Asegurate de tener habilitada la aceleracion por hardware. En Android Studio: File → Settings → SDK Manager → SDK Tools → activa **Intel HAXM** o verifica que tu CPU tenga habilitada la virtualizacion (VT-x o AMD-V) en la BIOS.

**Flutter no detecta el emulador**
Verifica que el emulador este completamente iniciado (la pantalla de inicio del telefono virtual visible) antes de ejecutar `flutter run`.

**El APK no instala por "fuente desconocida"**
Ve a Ajustes → Seguridad → Instalar aplicaciones desconocidas, y activa el permiso para el explorador de archivos o el navegador desde el que abres el APK.

**Como cambio la IP del ESP32 en la app?**
Edita el archivo `lib/services/esp32_service.dart` y cambia el valor de `baseUrl`, luego vuelve a compilar el APK con `flutter build apk --release`.
