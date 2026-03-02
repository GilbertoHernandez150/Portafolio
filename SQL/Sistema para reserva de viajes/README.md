# Sistema de Reservas de Viajes - Dominican Fast Travel Agency
> Nota: Imagenes en la documentacion.

## Descripción General
Este proyecto consiste en el desarrollo de una base de datos completa para la agencia de viajes dominicana **Dominican Fast Travel Agency**, diseñada para gestionar reservas de vuelos, hoteles, automóviles y paquetes turísticos de forma centralizada y eficiente.

El sistema surge con el propósito de modernizar los procesos de reserva de la agencia, garantizando seguridad, fiabilidad y trazabilidad en cada operación. La base de datos está implementada en tres tecnologías diferentes para cubrir distintos casos de uso.

El sistema se compone de:
- **SQL Server (Relacional):** base de datos principal con tablas, consultas avanzadas, vistas, funciones, triggers y procedimientos almacenados.
- **MongoDB (NoSQL):** implementación no relacional para almacenamiento de datos en formato de documentos JSON.
- **Redis (In-Memory):** implementación en memoria para acceso rápido a datos en tiempo real.

> 📌 Este proyecto fue desarrollado como proyecto final de la materia **Base de Datos Avanzada** en el ITLA.

---

## Objetivos
- Diseñar y desarrollar una base de datos para gestionar reservas de vuelos, hoteles, automóviles y paquetes turísticos.
- Implementar consultas avanzadas, vistas, funciones, triggers y procedimientos almacenados en SQL Server.
- Replicar la base de datos en MongoDB y Redis para comparar enfoques relacionales y no relacionales.
- Garantizar integridad referencial entre las tablas mediante claves primarias y foráneas.
- Automatizar procesos mediante triggers de auditoría, validación y actualización de disponibilidad.

---

## Funcionalidades Clave
- **Gestión de Usuarios y Proveedores:**  
  Registro de usuarios del sistema y proveedores de servicios (aerolíneas, hoteles, rentadoras y paquetes turísticos).

- **Reservas y Transacciones:**  
  Registro de reservas por usuario con estados (confirmada, pendiente, cancelada) y transacciones de pago asociadas por tipo (vuelo, hotel, automóvil, paquete).

- **Consultas Avanzadas:**  
  Incluye consultas para obtener reservas por usuario, vuelos disponibles entre ciudades, disponibilidad de hoteles y automóviles, total de ingresos y precio promedio por proveedor.

- **Vistas:**  
  Vistas preconstruidas de vuelos con proveedores, reservas con usuarios, hoteles disponibles y transacciones con reservas.

- **Funciones:**  
  Cálculo del precio total de estancia en hotel, duración de vuelos en horas, nombre de proveedor por ID y tipo de transacción.

- **Triggers:**  
  Auditoría de inserciones en reservas, actualización automática de disponibilidad de hotel tras una reserva, validación de precios no negativos en vuelos y registro de transacciones en tabla de auditoría.

- **Implementación en MongoDB:**  
  Colecciones equivalentes a las tablas SQL para almacenamiento de datos no estructurados en formato JSON.

- **Implementación en Redis:**  
  Almacenamiento de datos en memoria como strings con ID específico para acceso en tiempo real.

---

## Tecnologías Utilizadas
### Base de Datos Relacional
- **SQL Server** → Motor principal de base de datos relacional.
- **T-SQL** → Lenguaje para consultas, funciones, triggers y procedimientos almacenados.

### Base de Datos No Relacional
- **MongoDB** → Almacenamiento de datos en documentos JSON.
- **MongoDB Compass** → Herramienta visual para gestión de colecciones.

### Base de Datos en Memoria
- **Redis** → Almacenamiento clave-valor en tiempo real.

---

## Estructura de la Base de Datos

| Tabla | Descripción |
|---|---|
| `Usuarios` | Datos de los usuarios del sistema |
| `Proveedores` | Aerolíneas, hoteles, rentadoras y paquetes |
| `Vuelos` | Vuelos disponibles por proveedor |
| `Hoteles` | Hoteles con ubicación, precio y disponibilidad |
| `Automoviles` | Vehículos disponibles para alquiler |
| `PaquetesTuristicos` | Paquetes turísticos por proveedor |
| `Reservas` | Reservas realizadas por los usuarios |
| `Transacciones` | Pagos asociados a cada reserva |

**Relaciones principales:**
- Un **Proveedor** puede tener múltiples Vuelos, Hoteles, Automóviles y Paquetes (1 a N).
- Varias **Reservas** pueden estar relacionadas con un solo Usuario (N a 1).
- Cada **Transacción** está vinculada a una Reserva específica.

---

## Autores
**Gilberto Hernández** — Matrícula: 2023-1211  
**Joel de Jesús Oseliz Reynoso** — Matrícula: 2023-1132  

Estudiantes de Desarrollo de Software — ITLA  
Materia: Base de Datos Avanzada
