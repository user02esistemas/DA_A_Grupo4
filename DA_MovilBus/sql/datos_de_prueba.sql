-- ============================================================
-- SCRIPT DE DATOS DE PRUEBA - MOVILBUS
-- ============================================================
-- Ejecutar UNA SOLA VEZ en SQL Server Management Studio (SSMS)
-- Despues de haber creado las tablas con el script de la BD.
--
-- ORDEN: Primero se ELIMINAN todos los registros (hijos antes que
-- padres para respetar FK), luego se INSERTAN (padres antes que hijos).
-- ============================================================

USE MovilBusDB;
GO

-- ============================================================
-- FASE 1: LIMPIAR DATOS EXISTENTES (orden inverso de dependencias)
-- ============================================================
DELETE FROM Transaccion_Puntos;
DELETE FROM Puntos_Cliente;
DELETE FROM Nivel_Fidelidad;
DELETE FROM Encomienda_Estado;
DELETE FROM Encomienda;
DELETE FROM Cita_Encomienda;
DELETE FROM Viaje_Conductor;
DELETE FROM Pasaje;
DELETE FROM Pago;
DELETE FROM Viaje;
DELETE FROM Bus_Asiento;
DELETE FROM Bus;
DELETE FROM Ruta;
DELETE FROM Conductores;
DELETE FROM Cliente;
DELETE FROM Usuarios;
DELETE FROM Servicio;
DELETE FROM Roles;
DELETE FROM Tipo_Asiento;
DELETE FROM Ciudades;
GO

PRINT 'Datos existentes eliminados correctamente.';
GO

-- ============================================================
-- FASE 2: INSERTAR DATOS (orden de dependencias: padres primero)
-- ============================================================

-- --------------------------------------------------
-- 2.1. SERVICIOS
-- --------------------------------------------------
SET IDENTITY_INSERT Servicio ON;
INSERT INTO Servicio (id_servicio, nombre_servicio, descripcion) VALUES 
(1, 'EJECUTIVO VIP', 'Servicio premium con asientos reclinables 160 y 180, 4 columnas'),
(2, 'PRESIDENCIAL', 'Servicio de lujo con asientos cama 160 y 180, 3 columnas'),
(3, 'PREMIER', 'Servicio estandar con asientos reclinables, 3 columnas');
SET IDENTITY_INSERT Servicio OFF;
PRINT 'Servicios insertados: EJECUTIVO VIP, PRESIDENCIAL, PREMIER';
GO

-- --------------------------------------------------
-- 2.2. ROLES
-- --------------------------------------------------
SET IDENTITY_INSERT Roles ON;
INSERT INTO Roles (id_rol, nombre_rol) VALUES 
(1, 'ADMINISTRADOR'),
(2, 'VENDEDOR'),
(3, 'CLIENTE_WEB');
SET IDENTITY_INSERT Roles OFF;
PRINT 'Roles insertados: ADMINISTRADOR, VENDEDOR, CLIENTE_WEB';
GO

-- --------------------------------------------------
-- 2.3. TIPOS DE ASIENTO
-- --------------------------------------------------
SET IDENTITY_INSERT Tipo_Asiento ON;
INSERT INTO Tipo_Asiento (id_tipo_asiento, nombre_tipo, descripcion, recargo_porcentaje) VALUES 
(1, 'REGULAR 140', 'Asiento estandar reclinable 140 grados', 0.00),
(2, 'CAMA VIP 160', 'Asiento semicama 160 grados con mayor espacio', 15.00),
(3, 'CAMA 180', 'Asiento cama completamente reclinable 180 grados', 25.00);
SET IDENTITY_INSERT Tipo_Asiento OFF;
PRINT 'Tipos de asiento insertados: REGULAR 140, CAMA VIP 160, CAMA 180';
GO

