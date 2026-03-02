# Sistema Web de Gestión de Multas de Tránsito
> Nota: Imagenes del software en la documentacion que se encuentra en la carpeta docs.


## Descripción General
Este proyecto consiste en el desarrollo de una plataforma web diseñada para optimizar el registro, control y administración de infracciones viales mediante herramientas digitales accesibles desde el navegador.

El sistema surge con el propósito de modernizar los procesos tradicionales utilizados por agentes de tránsito y personal administrativo, reduciendo el uso de métodos manuales y facilitando la centralización de la información.

La aplicación permite registrar multas en tiempo real, administrar agentes del sistema, gestionar conceptos de infracciones, visualizar ubicaciones geográficas en mapas interactivos y generar reportes relacionados con ingresos y comisiones.

El sistema se compone de:
- **Backend (Lógica de negocio):** desarrollado en Blazor (.NET), encargado de gestionar la autenticación, el procesamiento de datos y la exposición de resultados.
- **Frontend (Interfaz Web):** construido con Blazor WebAssembly, para la visualización de registros, mapas interactivos y reportes.
- **Base de Datos Centralizada:** gestiona usuarios, roles, multas, evidencias, conceptos e ingresos.


---

## Objetivos
- Desarrollar una plataforma web para gestionar eficientemente el proceso de registro y administración de multas de tránsito.
- Facilitar el trabajo operativo de los agentes mediante herramientas digitales centralizadas.
- Mejorar el control administrativo con supervisión de agentes y generación de reportes.
- Visualizar geográficamente las incidencias registradas en mapas interactivos.
- Gestionar conceptos de infracciones con montos definidos por la administración.

---

## Funcionalidades Clave
- **Autenticación de Usuarios:**  
  Inicio de sesión seguro, registro de usuarios, recuperación de contraseña y control de acceso por roles.

- **Registro de Multas:**  
  Permite ingresar datos del ciudadano, concepto de infracción, descripción, agente responsable, fecha, ubicación geográfica (latitud/longitud) y evidencia fotográfica.

- **Listado y Gestión de Multas:**  
  Visualización, edición y eliminación de registros con identificación del agente responsable.

- **Mapa Geográfico de Infracciones:**  
  Visualización de multas en un mapa interactivo con ubicación precisa de las incidencias e información detallada por registro.

- **Reportes de Ingresos y Comisiones:**  
  Cálculo de ingresos mensuales, historial de multas procesadas y seguimiento del rendimiento de agentes.

- **Gestión de Agentes:**  
  Registro, edición, control de acceso y activación o desactivación de agentes.

- **Gestión de Conceptos de Multas:**  
  Creación de infracciones, definición de montos, edición, eliminación y listado de conceptos.

---

## Tipos de Usuarios y Roles
### Agente de Tránsito
Responsable del registro y seguimiento de infracciones.
- Registrar multas.
- Consultar historial de multas.
- Visualizar mapa de incidencias.
- Subir evidencias fotográficas.
- Consultar comisiones mensuales.

### Administrador / Oficina Central
Responsable del control general del sistema.
- Gestionar agentes.
- Administrar conceptos de multas.
- Supervisar registros.
- Generar reportes de ingresos.
- Activar y desactivar usuarios.

---

## Tecnologías Utilizadas
### Backend
- **Blazor (.NET / C#)** → Framework principal para la lógica del servidor y renderizado de componentes.

### Frontend
- **Blazor WebAssembly** → Interfaz de usuario interactiva basada en componentes.

### Base de Datos
- **Base de datos centralizada** → Gestiona usuarios, roles, agentes, multas, evidencias, conceptos e ingresos.

### Otros
- Integración con servicios de mapas (Leaflet / OpenStreetMap) para visualización geográfica.
- Control de acceso basado en roles (Agente / Administrador).
- Almacenamiento de evidencia fotográfica por multa.

---

## Arquitectura del Sistema
El sistema está estructurado bajo una arquitectura web modular compuesta por:
- Interfaz de usuario (Frontend con Blazor).
- Lógica de negocio (Backend .NET).
- Base de datos centralizada.
- Integración con servicios de mapas.

---

## Base de Datos
La base de datos gestiona las siguientes entidades:
- Usuarios y roles.
- Agentes.
- Multas registradas.
- Evidencias fotográficas.
- Conceptos de infracciones.
- Reportes e ingresos.

---

## Alcance del Sistema
- Registro de infracciones de tránsito.
- Administración de usuarios y agentes.
- Gestión de conceptos de multas.
- Visualización geográfica de incidencias.
- Generación de reportes de ingresos.
- Control y seguimiento de operaciones.

---

## Problemática que Resuelve
- Procesos manuales de registro de multas.
- Falta de centralización de información.
- Dificultad para supervisar agentes.
- Ausencia de visualización geográfica de incidencias.
- Limitado control sobre ingresos y reportes.
