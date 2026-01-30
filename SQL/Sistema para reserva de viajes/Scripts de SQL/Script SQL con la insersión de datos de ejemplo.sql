--==========================================================================================================
--2 - En esta sección haremos la insersión de los datos en las tablas ======================================
--==========================================================================================================

--Insersión de datos en la tabla Usuarios
insert into Usuarios (Nombre, Correo, Contraseña, Telefono) values 
('Josefina Montes','josefinamontes@gmail.com','contraseña1','809-000-0000'),
('Juan Perez', 'juanperez@gmail.com','contraseña2','809-111-1111'),
('Maria Lopez','marialopez@gmail.com','contraseña3','809-222-2222'),
('Carlos Rivera','carlosrivera@gmail.com','contraseña4','809-333-3333'),
('Ana Torres','anatorres@gmail.com','contraseña5','809-444-4444'),
('Pedro Martinez','pedromartinez@gmail.com','contraseña6','809-555-5555'),
('Pablo Cabrera','pablocabrera@gmail.com','contraseña7','809-666-6666'),
('Martina Gonzales','martinagonzales@gmail.com','contraseña8','809-777-7777'),
('Armando Matos','armandomatos@gmail.com','contraseña9','809-888-8888'),
('Lucas Jimenez','lucasjimenez@gmail.com','contraseña10','809-999-9999'),
('Luz Gonzalez','luzgonzalez@gmail.com','contraseña11','829-000-0000'),
('Erika Fernandez','erikafernandez@gmail.com','contraseña12','829-111-1111'),
('Victor Alvarez','victoralvarez@gmail.com','contraseña13','829-222-2222'),
('Sofia Castillo','sofiacastillo@gmail.com','contraseña14','829-333-3333'),
('Diego Herrera','diegoherrera@gmail.com','contraseña15','829-444-4444'),
('Camila Ortiz','camilaortiz@gmail.com','contraseña16','829-555-5555'),
('Ricardo Soto','ricardosoto@gmail.com','contraseña17','829-666-6666'),
('Natalia Reyes','nataliareyes@gmail.com','contraseña18','829-777-7777'),
('Luis Paredes','luisparedes@gmail.com','contraseña19','829-888-8888'),
('Santiago Mendez','santiagomendez@gmail.com','contraseña20','829-999-9999'),
('Gabriel Vargas','gabrielvargas@gmail.com','contraseña21','849-000-0000'),
('Elena Martinez','elenamartinez@gmail.com','contraseña22','849-111-1111'),
('David Ramirez','davidramirez@gmail.com','contraseña23','849-222-2222'),
('Isabel Pena','isabelpena@gmail.com','contraseña24','849-333-3333'),
('Miguel Rios','miguelrios@gmail.com','contraseña25','849-444-4444'),
('Paola Suarez','paolasuarez@gmail.com','contraseña26','849-555-5555'),
('Juan Carlos Diaz','juancarlosdiaz@gmail.com','contraseña27','849-666-6666'),
('Laura Espinal','lauraespinal@gmail.com','contraseña28','849-777-7777'),
('Esteban Luna','estebanluna@gmail.com','contraseña29','849-888-8888'),
('Valentina Guzman','valentinaguzman@gmail.com','contraseña30','849-999-9999');
go

--Insersión de datos en la tabla Proveedores
insert into Proveedores (Nombre, Tipo, Contacto) values
--Aerolínas
('Air Century','aerolinea','aircentury.com'),
('Sky High Aviation Services','aerolinea','skyhighdo.com'),
('American Airlines','aerolinea','aa.com'),
('Delta Air Lines','aerolinea','delta.com'),
('JetBlue Airways','aerolinea','jetblue.com'),
--Hoteles
('Casa de Campo Resort & Villas','hotel','casadecampo.com'),
('Excellence Punta Cana','hotel','excellenceresorts.com'),
('Hard Rock Hotel & Casino Punta Cana','hotel','hardrock.com'),
('Paradisus Palma Real Golf & Spa Resort','hotel','melia.com'),
('Santuary Cap Cana','hotel','melia.com'),
--RentaCars
('Avis Rent a Car','automovil','avis.com'),
('Budget Rent a Car','automovil','budget.com'),
('Hertz Rent a Car','automovil','hertz.com'),
('Europcar','automovil','europcar.com'),
('National Car Rental','automovil','nationalcar.com'),
--Paquetes
('Los 3 ojos Playa Santo Domingo, cenote y Cueva','paquete','viator.com'),
('Recorrido en bicicleta por la zona colonial','paquete','booking.com'),
('Relax en Samaná','paquete','viator.com'),
('Experiencia Todo Incluido en Puerto Plata','paquete','booking.com'),
('Paquete de Golf en Casa de Campo','paquete','booking.com');
go

