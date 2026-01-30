--==========================================================================================================
--4 - En esta sección haremos la parte de las Vistas, Procedimientos Almacenados, Funciones y Triggers =====
--==========================================================================================================

--Nota: Se pueden crear todas las vistas, procedimientos Almacenados, Funciones y Triggers necesarios.

--Vistas=========================================================================================

--Vista para mostrar todos los vuelos con sus proveedores
create view VistaVuelosProveedores as
select Vuelos.*, Proveedores.Nombre as NombreProveedor 
from Vuelos
join Proveedores on Vuelos.ProveedorID = Proveedores.ProveedorID;
go

--Vista para mostrar todas las reservas junto con los detalles de los usuarios
create view VistaReservasUsuarios as
select Reservas.*, Usuarios.Nombre, Usuarios.Correo 
from Reservas
join Usuarios on Reservas.UsuarioID = Usuarios.UsuarioID;
go

--Vista para mostrar los hoteles con disponibilidad y sus proveedores
create view VistaHotelesDisponibles as
select Hoteles.*, Proveedores.Nombre as NombreProveedor 
from Hoteles
join Proveedores on Hoteles.ProveedorID = Proveedores.ProveedorID
where Hoteles.Disponibilidad > 0;
go

--Vista para mostrar los detalles de las transacciones con sus reservas
create view VistaTransaccionesReservas as
select Transacciones.*, Reservas.FechaReserva, Reservas.Estado 
from Transacciones
join Reservas on Transacciones.ReservaID = Reservas.ReservaID;
go

--Funciones==========================================================================================

--Función para calcular el precio total de una estancia en un hotel
create function CalcularPrecioEstancia
    (@HotelID int, @Noches int)
returns decimal(10, 2)
as
begin
    declare @Precio decimal(10, 2);
    select @Precio = PrecioPorNoche from Hoteles where HotelID = @HotelID;
    return @Precio * @Noches;
end;
go

--Función para obtener el nombre de un proveedor por su ID
create function ObtenerNombreProveedor
    (@ProveedorID int)
returns varchar(100)
as
begin
    declare @Nombre varchar(100);
    select @Nombre = Nombre from Proveedores where ProveedorID = @ProveedorID;
    return @Nombre;
end;
go

--Función para calcular la duración de un vuelo en horas
create function CalcularDuracionVuelo
    (@VueloID int)
returns decimal(10, 2)
as
begin
    declare @Duracion decimal(10, 2);
    select @Duracion = datediff(minute, FechaHoraSalida, FechaHoraLlegada) / 60.0
    from Vuelos where VueloID = @VueloID;
    return @Duracion;
end;
go

--Función para obtener el tipo de transacción por ID de transacción
create function ObtenerTipoTransaccion
    (@TransaccionID int)
returns varchar(50)
as
begin
    declare @Tipo varchar(50);
    select @Tipo = Tipo from Transacciones where TransaccionID = @TransaccionID;
    return @Tipo;
end;
go

--Triggers===========================================================================================

--Trigger para auditar inserciones en la tabla Reservas
create trigger AuditarInsercionReservas
on Reservas
after insert
as
begin
    insert into Auditoria (Accion, Tabla, Fecha, Detalles)
    values ('insert', 'Reservas', getdate(), (select * from inserted for xml auto));
end;
go

--Trigger para actualizar la disponibilidad de un hotel después de una reserva
create trigger ActualizarDisponibilidadHotelTrigger
on Reservas
after insert
as
begin
    declare @HotelID int;
    declare @DisponibilidadActual int;

    --Obtenemos el HotelID relacionado con la reserva
    select @HotelID = (select HotelID from Hoteles where ProveedorID = i.UsuarioID)
    from inserted i
    where i.Estado = 'confirmada';

    --Si se encuentra un HotelID, actualizamos la disponibilidad
    if @HotelID is not null
    begin
        select @DisponibilidadActual = Disponibilidad from Hoteles where HotelID = @HotelID;
        update Hoteles
        set Disponibilidad = @DisponibilidadActual - 1
        where HotelID = @HotelID;
    end
end;
go

--Trigger para asegurar que el precio de un vuelo no sea negativo
create trigger ValidarPrecioVuelo
on Vuelos
after insert, update
as
begin
    if exists (select * from inserted where Precio < 0)
    begin
        raiserror('El precio del vuelo no puede ser negativo', 16, 1);
        rollback transaction;
    end
end;
go

--Trigger para registrar transacciones
create trigger RegistrarTransaccion
on Transacciones
after insert
as
begin
    declare @ReservaID int;
    select @ReservaID = ReservaID from inserted;

    if @ReservaID is not null
    begin
        insert into Auditoria (Accion, Tabla, Fecha, Detalles)
        values ('insert', 'Transacciones', getdate(), 
                (select * from inserted for xml auto));
    end
end;
go