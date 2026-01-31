#Nombre: Gilberto Hernandez
#Matricula: 2023-1211


import pygame
import sys
import random

# Inicializar pygame
pygame.init()

# Definir los colores
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GREEN = (0, 255, 0)
RED = (255, 0, 0)
BLUE = (0, 0, 255)
DARK_GRAY = (50, 50, 50)
LIGHT_GRAY = (100, 100, 100)

size = (1000, 600)

# Creación de la ventana
screen = pygame.display.set_mode(size)

# Control de los FPS
clock = pygame.time.Clock()

# Parámetros del salto
jump_power = 10  # Potencia del salto disminuida
fall_speed = 10  # Velocidad de caída ajustada
gravity = 0.5    # Gravedad
jumping = False

# Coordenadas y dimensiones de la plataforma
platform_width = size[0]
platform_height = 20  # Plataforma más delgada
platform_x = 0
platform_y = size[1] - platform_height

# Lista de plataformas
platforms = [(platform_x, platform_y, platform_width, platform_height)]

# Cargar la imagen de fondo
background_image = pygame.image.load("MiJuego/foto de mi juego.png").convert()
background_image = pygame.transform.scale(background_image, size)
background_rect = background_image.get_rect()

# Cargar las imágenes del jugador
jugador_image_left = pygame.image.load("MiJuego/jugador_izquierda/jugador_izquierda.png").convert_alpha()
jugador_image_right = pygame.image.load("MiJuego/jugador_derecha/jugador_derecha.png").convert_alpha()
jugador_image_left = pygame.transform.scale(jugador_image_left, (70, 70))  # Aumentar el tamaño del jugador
jugador_image_right = pygame.transform.scale(jugador_image_right, (70, 70))  # Aumentar el tamaño del jugador
jugador_rect = jugador_image_left.get_rect()
jugador_rect.center = (400, platform_y)  # Posicionamos al jugador sobre la plataforma

# Estado inicial del jugador (mirando hacia la derecha)
jugador_image = jugador_image_right

# Lista de proyectiles
proyectiles = []

# Temporizador para controlar el intervalo entre disparos
shoot_timer = 0
shoot_interval = 0.2  # Intervalo entre disparos en segundos

# Lista de enemigos
enemigos = []

# Variables para el control de enemigos
enemigos_max = 5  # Máximo número de enemigos en pantalla
enemigo_spawn_rate = 100  # Tasa de aparición de nuevos enemigos
enemigo_spawn_timer = 0

# Puntaje inicial
score = 0

# Cargar la imagen de la bala
bala_image_left = pygame.image.load("MiJuego/Disparos/bullet2.png").convert_alpha()
bala_image_right = pygame.image.load("MiJuego/Disparos/bullet2_der.png").convert_alpha()
bala_image_left = pygame.transform.scale(bala_image_left, (30, 20))
bala_image_right = pygame.transform.scale(bala_image_right, (30, 20))

# Definir button_rect como una variable global
button_rect = None

# Función para detectar colisiones entre dos rectángulos
def detectar_colision(rect1, rect2):
    return rect1.colliderect(rect2)

# Función para mostrar el puntaje en pantalla
def mostrar_puntaje():
    font = pygame.font.SysFont(None, 36)
    text = font.render("Puntaje: " + str(score), True, WHITE)
    screen.blit(text, (10, 10))