-- --------------------------------------------------
-- 2.4. CIUDADES
-- --------------------------------------------------
SET IDENTITY_INSERT Ciudades ON;
INSERT INTO Ciudades (id_ciudad, nombre, departamento, estado) VALUES 
(1, 'Lima',     'Lima',       'ACTIVO'),
(2, 'Arequipa', 'Arequipa',   'ACTIVO'),
(3, 'Cusco',    'Cusco',      'ACTIVO'),
(4, 'Trujillo', 'La Libertad','ACTIVO'),
(5, 'Chiclayo', 'Lambayeque', 'ACTIVO'),
(6, 'Piura',    'Piura',      'ACTIVO'),
(7, 'Huancayo', 'Junin',      'ACTIVO'),
(8, 'Ica',      'Ica',        'ACTIVO'),
(9, 'Cajamarca','Cajamarca',  'ACTIVO'),
(10,'Puno',     'Puno',       'ACTIVO');
SET IDENTITY_INSERT Ciudades OFF;
PRINT 'Ciudades insertadas: 10 registros';
GO

-- --------------------------------------------------
-- 2.5. RUTAS
-- --------------------------------------------------
SET IDENTITY_INSERT Ruta ON;
INSERT INTO Ruta (id_ruta, id_origen, id_destino, duracion_horas, precio_base, estado) VALUES 
(1, 1, 2, 16.0, 120.00, 'ACTIVO'),  -- Lima -> Arequipa
(2, 1, 3, 21.0, 150.00, 'ACTIVO'),  -- Lima -> Cusco
(3, 1, 4, 8.0,  80.00,  'ACTIVO'),  -- Lima -> Trujillo
(4, 1, 5, 12.0, 90.00,  'ACTIVO'),  -- Lima -> Chiclayo
(5, 1, 6, 15.0, 100.00, 'ACTIVO'),  -- Lima -> Piura
(6, 1, 7, 6.0,  60.00,  'ACTIVO'),  -- Lima -> Huancayo
(7, 1, 8, 4.5,  45.00,  'ACTIVO'),  -- Lima -> Ica
(8, 2, 3, 6.0,  55.00,  'ACTIVO'),  -- Arequipa -> Cusco
(9, 4, 5, 3.0,  35.00,  'ACTIVO'),  -- Trujillo -> Chiclayo
(10,5, 6, 3.5,  40.00,  'ACTIVO');  -- Chiclayo -> Piura
SET IDENTITY_INSERT Ruta OFF;
PRINT 'Rutas insertadas: 10 rutas comerciales';
GO

-- --------------------------------------------------
-- 2.6. CONDUCTORES
-- --------------------------------------------------
SET IDENTITY_INSERT Conductores ON;
INSERT INTO Conductores (id_conductor, dni, nombre, apellido, nro_licencia, estado) VALUES 
(1, '12345678', 'Ricardo',    'Mendoza',  'Q-12345678', 'DISPONIBLE'),
(2, '23456789', 'Luis',       'Fernandez','Q-23456789', 'DISPONIBLE'),
(3, '34567890', 'Jorge',      'Ramirez',  'Q-34567890', 'DISPONIBLE'),
(4, '45678901', 'Miguel',     'Torres',   'Q-45678901', 'ASIGNADO'),
(5, '56789012', 'Pedro',      'Castillo', 'Q-56789012', 'DISPONIBLE'),
(6, '67890123', 'Alberto',    'Vargas',   'Q-67890123', 'ASIGNADO'),
(7, '78901234', 'Raul',       'Cardenas', 'Q-78901234', 'DISPONIBLE'),
(8, '89012345', 'Fernando',   'Rojas',    'Q-89012345', 'DISPONIBLE');
SET IDENTITY_INSERT Conductores OFF;
PRINT 'Conductores insertados: 8 registros';
GO

-- --------------------------------------------------
-- 2.7. BUSES
-- --------------------------------------------------
SET IDENTITY_INSERT Bus ON;
INSERT INTO Bus (id_bus, placa, marca, modelo, capacidad_asientos, cantidad_pisos, estado, id_servicio) VALUES 
(1, 'ABC-123', 'Scania',    'K410',  32, 2, 'ACTIVO',        3),
(2, 'DEF-456', 'Mercedes',  'O500',  43, 2, 'ACTIVO',        2),
(3, 'GHI-789', 'Volvo',     '9700',  37, 1, 'ACTIVO',        1),
(4, 'JKL-012', 'Scania',    'K360',  60, 2, 'ACTIVO',        1),
(5, 'MNO-345', 'Mercedes',  'O500',  32, 2, 'EN MANTENIMIENTO', 2),
(6, 'PQR-678', 'Volvo',     '9700',  40, 1, 'ACTIVO',        1),
(7, 'STU-901', 'Scania',    'K410',  43, 1, 'ACTIVO',        2),
(8, 'VWX-234', 'Mercedes',  'O500',  32, 1, 'ACTIVO',        3);
SET IDENTITY_INSERT Bus OFF;
PRINT 'Buses insertados: 8 unidades';
GO

