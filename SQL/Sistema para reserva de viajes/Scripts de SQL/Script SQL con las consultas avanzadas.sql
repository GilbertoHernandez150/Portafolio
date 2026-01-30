--==========================================================================================================
--3 - En esta sección haremos las consultas avanzadas ======================================================
--==========================================================================================================

--Nota: Se pueden agregar más consultas en caso de ser necesario

--Consulta para obtener las reservas de un usuario específico
select * from Reservas where UsuarioID = 1;
go

--Consulta para obtener los vuelos disponibles entre dos ciudades en una fecha específica
select * from Vuelos where Origen = 'Republica Dominicana' and Destino = 'Puerto Rico' and 
cast(FechaHoraSalida as date) = '2024-07-20';
go

--Consulta para obtener la disponibilidad de hoteles en una ubicación específica
select * from Hoteles where Ubicacion = 'La Romana' and Disponibilidad > 0;
go

--Consulta para obtener el total de ingresos por reservas de un usuario específico
select sum(Transacciones.Monto) as TotalIngresos from Transacciones join 
Reservas on Transacciones.ReservaID = Reservas.ReservaID where 
Reservas.UsuarioID = 1;
go

--Consulta para obtener la disponibilidad de automoviles en una ubicación específica
select * from Automoviles where Marca = 'BMW' and Disponibilidad > 0;
go

--Consulta para obtener todas las transacciones de un tipo específico
select * from Transacciones where Tipo = 'vuelo';
go

--Consulta para obtener el total de reservas por estado
select Estado, count(*) as TotalReservas from Reservas group by Estado;
go

--Consulta para obtener los proveedores que ofrecen paquetes turísticos
select * from Proveedores where Tipo = 'paquete';
go

--Consulta para obtener el precio promedio de vuelos por proveedor
select ProveedorID, avg(Precio) as PrecioPromedio from Vuelos group by 
ProveedorID;
go

--Consulta para obtener los detalles de las reservas junto con los usuarios que las realizaron
select Reservas.*, Usuarios.Nombre from Reservas join Usuarios on 
Reservas.UsuarioID = Usuarios.UsuarioID;
go