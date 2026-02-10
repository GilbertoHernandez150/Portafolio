# Ajedrez con Inteligencia Artificial
## Descripción General
Este proyecto consiste en el desarrollo de un sistema de ajedrez profesional con Inteligencia Artificial accesible desde navegador web. El usuario juega con las piezas blancas contra una IA que controla las negras, con distintos niveles de dificultad, incluyendo un modo profesional con comportamiento estratégico avanzado.

El sistema está diseñado bajo una arquitectura cliente-servidor, utilizando Python con Flask como backend y JavaScript para la interacción en tiempo real del frontend.

El sistema se compone de:
- Backend (API REST): desarrollado en Python con Flask, encargado de gestionar el estado del juego, validar movimientos y ejecutar la Inteligencia Artificial.
- Frontend (Interfaz Web): construido con HTML, CSS y JavaScript, para la visualización del tablero, captura de movimientos y comunicación con el backend.


## Objetivos
- Implementar las reglas oficiales del ajedrez.
- Desarrollar una IA basada en el algoritmo Minimax con poda alfa-beta.
- Permitir múltiples niveles de dificultad ajustables.
- Proveer una interfaz clara, intuitiva y profesional.
- Garantizar estabilidad y control de errores durante la partida.
- Detectar jaque, jaque mate y tablas automáticamente.


## Funcionalidades Clave
- Juego completo de ajedrez:
  Todas las reglas oficiales implementadas incluyendo movimientos legales, capturas, promoción de peones, detección de jaque, jaque mate y tablas.

- IA con múltiples niveles de dificultad:
  4 niveles configurables (Principiante, Intermedio, Avanzado, Profesional) con profundidad de búsqueda variable y diferentes grados de aleatoriedad.

- Algoritmo Minimax con poda alfa-beta:
  La IA explora el árbol de movimientos futuros maximizando su ventaja y minimizando la del oponente, con optimización mediante poda para reducir nodos evaluados.

- Evaluación estratégica avanzada:
  Considera material (valor de piezas), posición del rey, capturas, rey expuesto y ventaja posicional para decisiones más realistas.

- Gestión de múltiples partidas:
  Cada partida se identifica con un game_id único, permitiendo mantener múltiples juegos simultáneos aislados.

- Interfaz web intuitiva:
  - Tablero dinámico generado a partir de FEN.
  - Resaltado visual de movimientos válidos.
  - Mensajes de estado claros (GANASTE, PERDISTE, TABLAS).
  - Bloqueo de interacciones al finalizar la partida.


## Tecnologías Utilizadas
### Backend
- Python → lenguaje principal del backend.
- Flask → servidor web para manejo de peticiones HTTP.
- python-chess → motor de reglas del ajedrez y validación de movimientos.

### Frontend
- HTML5 → estructura de la interfaz.
- CSS3 → estilos y diseño del tablero.
- JavaScript (Vanilla JS) → lógica del cliente y manejo del DOM.
- Fetch API → comunicación con el backend mediante JSON.

### Algoritmos
- Minimax con poda alfa-beta → búsqueda adversarial para decisiones de la IA.
- Función de evaluación heurística → análisis de posición considerando múltiples factores.


## Arquitectura del Sistema
El sistema sigue una arquitectura cliente-servidor:

### Frontend (Cliente)
- Renderiza el tablero dinámicamente a partir de FEN.
- Captura interacciones del usuario (clicks en piezas y casillas).
- Envía movimientos al backend mediante peticiones HTTP POST.
- Recibe y muestra la respuesta de la IA.
- Resalta movimientos válidos visualmente.

### Backend (Servidor)
- Valida movimientos según las reglas del ajedrez.
- Ejecuta la IA para calcular el mejor movimiento.
- Controla el estado del juego (jaque, jaque mate, tablas).
- Gestiona múltiples partidas simultáneas mediante identificadores únicos.

La comunicación se realiza mediante peticiones HTTP POST con datos en formato JSON.


