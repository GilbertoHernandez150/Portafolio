--Aquí hacemos la cración de la base de datos
create database SistemaReservasViajesBD;
go

--Aquí hacemos uso de la base de datos
use SistemaReservasViajesBD;
go

--==========================================================================================================
--1 - En esta sección haremos la creación de las tablas ====================================================
--==========================================================================================================

--Tabla Usuarios
create table Usuarios (
UsuarioID int identity (1,1) primary key,
Nombre varchar (100),
Correo varchar (100) unique,
Contraseña varchar (100),
Telefono varchar (100)
);
go

--Tabla Proveedores
create table Proveedores (
ProveedorID int identity (1,1) primary key,
Nombre varchar (100),
Tipo varchar (50),
Contacto varchar (100)
);
go

--Tabla Vuelos
create table Vuelos (
VueloID int identity (1,1) primary key,
ProveedorID int,
Origen varchar (100),
Destino varchar (100),
FechaHoraSalida datetime,
FechaHoraLlegada datetime,
Precio decimal (10,2),
foreign key (ProveedorID) references Proveedores (ProveedorID)
);
go

--Tabla Hoteles
create table Hoteles (
HotelID int identity (1,1) primary key,
ProveedorID int,
Nombre varchar (100),
Ubicacion varchar (100),
PrecioPorNoche decimal (10, 2),
Disponibilidad int,
foreign key (ProveedorID) references Proveedores (ProveedorID)
);
go

--Tabla Automóviles
create table Automoviles (
AutosID int identity (1,1) primary key,
ProveedorID int,
Marca varchar (50),
Modelo varchar (50),
PrecioPorDia decimal (10,2),
Disponibilidad int,
foreign key (ProveedorID) references Proveedores (ProveedorID)
);
go

--Tabla Paquetes Turísticos
create table PaquetesTuristicos (
PaqueteID int identity (1,1) primary key,
ProveedorID int,
Descripcion varchar (200),
Precio decimal (10,2),
Disponibilidad int,
foreign key (ProveedorID) references Proveedores (ProveedorID)
);
go

--Tabla Reservas
create table Reservas (
ReservaID int identity (1,1) primary key,
UsuarioID int,
FechaReserva datetime,
Estado varchar (50),
foreign key (UsuarioID) references Usuarios (UsuarioID),
);
go

--Tabla Transacciones
create table Transacciones (
TransaccionID int identity (1,1) primary key,
ReservaID int,
Monto decimal (10, 2),
FechaTransaccion datetime,
Tipo varchar (50),
foreign key (ReservaID) references Reservas (ReservaID)
);
go