-- --------------------------------------------------
-- 2.8. CLIENTES
-- --------------------------------------------------
SET IDENTITY_INSERT Cliente ON;
INSERT INTO Cliente (id_cliente, dni, nombre, apellido, telefono, email) VALUES 
(1, '11111111', 'Ana',      'Martinez', '999111111', 'ana@email.com'),
(2, '22222222', 'Carlos',   'Lopez',    '999222222', 'carlos@email.com'),
(3, '33333333', 'Rosa',     'Gutierrez','999333333', 'rosa@email.com'),
(4, '44444444', 'Juan',     'Diaz',     '999444444', 'juan@email.com'),
(5, '55555555', 'Maria',    'Sanchez',  '999555555', 'maria@email.com'),
(6, '66666666', 'Luis',     'Paredes',  '999666666', 'luis@email.com'),
(7, '77777777', 'Carmen',   'Flores',   '999777777', 'carmen@email.com'),
(8, '88888888', 'Roberto',  'Huaman',   '999888888', 'roberto@email.com');
SET IDENTITY_INSERT Cliente OFF;
PRINT 'Clientes insertados: 8 registros';
GO

-- --------------------------------------------------
-- 2.9. USUARIOS DEL SISTEMA (con BCrypt)
-- --------------------------------------------------
-- admin / admin123 (ADMINISTRADOR)
INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado)
VALUES ('admin', '$2a$12$Wozca0979LjOP9OEFcvaueJOw.8SvziXFoAK5ijjCuf2G0FWd5kLC', 'Admin', 'Principal', 1, 'ACTIVO');
-- vendedor1 / 123456
INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado)
VALUES ('vendedor1', '$2a$12$6y./4zt0.SjWc/mWbWYz8.ii./kFgoVXiikRJQZGfma1AE5Qo2Aly', 'Carlos', 'Garcia', 2, 'ACTIVO');
-- vendedor2 / 123456
INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado)
VALUES ('vendedor2', '$2a$12$/E0oYno8FkQcQbk0p1P5N.S6AM6QnMyz0Ck1ZHJGWQPFwVQwSll3a', 'Maria', 'Lopez', 2, 'ACTIVO');
-- vendedor3 / 123456
INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado)
VALUES ('vendedor3', '$2a$12$fOe0NHTF.J5CJQma4zVkTOWXDTz1oxKl6w2P8hrYQ6VDjFTJLuRnW', 'Juan', 'Perez', 2, 'ACTIVO');
-- cliente 11111111 / cliente123 (Ana Martinez)
INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado)
VALUES ('11111111', '$2a$12$vW.UiyKeNGiw2g.meLYMBu34wqqMX.JgDxte6q9HXjynPKtj9I2/G', 'Ana', 'Martinez', 3, 'ACTIVO');
-- cliente 22222222 / cliente123 (Carlos Lopez)
INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado)
VALUES ('22222222', '$2a$12$fmQooJV2QFpXmn4/SXe3Xeex/pE1Prhouu5yx4ZsyPiXA55sKdp2K', 'Carlos', 'Lopez', 3, 'ACTIVO');
PRINT 'Usuarios insertados: admin(admin123), vendedor1/2/3(123456), clientes(cliente123)';
GO

-- --------------------------------------------------
-- 2.10. VIAJES PROGRAMADOS
-- --------------------------------------------------
-- Viaje 1: Lima(1) -> Trujillo(4), Bus ABC-123, maniana 8:00 AM, duracion 8h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 3, id_bus,
       DATEADD(HOUR, 8, DATEADD(DAY, 1, CAST(GETDATE() AS DATE))),
       DATEADD(HOUR, 16, DATEADD(DAY, 1, CAST(GETDATE() AS DATE))),
       'PROGRAMADO'