--Insersión de datos en la tabla Vuelos
insert into Vuelos (ProveedorID, Origen, Destino, FechaHoraSalida, FechaHoraLlegada, Precio) values
(1, 'Puerto Rico', 'Republica Dominicana', '2024-07-20T08:00:00', '2024-07-20T10:00:00', 200.00),
(2, 'España', 'Republica Dominicana', '2024-08-15T09:00:00', '2024-08-15T15:00:00', 800.00),
(3, 'Londres', 'Republica Dominicana', '2024-12-10T12:00:00', '2024-12-10T20:00:00', 2000.00),
(4, 'Mexico', 'Republica Dominicana', '2024-04-08T12:00:00', '2024-04-08T16:00:00', 500.00),
(5, 'Francia', 'Republica Dominicana', '2024-06-08T04:00:00', '2024-06-08T16:00:00', 1500.00),
(1, 'Argentina', 'Republica Dominicana', '2024-09-01T10:00:00', '2024-09-01T22:00:00', 1200.00),
(2, 'Chile', 'Republica Dominicana', '2024-10-05T09:00:00', '2024-10-05T19:00:00', 900.00),
(3, 'Colombia', 'Republica Dominicana', '2024-11-10T14:00:00', '2024-11-10T18:00:00', 600.00),
(4, 'Panamá', 'Republica Dominicana', '2024-12-15T07:00:00', '2024-12-15T09:00:00', 350.00),
(5, 'Venezuela', 'Republica Dominicana', '2024-08-20T12:00:00', '2024-08-20T16:00:00', 800.00),
(1, 'Brasil', 'Republica Dominicana', '2024-09-25T06:00:00', '2024-09-25T18:00:00', 1500.00),
(2, 'Ecuador', 'Republica Dominicana', '2024-10-30T11:00:00', '2024-10-30T17:00:00', 700.00),
(3, 'Perú', 'Republica Dominicana', '2024-11-14T13:00:00', '2024-11-14T21:00:00', 1100.00),
(4, 'Uruguay', 'Republica Dominicana', '2024-12-19T15:00:00', '2024-12-20T01:00:00', 1300.00),
(5, 'Bolivia', 'Republica Dominicana', '2024-08-22T08:00:00', '2024-08-22T15:00:00', 900.00),
(1, 'Paraguay', 'Republica Dominicana', '2024-09-27T16:00:00', '2024-09-27T22:00:00', 1000.00),
(2, 'Costa Rica', 'Republica Dominicana', '2024-10-03T07:00:00', '2024-10-03T11:00:00', 500.00),
(3, 'Cuba', 'Republica Dominicana', '2024-11-08T10:00:00', '2024-11-08T13:00:00', 400.00),
(4, 'Honduras', 'Republica Dominicana', '2024-12-12T18:00:00', '2024-12-12T23:00:00', 750.00),
(5, 'Guatemala', 'Republica Dominicana', '2024-08-29T05:00:00', '2024-08-29T10:00:00', 600.00),
(1, 'El Salvador', 'Republica Dominicana', '2024-09-19T12:00:00', '2024-09-19T17:00:00', 650.00),
(2, 'Nicaragua', 'Republica Dominicana', '2024-10-15T14:00:00', '2024-10-15T20:00:00', 700.00),
(3, 'Belice', 'Republica Dominicana', '2024-11-21T06:00:00', '2024-11-21T11:00:00', 500.00),
(4, 'Barbados', 'Republica Dominicana', '2024-12-28T13:00:00', '2024-12-28T15:00:00', 350.00),
(5, 'Jamaica', 'Republica Dominicana', '2024-08-05T10:00:00', '2024-08-05T12:00:00', 400.00),
(1, 'Trinidad y Tobago', 'Republica Dominicana', '2024-09-11T09:00:00', '2024-09-11T11:00:00', 450.00),
(2, 'Guyana', 'Republica Dominicana', '2024-10-20T11:00:00', '2024-10-20T17:00:00', 700.00),
(3, 'Surinam', 'Republica Dominicana', '2024-11-27T15:00:00', '2024-11-27T19:00:00', 600.00),
(4, 'Islas Vírgenes', 'Republica Dominicana', '2024-12-22T13:00:00', '2024-12-22T15:00:00', 300.00),
(5, 'Italia', 'Republica Dominicana', '2024-02-24T15:00:00', '2024-02-25T00:00:00', 600.00);
go

