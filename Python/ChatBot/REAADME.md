# Chatbot ITLA
## Descripción General
Este proyecto consiste en el desarrollo de un chatbot conversacional utilizando únicamente el lenguaje Python. El chatbot puede proveer información referente al Instituto Tecnológico de las Américas (ITLA) con el fin de conocer más acerca de la institución.

El sistema utiliza procesamiento de lenguaje natural simple basado en coincidencia de patrones y probabilidad. El bot analiza las preguntas del usuario, calcula qué tan bien coinciden con respuestas conocidas y selecciona la respuesta más apropiada.

El sistema se compone de:
- Motor de procesamiento: Preprocesa el input del usuario, analiza coincidencias mediante expresiones regulares y calcula probabilidad de respuestas.
- Base de datos de respuestas: Archivo separado (responses.py) con preguntas y respuestas predefinidas sobre el ITLA.
- Interfaz de consola: Interacción en tiempo real por línea de comandos.

Nota: Los datos presentes e ingresados en el chatbot pueden cambiar o variar con el tiempo dependiendo de las decisiones administrativas de la institución.


## Objetivos
- Desarrollar un chatbot funcional utilizando solo Python estándar.
- Implementar sistema de procesamiento de lenguaje natural básico.
- Crear base de datos de respuestas sobre el ITLA.
- Aplicar técnicas de coincidencia de patrones y probabilidad.
- Demostrar fundamentos de chatbots basados en reglas.
- Proveer información educativa sobre la institución de manera interactiva.


## Funcionalidades Clave
- Procesamiento de lenguaje natural simple:
  Análisis de texto mediante expresiones regulares (re). Conversión a minúsculas, división en palabras y eliminación de caracteres especiales.

- Sistema de coincidencia por probabilidad:
  Calcula qué tan bien coincide la pregunta del usuario con respuestas conocidas. Cuenta palabras reconocidas, verifica palabras obligatorias y calcula porcentaje de coincidencia (0-100).

- Base de datos de respuestas configurable:
  Archivo separado (responses.py) con estructura de diccionarios que incluye texto de respuesta, palabras reconocidas, palabras obligatorias y tipo de respuesta.

- Manejo de incertidumbre:
  Cuando ninguna respuesta alcanza el umbral mínimo (20%), selecciona una respuesta genérica aleatoria de un conjunto predefinido.

- Sin dependencias externas:
  Solo usa librerías estándar de Python (re, random). No requiere instalación de paquetes adicionales.

- Fácil expansión:
  Agregar nuevas respuestas es tan simple como añadir un nuevo diccionario al archivo responses.py.


## Tecnologías Utilizadas
### Lenguaje de Programación
- Python 3.x → lenguaje principal del chatbot.

### Librerías Estándar
- re → expresiones regulares para procesamiento de texto.
- random → selección aleatoria de respuestas genéricas.

### Técnicas Implementadas
- Coincidencia de patrones → análisis de palabras clave.
- Cálculo de probabilidad → porcentaje de coincidencia.
- Programación basada en reglas → respuestas predefinidas.


## Funcionamiento del Sistema

### Paso 1: Preprocesamiento del Input
- Convierte la entrada del usuario a minúsculas.
- Divide el texto en palabras individuales usando expresiones regulares.
- Elimina caracteres especiales y espacios.

### Paso 2: Análisis de Coincidencia
- Cuenta cuántas palabras del usuario coinciden con palabras conocidas.
- Verifica si están presentes las palabras obligatorias (required_words).
- Calcula el porcentaje de coincidencia: (palabras_reconocidas / total_palabras) × 100.
- Retorna la probabilidad (0-100).

### Paso 3: Selección de Respuesta
- Evalúa todas las respuestas disponibles en la base de datos.
- Selecciona la respuesta con mayor probabilidad de coincidencia.
- Si ninguna supera el umbral del 20%, usa respuesta genérica aleatoria.


## Instalación

### Requisitos Previos
- Python 3.6 o superior
- No se requieren dependencias externas

### Pasos de Instalación
```bash
# 1. Clonar el repositorio
git clone https://github.com/GilbertoHernandez150/Portafolio/tree/main/Python/ChatBot
cd ChatBot

# 2. Verificar instalación de Python
python --version

# 3. Ejecutar el chatbot
python chatbot.py
```


## Uso del Sistema

### Ejecutar el Chatbot
```bash
python chatbot.py
```

### Ejemplo de Interacción
```
Bot: ¡Hola! Soy el chatbot del ITLA. ¿En qué puedo ayudarte?
Tú: ¿Qué carreras ofrece el ITLA?

Bot: El ITLA ofrece las siguientes carreras técnicas:
     - Desarrollo de Software
     - Redes y Telecomunicaciones
     - Multimedia
     - Mecatrónica
     - Y más...

Tú: ¿Dónde está ubicado?

Bot: El ITLA está ubicado en la Autopista Las Américas, 
     Km 27, La Caleta, Boca Chica, República Dominicana.
```

### Comandos Especiales
- salir / exit / quit → Termina el programa.
- Cualquier pregunta sobre el ITLA → Respuesta del bot.

---

**Desarrollado por: Gilberto Hernández**