## Motor de Inteligencia Artificial
La IA está encapsulada en la clase ChessAI, responsable de:
- Evaluar posiciones del tablero.
- Analizar jugadas futuras mediante árbol de búsqueda.
- Seleccionar el mejor movimiento posible según la dificultad.

### Algoritmo Minimax con Poda Alfa-Beta
Características del algoritmo:
- Negras (IA) → maximizan puntuación.
- Blancas (Jugador) → minimizan puntuación.
- Profundidad variable según nivel de dificultad.
- Poda alfa-beta reduce drásticamente el número de nodos evaluados.

### Función de Evaluación
La función evaluate() considera:
- Material: Valor de las piezas en el tablero (Peón: 1, Caballo: 3, Alfil: 3, Torre: 5, Dama: 9).
- Jaque y jaque mate: Bonificación/penalización significativa.
- Capturas: Valor de piezas capturadas.
- Rey expuesto: Penalización por rey vulnerable.
- Ventaja posicional: Control del centro y desarrollo.

### Niveles de Dificultad
| Dificultad | Profundidad | Aleatoriedad | Características |
|------------|-------------|--------------|-----------------|
| Principiante | 1 | Alta | Movimientos básicos, errores frecuentes |
| Intermedio | 2 | Media | Considera 2 movimientos adelante |
| Avanzado | 3 | Baja | Estrategia a medio plazo |
| Profesional | 4-5 | Ninguna | Comportamiento estratégico avanzado |


## Instalación

### Requisitos Previos
- Python 3.7 o superior
- pip (gestor de paquetes de Python)

### Pasos de Instalación
```bash
# 1. Clonar el repositorio
git clone https://github.com/GilbertoHernandez150/Portafolio/tree/main/Python/Ajedrez_IA
cd Ajedrez_IA

# 2. Crear entorno virtual (recomendado)
python -m venv venv

# 3. Activar entorno virtual
# En Windows:
venv\Scripts\activate
# En macOS/Linux:
source venv/bin/activate

# 4. Instalar dependencias
pip install flask python-chess

# 5. Ejecutar el servidor
python app.py
```

Acceso al juego: Abrir navegador en http://localhost:5000


## Uso del Sistema

### Iniciar Partida
1. Seleccionar nivel de dificultad (Principiante, Intermedio, Avanzado o Profesional).
2. Hacer clic en "Iniciar Juego".

### Durante la Partida
1. Hacer clic en una pieza blanca para seleccionarla.
2. Las casillas válidas se resaltarán en verde.
3. Hacer clic en una casilla resaltada para realizar el movimiento.
4. La IA responderá automáticamente con su movimiento.

### Mensajes de Estado
El sistema muestra mensajes claros al finalizar:
- GANASTE → Victoria del jugador.
- PERDISTE → Victoria de la IA.
- TABLAS → Empate.

Cuando el juego finaliza, se bloquean las interacciones.


## Endpoints del Backend
- /new_game → Iniciar nueva partida (POST)
- /move → Enviar movimiento del jugador (POST)
- /get_legal_moves → Obtener movimientos válidos para una pieza (POST)


## Limitaciones del Sistema
- No guarda historial de partidas.
- IA no utiliza apertura teórica (libro de aperturas).
- No usa tablas de finales (endgame tablebase).
- No implementa multithreading (una IA por petición).
- Sin persistencia de datos en base de datos.
- No hay sistema de usuarios o autenticación.


## Mejoras Futuras
- Base de Datos: Implementar persistencia de partidas, sistema de usuarios, historial y estadísticas.
- Mejoras de IA: Integración con motor Stockfish, libro de aperturas, tablas de finales, aprendizaje por refuerzo.
- Funcionalidades: Modo multijugador online, chat entre jugadores, análisis de partidas, sugerencias de movimientos.
- Optimización: Multithreading para cálculos paralelos, caché de evaluaciones, búsqueda paralela.
- Interfaz: Temas personalizables, animaciones de movimiento, efectos de sonido, modo oscuro.

---

**Desarrollado por: Gilberto Hernández**
