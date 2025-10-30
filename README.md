# ⚠️ ATENCIÓN: NO HACER PUSH DIRECTO AL MAIN ⚠️

**¡MUY IMPORTANTE!**

- **🚫 NUNCA HAGAS PUSH DIRECTO A `main`**
- **💡 SIEMPRE TRABAJA EN RAMAS `feature/...` O `develop`**
- **✅ Crea tu rama feature desde `develop`:**



<br> <br>

# 🚀 Guía de Despliegue Flutter — CaffiNet-FrontEnd

**Repositorio:** `https://github.com/upc-pre-1acc0184-2520-1407-G10-CaffiNet/CaffiNet-FrontEnd.git`

Esta guía cubre todo el proceso para clonar, configurar y ejecutar la aplicación Flutter **CaffiNet-FrontEnd**, desde los requisitos previos hasta las buenas prácticas de desarrollo y ramas.

## 1️⃣ Requisitos Previos 🛠️

Antes de comenzar, asegúrate de tener instaladas las siguientes herramientas:

* 🐦 **Flutter SDK:**
    * Descarga e instalación: [flutter.dev](https://flutter.dev/docs/get-started/install)
    * **Crucial:** Añadir la carpeta `flutter/bin` a la variable de entorno **PATH**.
    * Reinicia tu terminal o VS Code después de la instalación.
* 🔧 **VS Code:**
    * Extensiones recomendadas: `Flutter` y `Dart`.
* 💻 **Git:**
    * Necesario para clonar el repositorio y gestionar el control de versiones.
* 📱 **Emulador/Simulador (Opcional):**
    * Android Studio (para emuladores de Android) o Xcode (para simuladores de iOS).


## 2️⃣ Clonar el Repositorio 📥

Abre tu terminal, navega a la carpeta donde deseas guardar el proyecto y ejecuta los siguientes comandos:

```bash
git clone https://github.com/upc-pre-1acc0184-2520-1407-G10-CaffiNet/CaffiNet-FrontEnd.git
cd CaffiNet-FrontEnd

```

## 3️⃣ Errores Comunes al Clonar ⚠️

Si el proyecto no se ejecuta inmediatamente después de clonar, podría deberse a:

* ⚠️ **Dependencias no instaladas:** Falta ejecutar `flutter pub get`.
* ⚠️ **Flutter SDK no en el PATH:** El entorno no está configurado correctamente o el SDK no está instalado.
* ⚠️ **Versión de Flutter distinta:** La versión local de Flutter no coincide con la requerida por el proyecto.
* ⚠️ **Archivos generados faltantes:** Archivos de *code generation* que deben ser creados (ej. `build_runner`).

> **Solución:** Ejecutar el comando del Punto 4 (`flutter pub get`) seguido del Punto 5 (`flutter doctor`).


## 4️⃣ Instalar Dependencias 📦

Dentro de la carpeta del proyecto (`CaffiNet-FrontEnd`), ejecuta:

```bash
flutter pub get
```

## 5️⃣ Verificar Instalación con Flutter Doctor 🩺

Ejecuta este comando para revisar el estado completo de tu entorno Flutter:

```bash
flutter doctor
```

## 6️⃣ Abrir el Proyecto en VS Code 📂

1.  Abre VS Code.
2.  Ve a `File` -> `Open Folder...`.
3.  Selecciona la carpeta `CaffiNet-FrontEnd`.

> 💡 **Consejo:** VS Code detectará automáticamente las extensiones de Flutter/Dart. En la barra de estado inferior derecha, usa el **Device Selector** para elegir tu emulador o dispositivo físico.

## 7️⃣ Ejecutar el Proyecto ▶️

Con un emulador/dispositivo seleccionado, compila y ejecuta la aplicación:

```bash
flutter run
```

## 8️⃣ Actualizar Dependencias ⬆️

Si necesitas actualizar todos los paquetes a la última versión compatible con las restricciones de tu `pubspec.yaml`, usa:

```bash
flutter pub upgrade
```


## 9️⃣ Crear rama feature desde develop y buenas prácticas

Si ya tienes la rama `develop` en el repositorio, no la crees de nuevo.  
Sigue este flujo:


### Cambiar a la rama develop existente
```bash
git checkout develop
```
### Crear y cambiar a tu rama feature
```bash
git checkout -b feature/nombre-de-la-rama
```
### Subir la rama feature al remoto
```bash
git push -u origin feature/nombre-de-la-rama
```