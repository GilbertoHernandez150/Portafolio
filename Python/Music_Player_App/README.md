# Music Player App - Sistema Web de Streaming Musical
> Nota: Imagenes del software en la documentacion que se encuentra en la carpeta docs.

## Descripción General
Este proyecto consiste en el desarrollo de un sistema web de streaming musical que permite reproducir contenido multimedia mediante una interfaz interactiva accesible desde el navegador.

La aplicación implementa una arquitectura cliente-servidor, donde el backend desarrollado en **Python con Flask** gestiona las solicitudes, el acceso a la base de datos y la entrega de los recursos multimedia, mientras que el frontend utiliza HTML, CSS y JavaScript para proporcionar una experiencia de usuario dinámica y moderna.

El sistema permite buscar canciones, reproducir contenido multimedia, controlar la reproducción y gestionar eventos del reproductor en tiempo real. La aplicación integra el elemento `<video>` de HTML5 para manejar la reproducción de audio y video de manera sincronizada.

El sistema se compone de:
- **Backend (API REST):** desarrollado en Python con Flask, encargado de gestionar las solicitudes, acceso a la base de datos y entrega de recursos multimedia.
- **Frontend (Interfaz Web):** construido con HTML, CSS y JavaScript, para la visualización y control del reproductor.

---

## Objetivos
- Desarrollar un sistema web de streaming musical utilizando Python y Flask como backend.
- Implementar una arquitectura cliente-servidor funcional.
- Desarrollar un reproductor multimedia basado en HTML5.
- Gestionar estados de reproducción como play, pause, siguiente y anterior.
- Integrar una base de datos SQLite para almacenamiento de información musical.
- Diseñar una interfaz moderna inspirada en plataformas actuales de streaming.
- Garantizar sincronización estable entre la reproducción multimedia y la interfaz visual.

---

## Funcionalidades Clave
- **Reproductor Multimedia Web:**  
  La aplicación incluye un reproductor integrado que permite reproducir canciones desde el navegador utilizando el elemento `<video>` de HTML5.

- **Control Dinámico de Reproducción:**  
  El usuario puede interactuar con controles como Play/Pause, Siguiente, Anterior, Shuffle, Repeat, control de volumen y barra de progreso interactiva.

- **Sincronización de Eventos Multimedia:**  
  El sistema utiliza eventos como `loadedmetadata` y `timeupdate` para mantener sincronizada la barra de progreso con el tiempo real de reproducción.

- **Interfaz Web Interactiva:**  
  El frontend actualiza dinámicamente la interfaz mediante JavaScript, mostrando información de la canción actual, duración, progreso y controles activos.

- **Integración con Base de Datos:**  
  Las canciones se almacenan en una base de datos SQLite con información como ID, nombre, artista y ruta del archivo multimedia.

- **Arquitectura Modular:**  
  El sistema separa responsabilidades entre Backend (lógica de servidor), Servicios, Modelos y Frontend, facilitando el mantenimiento y la escalabilidad.

---

## Tecnologías Utilizadas
### Backend
- **Python** → Lenguaje principal del servidor.
- **Flask** → Framework web para creación de la API.
- **SQLite** → Base de datos ligera integrada.

### Frontend
- **HTML5** → Estructura de la interfaz.
- **CSS3** → Diseño visual y estilos.
- **JavaScript (Vanilla JS)** → Manipulación dinámica del DOM.

### Otros
- HTML5 Video Element para control de reproducción multimedia.
- Sistema de logs para monitoreo del sistema.
- Caché para optimización de consultas.
- Validaciones de datos para evitar solicitudes inválidas.

---

## Ejecución del Proyecto
### 1. Clonar el repositorio
```bash
git clone https://github.com/GilbertoHernandez150/Portafolio/tree/main/Python/Music_Player_App
cd Music_Player_App
```

### 2. Crear entorno virtual
```bash
py -3.11 -m venv venv
```

Activar entorno virtual:

**Windows**
```bash
venv\Scripts\activate
```

**Mac / Linux**
```bash
source venv/bin/activate
```

### 3. Instalar dependencias
```bash
pip install flask
pip install -r requirements.txt
```

### 4. Ejecutar el servidor
```bash
python app.py
```

El servidor se ejecutará en: `http://127.0.0.1:5000`  
Abrir esta dirección en el navegador.

---

## Uso del Sistema
### Selección de Canciones
Al ingresar a la aplicación se muestra la lista de canciones disponibles. Al seleccionar una canción, el frontend envía una solicitud al backend, el servidor consulta la base de datos, se obtiene la información del archivo multimedia y el reproductor se activa automáticamente.

### Controles del Reproductor
- Play / Pause
- Siguiente canción / Canción anterior
- Shuffle y Repeat
- Control de volumen
- Barra de progreso interactiva (permite adelantar o retroceder sin reiniciar la reproducción)

### Base de Datos
El sistema utiliza **SQLite** como gestor de base de datos. El archivo se encuentra en `data/music_player.db` y almacena ID, nombre, artista y ruta del archivo multimedia. Puede visualizarse con herramientas como SQLite Viewer.

---

## Estructura del Proyecto
```
Music_Player_App
│
├── app.py
├── requirements.txt
├── README.md
│
├── app
│   ├── api
│   ├── core
│   ├── models
│   ├── services
│   └── utils
│
├── templates
│   └── index.html
│
├── static
│   ├── css
│   ├── js
│   └── images
│
├── data
│   └── music_player.db
│
├── cache
├── logs
└── venv
```

---

## Personalización y Recomendaciones
El sistema puede ampliarse para incluir: sistema de autenticación de usuarios, playlists personalizadas, recomendaciones musicales, integración con APIs externas de música y migración de SQLite a PostgreSQL.

**Recomendaciones:**
- Ejecutar el sistema dentro de un entorno virtual.
- No modificar directamente archivos multimedia en producción.

- Mantener copias de seguridad de la base de datos.