--Insersión de datos en la tabla Hoteles
insert into Hoteles (ProveedorID, Nombre, Ubicacion, PrecioPorNoche, Disponibilidad) values
(6, 'Casa de Campo Resort & Villas', 'La Romana', 100.00, 30),
(7, 'Excellence Punta Cana', 'Punta Cana', 150.00, 25),
(8, 'Hard Rock Hotel & Casino Punta Cana', 'PuntaCana', 200.00, 20),
(9, 'Paradisus Palma Real Golf & Spa Resort', 'Punta Cana', 250.00, 15),
(10, 'Santuary Cap Cana', 'Punta Cana', 300.00, 10);
go

--Insersión de datos en la tabla Automóviles
insert into Automoviles (ProveedorID, Marca, Modelo, PrecioPorDia, Disponibilidad) values
(11, 'BMW', 'X5', 250.00, 5),
(12, 'Polaris', 'Sportman 570', 100.00, 5),
(13, 'Jeep', 'Wrangler', 200.00, 6),
(14, 'Toyota', 'Hiace', 400.00, 5),
(15, 'Mercedes-Benz', 'Sprinter Minibus', 500.00, 5),
(11, 'Ford', 'Escape', 150.00, 8),
(12, 'Chevrolet', 'Suburban', 270.00, 6),
(13, 'Volkswagen', 'Atlas', 250.00, 7),
(14, 'Subaru', 'Forester', 160.00, 9),
(15, 'Hyundai', 'Kona', 140.00, 10),
(11, 'Nissan', 'Murano', 190.00, 8),
(12, 'Land Rover', 'Discovery', 300.00, 5),
(13, 'Audi', 'Q5', 220.00, 7),
(14, 'Kia', 'Telluride', 280.00, 4),
(15, 'Honda', 'CR-V', 180.00, 9),
(11, 'Jeep', 'Grand Cherokee', 260.00, 6),
(12, 'Toyota', '4Runner', 240.00, 5),
(13, 'GMC', 'Acadia', 210.00, 8),
(14, 'Ram', '2500', 240.00, 4),
(15, 'Chrysler', 'Voyager', 230.00, 6),
(11, 'Ford', 'Transit Connect', 200.00, 7),
(12, 'Mitsubishi', 'Outlander', 170.00, 8),
(13, 'Buick', 'Envision', 190.00, 7),
(14, 'Lexus', 'GX', 290.00, 5),
(15, 'Mazda', 'CX-5', 200.00, 8),
(11, 'Porsche', 'Macan', 330.00, 4),
(12, 'Land Rover', 'Evoque', 280.00, 6),
(13, 'Nissan', 'Armada', 300.00, 3),
(14, 'Chevrolet', 'Colorado', 190.00, 8),
(15, 'Jeep', 'Gladiator', 220.00, 7);
go

--Insersión de datos en la tabla Paquetes
insert into PaquetesTuristicos (ProveedorID, Descripcion, Precio, Disponibilidad) values
(16, 'Los 3 ojos Playa Santo Domingo', 500.00, 3),
(17, 'Recorrido en bicicleta por la zona colonial', 600.00, 6),
(18, 'Relax en Samana', 700.00, 9),
(19, 'Experiencia Todo Incluido en Puerto Plata', 800.00, 12),
(20, 'Paquete de Golf en Casa de Campo', 900.00, 15);
go