FROM Bus WHERE placa = 'ABC-123';
PRINT 'Viaje 1: Lima -> Trujillo maniana 8AM';

-- Viaje 2: Lima(1) -> Arequipa(2), Bus DEF-456, maniana 10PM, duracion 16h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 1, id_bus,
       DATEADD(HOUR, 22, DATEADD(DAY, 1, CAST(GETDATE() AS DATE))),
       DATEADD(HOUR, 38, DATEADD(DAY, 1, CAST(GETDATE() AS DATE))),
       'PROGRAMADO'
FROM Bus WHERE placa = 'DEF-456';
PRINT 'Viaje 2: Lima -> Arequipa maniana 10PM';

-- Viaje 3: Lima(1) -> Chiclayo(5), Bus GHI-789, pasado maniana 7AM, duracion 12h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 4, id_bus,
       DATEADD(HOUR, 7, DATEADD(DAY, 2, CAST(GETDATE() AS DATE))),
       DATEADD(HOUR, 19, DATEADD(DAY, 2, CAST(GETDATE() AS DATE))),
       'PROGRAMADO'
FROM Bus WHERE placa = 'GHI-789';
PRINT 'Viaje 3: Lima -> Chiclayo pasado maniana 7AM';

-- Viaje 4: Lima(1) -> Cusco(3), Bus JKL-012, en 3 dias 6PM, duracion 21h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 2, id_bus,
       DATEADD(HOUR, 18, DATEADD(DAY, 3, CAST(GETDATE() AS DATE))),
       DATEADD(HOUR, 39, DATEADD(DAY, 3, CAST(GETDATE() AS DATE))),
       'PROGRAMADO'
FROM Bus WHERE placa = 'JKL-012';
PRINT 'Viaje 4: Lima -> Cusco en 3 dias 6PM';

-- Viaje 5: Trujillo(4) -> Chiclayo(5), Bus PQR-678, maniana 6AM, duracion 3h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 9, id_bus,
       DATEADD(HOUR, 6, DATEADD(DAY, 1, CAST(GETDATE() AS DATE))),
       DATEADD(HOUR, 9, DATEADD(DAY, 1, CAST(GETDATE() AS DATE))),
       'PROGRAMADO'
FROM Bus WHERE placa = 'PQR-678';
PRINT 'Viaje 5: Trujillo -> Chiclayo maniana 6AM';

-- Viaje 6: Lima(1) -> Huancayo(7), Bus STU-901, hoy 6PM, duracion 6h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 6, id_bus,
       DATEADD(HOUR, 18, CAST(GETDATE() AS DATE)),
       DATEADD(HOUR, 24, CAST(GETDATE() AS DATE)),
       'PROGRAMADO'
FROM Bus WHERE placa = 'STU-901';
PRINT 'Viaje 6: Lima -> Huancayo hoy 6PM';

-- Viaje 7: Lima(1) -> Ica(8), Bus PQR-678, hoy 8PM, duracion 4.5h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 7, id_bus,
       DATEADD(HOUR, 20, CAST(GETDATE() AS DATE)),
       DATEADD(HOUR, 24, CAST(GETDATE() AS DATE)),
       'PROGRAMADO'
FROM Bus WHERE placa = 'PQR-678';
PRINT 'Viaje 7: Lima -> Ica hoy 8PM';

-- Viaje 8: Arequipa(2) -> Cusco(3), Bus VWX-234, en 2 dias 7AM, duracion 6h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 8, id_bus,
       DATEADD(HOUR, 7, DATEADD(DAY, 2, CAST(GETDATE() AS DATE))),
       DATEADD(HOUR, 13, DATEADD(DAY, 2, CAST(GETDATE() AS DATE))),
       'PROGRAMADO'
FROM Bus WHERE placa = 'VWX-234';
PRINT 'Viaje 8: Arequipa -> Cusco en 2 dias 7AM';

-- Viaje 9: Lima(1) -> Trujillo(4), Bus ABC-123, hoy 10PM, duracion 8h
INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado)
SELECT 3, id_bus,
       DATEADD(HOUR, 22, CAST(GETDATE() AS DATE)),
       DATEADD(HOUR, 30, CAST(GETDATE() AS DATE)),
       'PROGRAMADO'
