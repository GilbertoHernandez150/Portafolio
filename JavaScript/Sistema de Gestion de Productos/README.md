# Sistema de Gestión de Productos
> Nota: Imagenes del software en la documentacion que se encuentra en la carpeta docs.

## Descripción General
Este proyecto consiste en el desarrollo de una aplicación web funcional diseñada para simular un entorno administrativo de gestión de productos, control de acceso de usuarios y visualización de estadísticas mediante un dashboard interactivo.

El sistema fue desarrollado con tecnologías base (HTML, CSS y JavaScript) aplicando principios de organización de código, separación de responsabilidades y arquitectura modular, con el propósito de servir tanto como evidencia académica como pieza de portafolio.

El sistema se compone de:
- **Frontend (Interfaz Web):** construido con HTML, CSS y JavaScript, organizado en módulos independientes para autenticación, gestión de productos, pagos y dashboard.
- **Pruebas Automatizadas:** desarrolladas con Python y Selenium para validar el correcto funcionamiento de la interfaz.

---

## Objetivos
- Desarrollar una aplicación web funcional para la gestión básica de productos.
- Implementar una interfaz web organizada y usable con separación de responsabilidades.
- Simular un proceso de autenticación de usuarios con redirección al dashboard.
- Gestionar productos mediante JavaScript (agregar, editar, eliminar).
- Mostrar estadísticas generales en un panel de control administrativo.
- Aplicar pruebas automatizadas utilizando Selenium para validar la interfaz.

---

## Funcionalidades Clave
- **Módulo de Autenticación:**  
  Simula el inicio de sesión de un usuario administrador, valida el formulario y redirige al dashboard tras ingresar credenciales correctas.

- **Módulo de Gestión de Productos:**  
  Permite agregar, editar y eliminar productos. La lógica está encapsulada en un módulo independiente para mantener el orden del código.

- **Módulo de Simulación de Pagos:**  
  Simula el proceso de pago de un producto mostrando el total con IVA incluido antes de confirmar la transacción.

- **Dashboard Administrativo:**  
  Muestra información general como total de productos, fecha y hora del último acceso y estadísticas simuladas de ventas. Incluye opciones para limpiar datos y cerrar sesión.

- **Pruebas Automatizadas:**  
  El sistema cuenta con pruebas desarrolladas en Selenium que abren la aplicación automáticamente, validan la carga de las páginas y capturan evidencias visuales mediante screenshots.

---

## Tecnologías Utilizadas
### Frontend
- **HTML5** → Estructura de las vistas.
- **CSS3** → Diseño visual y estilos.
- **JavaScript (Vanilla JS)** → Lógica del sistema y manipulación del DOM.

### Pruebas
- **Python** → Lenguaje base para las pruebas automatizadas.
- **Selenium WebDriver** → Automatización y validación de la interfaz.

---

## Arquitectura del Sistema
El proyecto está organizado bajo una arquitectura modular orientada a la claridad y mantenibilidad:

```
src/
├── css/        → Hojas de estilo
├── js/         → Lógica organizada por módulos
└── pages/      → Vistas HTML del sistema

tests/          → Pruebas automatizadas con Selenium
docs/           → Documentación técnica del proyecto
```

---

## Flujo de la Aplicación
1. El usuario accede a la página principal.
2. Navega hacia el inicio de sesión e ingresa sus credenciales.
3. Al autenticarse correctamente, es redirigido al dashboard.
4. Desde el dashboard visualiza estadísticas y accede a la gestión de productos.
5. Puede agregar, editar, eliminar productos y simular pagos.
6. Al finalizar, puede cerrar sesión y regresar al inicio.

---

## Autor
**Gilberto Hernández**  
Estudiante de Desarrollo de Software