--Insersión de datos en la tabla Reservas
insert into Reservas (UsuarioID, FechaReserva, Estado) values
(1, '2024-07-20T10:30:00', 'confirmada'),
(2, '2024-07-21T17:45:00', 'pendiente'),
(3, '2024-07-22T08:00:00', 'cancelada'),
(4, '2024-07-23T20:40:00', 'confirmada'),
(5, '2024-07-23T12:20:00', 'piendiente'),
(6, '2024-07-24T09:15:00', 'confirmada'),
(7, '2024-07-25T14:30:00', 'pendiente'),
(8, '2024-07-26T16:00:00', 'confirmada'),
(9, '2024-07-27T11:45:00', 'cancelada'),
(10, '2024-07-28T18:00:00', 'confirmada'),
(11, '2024-07-29T10:30:00', 'pendiente'),
(12, '2024-07-30T15:00:00', 'confirmada'),
(13, '2024-07-31T17:15:00', 'cancelada'),
(14, '2024-08-01T13:30:00', 'confirmada'),
(15, '2024-08-02T19:00:00', 'pendiente'),
(16, '2024-08-03T09:45:00', 'confirmada'),
(17, '2024-08-04T16:30:00', 'cancelada'),
(18, '2024-08-05T12:00:00', 'confirmada'),
(19, '2024-08-06T14:15:00', 'pendiente'),
(20, '2024-08-07T20:30:00', 'confirmada'),
(21, '2024-08-08T10:00:00', 'cancelada'),
(22, '2024-08-09T17:30:00', 'confirmada'),
(23, '2024-08-10T08:45:00', 'pendiente'),
(24, '2024-08-11T18:15:00', 'confirmada'),
(25, '2024-08-12T13:00:00', 'cancelada'),
(26, '2024-08-13T15:30:00', 'confirmada'),
(27, '2024-08-14T19:45:00', 'pendiente'),
(28, '2024-08-15T11:00:00', 'confirmada'),
(29, '2024-08-16T16:15:00', 'cancelada'),
(30, '2024-08-17T10:30:00', 'confirmada');
go

--Insersión de datos en la tabla Transacciones
insert into Transacciones (ReservaID, Monto, FechaTransaccion, Tipo) values
(1, 200.00, '2024-07-20T05:00:00', 'vuelo'),
(2, 100.00, '2024-07-21T10:00:00', 'hotel'),
(3, 300.00, '2024-07-22T11:00:00', 'paquete'),
(4, 150.00, '2024-07-23T15:00:00', 'automovil'),
(5, 250.00, '2024-07-24T09:00:00', 'vuelo'),
(6, 120.00, '2024-07-25T14:00:00', 'hotel'),
(7, 350.00, '2024-07-26T16:00:00', 'paquete'),
(8, 200.00, '2024-07-27T12:00:00', 'automovil'),
(9, 275.00, '2024-07-28T18:00:00', 'vuelo'),
(10, 150.00, '2024-07-29T10:30:00', 'hotel'),
(11, 400.00, '2024-07-30T15:00:00', 'paquete'),
(12, 180.00, '2024-07-31T13:00:00', 'automovil'),
(13, 220.00, '2024-08-01T09:00:00', 'vuelo'),
(14, 130.00, '2024-08-02T14:00:00', 'hotel'),
(15, 330.00, '2024-08-03T16:00:00', 'paquete'),
(16, 210.00, '2024-08-04T12:00:00', 'automovil'),
(17, 260.00, '2024-08-05T19:00:00', 'vuelo'),
(18, 140.00, '2024-08-06T10:30:00', 'hotel'),
(19, 350.00, '2024-08-07T15:00:00', 'paquete'),
(20, 190.00, '2024-08-08T13:00:00', 'automovil'),
(21, 240.00, '2024-08-09T09:00:00', 'vuelo'),
(22, 160.00, '2024-08-10T14:00:00', 'hotel'),
(23, 370.00, '2024-08-11T16:00:00', 'paquete'),
(24, 200.00, '2024-08-12T12:00:00', 'automovil'),
(25, 280.00, '2024-08-13T18:00:00', 'vuelo'),
(26, 150.00, '2024-08-14T10:30:00', 'hotel'),
(27, 340.00, '2024-08-15T15:00:00', 'paquete'),
(28, 220.00, '2024-08-16T13:00:00', 'automovil'),
(29, 260.00, '2024-08-17T09:00:00', 'vuelo'),
(30, 170.00, '2024-08-18T14:00:00', 'hotel');
go
