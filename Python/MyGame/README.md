# MyGame - Videojuego 2D de Acción y Supervivencia
## Descripción General
Este proyecto consiste en el desarrollo de un videojuego 2D tipo acción y supervivencia, implementado utilizando el lenguaje de programación Python junto con la librería Pygame. El objetivo principal del juego es poner a prueba los reflejos, la coordinación y la capacidad de reacción del jugador frente a enemigos que aparecen progresivamente en pantalla.

El videojuego cuenta con una interfaz gráfica interactiva, iniciando con un menú principal que permite al usuario comenzar la partida. Una vez iniciado el juego, el jugador controla a un personaje principal que puede desplazarse horizontalmente, saltar y disparar proyectiles para eliminar a los enemigos que se aproximan desde ambos lados de la pantalla.

El sistema se compone de:
- Mecánicas de juego: Movimiento del personaje, sistema de salto con gravedad, disparo de proyectiles y detección de colisiones.
- Sistema de enemigos: Aparición progresiva con velocidad y frecuencia variable según puntuación.
- Interfaz gráfica: Menú principal, tablero de juego con fondo personalizado, sprites animados y mensajes de estado.


## Objetivos
- Desarrollar un videojuego 2D funcional con mecánicas de acción y supervivencia.
- Implementar sistema de puntuación y dificultad progresiva.
- Crear sistema de detección de colisiones entre elementos del juego.
- Diseñar interfaz gráfica interactiva con animaciones visuales.
- Aplicar conceptos de programación orientada a eventos y manejo de gráficos 2D.
- Gestionar estados del juego (Menú, Jugando, Victoria, Game Over).


## Funcionalidades Clave
- Control del personaje:
  Movimiento horizontal (izquierda/derecha), sistema de salto con física de gravedad y disparo de proyectiles hacia enemigos.

- Sistema de enemigos dinámico:
  Aparición progresiva desde ambos lados de la pantalla con movimiento automático hacia el jugador. Velocidad y frecuencia aumentan según puntuación.

- Detección de colisiones:
  - Jugador vs Enemigo: Game Over inmediato.
  - Proyectil vs Enemigo: Eliminación del enemigo, +1 punto, destrucción del proyectil.

- Sistema de puntuación:
  Incrementa con cada enemigo eliminado. Sin penalización por proyectiles fallados. Puntaje visible en todo momento.

- Dificultad progresiva:
  Escalamiento dinámico dividido en rangos:
  - 0-5 puntos: Velocidad normal, frecuencia baja.
  - 6-15 puntos: Velocidad +20%, frecuencia media.
  - 16-30 puntos: Velocidad +40%, frecuencia alta.
  - 31+ puntos: Velocidad +60%, frecuencia muy alta.

- Estados del juego:
  Gestión de estados (MENU, PLAYING, VICTORY, GAME_OVER) con transiciones automáticas y bloqueo de interacciones al finalizar.

- Animaciones visuales:
  Sprites animados para personaje principal, enemigos y proyectiles. Fondo gráfico personalizado y plataforma base delimitadora.


## Tecnologías Utilizadas
### Lenguaje de Programación
- Python 3.x → lenguaje principal del juego.

### Librerías
- Pygame → motor gráfico para renderizado 2D, manejo de eventos y física básica.
- sys → gestión de sistema y cierre de aplicación.
- random → generación de posiciones aleatorias para enemigos.

### Conceptos Aplicados
- Programación orientada a eventos → manejo de input del teclado y mouse.
- Manejo de gráficos 2D → renderizado de sprites y actualización de pantalla a 60 FPS.
- Control de colisiones → detección mediante rect collision.
- Gestión de estados del juego → MENU, PLAYING, VICTORY, GAME_OVER.
- Lógica de dificultad progresiva → ajuste dinámico basado en puntuación.


## Instalación

### Requisitos Previos
- Python 3.7 o superior
- pip (gestor de paquetes de Python)

### Pasos de Instalación
```bash
# 1. Clonar el repositorio
git clone https://github.com/GilbertoHernandez150/Portafolio/tree/main/Python/MyGame
cd MyGame

# 2. Crear entorno virtual (recomendado)
python -m venv venv

# 3. Activar entorno virtual
# En Windows:
venv\Scripts\activate
# En macOS/Linux:
source venv/bin/activate

# 4. Instalar Pygame
pip install pygame

# 5. Ejecutar el juego
python game.py
```

## Controles del Juego
| Tecla | Acción |
|-------|--------|
| Flecha Izquierda | Mover personaje a la izquierda |
| Flecha Derecha | Mover personaje a la derecha |
| Espacio | Saltar |
| Click Izquierdo | Disparar proyectil |
| ESC | Salir del juego |


---

**Desarrollado por: Gilberto Hernández**