FROM Bus WHERE placa = 'ABC-123';
PRINT 'Viaje 9: Lima -> Trujillo hoy 10PM';
GO

-- --------------------------------------------------
-- 2.11. CONDUCTORES POR VIAJE
-- --------------------------------------------------
INSERT INTO Viaje_Conductor (id_viaje, id_conductor, rol_tripulacion)
SELECT TOP 1 v.id_viaje, c.id_conductor, 'PRINCIPAL'
FROM Viaje v CROSS JOIN Conductores c
WHERE c.dni = '12345678' ORDER BY v.fecha_hora_salida;

INSERT INTO Viaje_Conductor (id_viaje, id_conductor, rol_tripulacion)
SELECT TOP 1 v.id_viaje, c.id_conductor, 'SECUNDARIO'
FROM Viaje v CROSS JOIN Conductores c
WHERE c.dni = '45678901' ORDER BY v.fecha_hora_salida;

INSERT INTO Viaje_Conductor (id_viaje, id_conductor, rol_tripulacion)
SELECT TOP 1 v.id_viaje, c.id_conductor, 'PRINCIPAL'
FROM Viaje v CROSS JOIN Conductores c
WHERE v.id_ruta = 6 AND c.dni = '34567890' ORDER BY v.fecha_hora_salida;
PRINT 'Conductores asignados a viajes';
GO

-- --------------------------------------------------
-- 2.12. NIVELES DE FIDELIDAD
-- --------------------------------------------------
SET IDENTITY_INSERT Nivel_Fidelidad ON;
INSERT INTO Nivel_Fidelidad (id_nivel, nombre_nivel, puntos_desde, puntos_hasta, descuento_porcentaje, color_hex, icono)
VALUES 
(1, 'BRONCE',  0,    199,  0,   '#CD7F32', 'bi-trophy-fill'),
(2, 'PLATA',   200,  499,  3,   '#C0C0C0', 'bi-trophy-fill'),
(3, 'ORO',     500,  999,  5,   '#FFD700', 'bi-trophy-fill'),
(4, 'PLATINO', 1000, NULL, 10,  '#E5E4E2', 'bi-star-fill');
SET IDENTITY_INSERT Nivel_Fidelidad OFF;
PRINT 'Niveles de fidelidad: BRONCE, PLATA, ORO, PLATINO';
GO

-- ============================================================
-- FASE 3: VERIFICACION
-- ============================================================
SELECT 'SERVICIOS' AS tabla, COUNT(*) AS registros FROM Servicio
UNION ALL SELECT 'ROLES', COUNT(*) FROM Roles
UNION ALL SELECT 'TIPO_ASIENTO', COUNT(*) FROM Tipo_Asiento
UNION ALL SELECT 'CIUDADES', COUNT(*) FROM Ciudades
UNION ALL SELECT 'RUTAS', COUNT(*) FROM Ruta
UNION ALL SELECT 'CONDUCTORES', COUNT(*) FROM Conductores
UNION ALL SELECT 'BUSES', COUNT(*) FROM Bus
UNION ALL SELECT 'CLIENTES', COUNT(*) FROM Cliente
UNION ALL SELECT 'USUARIOS', COUNT(*) FROM Usuarios
UNION ALL SELECT 'VIAJES', COUNT(*) FROM Viaje
UNION ALL SELECT 'VIAJE_CONDUCTOR', COUNT(*) FROM Viaje_Conductor
UNION ALL SELECT 'NIVEL_FIDELIDAD', COUNT(*) FROM Nivel_Fidelidad
ORDER BY tabla;
GO

PRINT '';
PRINT '============================================';
PRINT '  DATOS DE PRUEBA INSERTADOS';
PRINT '============================================';
PRINT '  ADMIN:      admin / admin123';
PRINT '  VENDEDOR:   vendedor1 / 123456';
PRINT '  VENDEDOR:   vendedor2 / 123456';
PRINT '  VENDEDOR:   vendedor3 / 123456';
PRINT '  CLIENTE:    11111111 / cliente123';
PRINT '  CLIENTE:    22222222 / cliente123';
PRINT '============================================';
GO