# Función para mostrar la pantalla de Game Over y volver al menú de inicio
def mostrar_game_over():
    font = pygame.font.SysFont(None, 72)
    text = font.render("Game Over", True, RED)
    text_rect = text.get_rect(center=(size[0] // 2, size[1] // 2))
    screen.blit(text, text_rect)
    pygame.display.flip()
    pygame.time.delay(2000)  # Esperar 2 segundos antes de regresar al menú de inicio
    # Restablecer el estado del juego
    global jugando, score, enemigos, proyectiles
    jugando = False
    score = 0
    enemigos = []
    proyectiles = []

# Función para mostrar el mensaje de "Felicidades Ganaste"
def mostrar_ganador():
    font = pygame.font.SysFont(None, 72)
    text = font.render("Felicidades Ganaste", True, GREEN)
    text_rect = text.get_rect(center=(size[0] // 2, size[1] // 2))
    screen.blit(text, text_rect)

# Variables para el control de la velocidad de los enemigos
enemigo_speed = 3  # Velocidad inicial de los enemigos
enemigo_spawn_interval = 100  # Intervalo de aparición inicial de los enemigos
enemigo_speed_increase = 0.02  # Incremento de velocidad de los enemigos

# Función para mostrar el menú de inicio
def mostrar_menu_inicio():
    global button_rect
    screen.fill(BLACK)  # Cambiar el color de fondo a negro

    # Animación de nieve
    snowflakes = [(random.randint(0, size[0]), random.randint(0, size[1])) for _ in range(100)]
    for flake in snowflakes:
        pygame.draw.circle(screen, WHITE, flake, 2)

    font_title = pygame.font.SysFont(None, 72)
    text_title = font_title.render("S.O.S", True, WHITE)
    text_title_rect = text_title.get_rect(center=(size[0] // 2, size[1] // 4))
    screen.blit(text_title, text_title_rect)

    # Botón Start
    font_button = pygame.font.SysFont(None, 36)
    button_start = font_button.render("Start", True, WHITE, GREEN)
    global button_rect  # Definir button_rect como global
    button_rect = button_start.get_rect(center=(size[0] // 2, size[1] // 2))
    pygame.draw.rect(screen, GREEN, button_rect)
    screen.blit(button_start, button_rect.topleft)

    pygame.display.flip()

# Variable para controlar el estado del juego
jugando = False

# Detectar los eventos del programa
while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        elif event.type == pygame.MOUSEBUTTONDOWN and not jugando:
            mouse_pos = pygame.mouse.get_pos()
            if button_rect.collidepoint(mouse_pos):  # Acceder a button_rect globalmente
                jugando = True

    if not jugando:
        mostrar_menu_inicio()
    else:
        # Eventos del teclado
        userInput = pygame.key.get_pressed()
        if userInput[pygame.K_LEFT]:
            jugador_image = jugador_image_left
            jugador_rect.x -= 3
        elif userInput[pygame.K_RIGHT]:
            jugador_image = jugador_image_right
            jugador_rect.x += 3

        # Actualizar el temporizador de disparo
        shoot_timer = max(0, shoot_timer - clock.get_time() / 1000)  # Restar el tiempo transcurrido desde el último frame

        # Disparar proyectil al presionar "x"
        if userInput[pygame.K_x] and shoot_timer <= 0:
            shoot_timer = shoot_interval  # Reiniciar el temporizador
            if jugador_image == jugador_image_left:
                proyectil_rect = pygame.Rect(jugador_rect.left, jugador_rect.centery - 10, 10, 5)
                proyectiles.append((proyectil_rect, -5))  # Velocidad negativa para mover la bala hacia la izquierda
            else:  # Jugador mirando hacia la derecha
                proyectil_rect = pygame.Rect(jugador_rect.right, jugador_rect.centery - 10, 10, 5)
                proyectiles.append((proyectil_rect, 5))  # Velocidad positiva para mover la bala hacia la derecha

        # Control de aparición de enemigos
        if len(enemigos) < enemigos_max:
            enemigo_spawn_timer += 1
            if enemigo_spawn_timer >= enemigo_spawn_interval:
                # Posicionamos al enemigo en el límite izquierdo o derecho de la pantalla, al mismo nivel que el jugador
                enemigo_rect = pygame.Rect(0 if jugador_rect.x > size[0] // 2 else size[0], jugador_rect.y, jugador_rect.width, jugador_rect.height)
                enemigo_image_left = pygame.image.load("MiJuego/Enemigos/enemigo_izquierda.png").convert_alpha()
                enemigo_image_right = pygame.image.load("MiJuego/Enemigos/enemigo_derecha.png").convert_alpha()
                enemigo_image_left = pygame.transform.scale(enemigo_image_left, (jugador_rect.width, jugador_rect.height))
                enemigo_image_right = pygame.transform.scale(enemigo_image_right, (jugador_rect.width, jugador_rect.height))
                enemigo_image = enemigo_image_left if jugador_rect.x > size[0] // 2 else enemigo_image_right
                # Establecemos la velocidad del enemigo hacia el jugador
                enemigos.append((enemigo_rect, enemigo_speed if jugador_rect.x > size[0] // 2 else -enemigo_speed, enemigo_image))
                enemigo_spawn_timer = 0

        # Aplicar gravedad
        jugador_rect.y += gravity

        # Verificar si el jugador está sobre una plataforma
        on_platform = False
        for platform in platforms:
            if jugador_rect.colliderect(platform):
                on_platform = True
                jugador_rect.y = platform[1] - jugador_rect.height
                break

        # Manejo del salto
        if userInput[pygame.K_SPACE] and not jumping and on_platform:
            jumping = True

        if jumping:
            jugador_rect.y -= jump_power
            jump_power -= 0.5  # Reducir la potencia del salto con el tiempo
            if jump_power <= 0:
                jumping = False
                jump_power = 10  # Reiniciar la potencia del salto

        # Limitar la velocidad de caída
        if not jumping:
            jugador_rect.y += fall_speed
            if fall_speed < 10:  # Limitar la velocidad máxima de caída
                fall_speed += 0.5

        # Limitar la posición del jugador dentro de los límites de la pantalla
        jugador_rect.x = max(0, min(jugador_rect.x, size[0] - jugador_rect.width))

        # Actualizar la posición de los proyectiles
        for proyectil in proyectiles:
            proyectil[0].x += proyectil[1]  # Mover la bala en la dirección establecida por su velocidad
            # Eliminar proyectiles que salen de la pantalla
            if proyectil[0].right < 0 or proyectil[0].left > size[0]:
                proyectiles.remove(proyectil)

        # Aumentar la velocidad de los enemigos cada 10 puntos
        if score % 10 == 0 and score != 0:
            enemigo_speed += enemigo_speed_increase

        # Actualizar la posición de los enemigos
        for enemigo in enemigos:
            enemigo_rect, enemigo_dx, enemigo_image = enemigo
            enemigo_rect.x += enemigo_dx
            # Eliminar enemigos que salen de la pantalla
            if enemigo_rect.right < 0 or enemigo_rect.left > size[0]:
                enemigos.remove(enemigo)

        # Detectar colisiones entre el jugador y los enemigos
        for enemigo in enemigos:
            if detectar_colision(jugador_rect, enemigo[0]):
                mostrar_game_over()

        # Detectar colisiones entre proyectiles y enemigos
        for proyectil in proyectiles:
            for enemigo in enemigos:
                if detectar_colision(proyectil[0], enemigo[0]):
                    enemigos.remove(enemigo)
                    proyectiles.remove(proyectil)
                    score += 1

        # Dibujar la imagen de fondo
        screen.blit(background_image, background_rect)

        # Dibujar al jugador
        screen.blit(jugador_image, jugador_rect)

        # Dibujar los proyectiles
        for proyectil in proyectiles:
            screen.blit(bala_image_left if proyectil[1] < 0 else bala_image_right, proyectil[0])

        # Dibujar los enemigos
        for enemigo in enemigos:
            screen.blit(enemigo[2], enemigo[0])

        # Dibujar la plataforma
        pygame.draw.rect(screen, BLACK, (0, platform_y, size[0], platform_height))

        # Mostrar el puntaje en pantalla
        mostrar_puntaje()

        # Verificar si el jugador ha ganado
        if score >= 10:
            mostrar_ganador()
            pygame.display.flip()
            pygame.time.delay(2000)  # Esperar 2 segundos antes de salir
            pygame.quit()
            sys.exit()

    # Actualizar la pantalla
    pygame.display.flip()
    clock.tick(60)
