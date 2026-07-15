USE [master];
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'MovilBusDB')
BEGIN
    -- Forzar el cierre de todas las conexiones activas para evitar el error "Database in use"
    ALTER DATABASE [MovilBusDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [MovilBusDB];
    PRINT 'Base de datos MovilBusDB eliminada con éxito.';
END
GO

-- =========================================================================
-- 2. CREAR NUEVA BASE DE DATOS LIMPIA
-- =========================================================================
CREATE DATABASE [MovilBusDB];
GO
USE [MovilBusDB];
GO

-- =========================================================================
-- 3. CREACIÓN DE TABLAS MAESTRAS (Sin dependencias externas)
-- =========================================================================

CREATE TABLE Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL -- 'ADMINISTRADOR', 'VENDEDOR', 'CLIENTE_WEB'
);

CREATE TABLE Ciudades (
    id_ciudad INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
);

-- Nueva Tabla para clasificar las configuraciones de los Buses
CREATE TABLE Servicio (
    id_servicio INT IDENTITY(1,1) PRIMARY KEY,
    nombre_servicio VARCHAR(50) NOT NULL, -- 'PRESIDENCIAL', 'EJECUTIVO VIP', 'PREMIER'
    descripcion VARCHAR(150) NULL
);

CREATE TABLE Bus (
    id_bus INT IDENTITY(1,1) PRIMARY KEY,
    placa VARCHAR(15) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    capacidad_asientos INT NOT NULL,
    cantidad_pisos INT NOT NULL DEFAULT 1,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    id_servicio INT NOT NULL DEFAULT 1, -- Relación con el servicio del bus
    CONSTRAINT FK_Bus_Servicio FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio)
);

CREATE TABLE Conductores (
    id_conductor INT IDENTITY(1,1) PRIMARY KEY,
    dni VARCHAR(8) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    nro_licencia VARCHAR(30) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE'
);

CREATE TABLE Tipo_Asiento (
    id_tipo_asiento INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL, -- 'Semi Cama 140°', 'Cama Vip 160°', 'Full Flat 180°'
    precio_adicional DECIMAL(8, 2) NOT NULL DEFAULT 0.00
);

-- =========================================================================
-- 4. TABLAS SECUNDARIAS (Con dependencias de nivel 1)
-- =========================================================================

-- Tabla Unificada de Usuarios
CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE, -- DNI o Correo
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    id_rol INT NOT NULL,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
);

-- Plantilla de Asientos por Bus (Modificada para recargos de ubicación)
CREATE TABLE Bus_Asiento (
    id_bus_asiento INT IDENTITY(1,1) PRIMARY KEY,
    id_bus INT NOT NULL,
    numero_asiento INT NOT NULL,
    piso INT NOT NULL,
    fila INT NOT NULL,
    columna INT NOT NULL,
    posicion VARCHAR(30) NOT NULL DEFAULT 'VENTANA';,
    estado VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
    id_tipo_asiento INT NOT NULL,
    recargo_ubicacion DECIMAL(8, 2) NOT NULL DEFAULT 0.00, -- Extra por ser ventana solitaria/individual
    CONSTRAINT FK_Asiento_Bus FOREIGN KEY (id_bus) REFERENCES Bus(id_bus),
    CONSTRAINT FK_Asiento_Tipo FOREIGN KEY (id_tipo_asiento) REFERENCES Tipo_Asiento(id_tipo_asiento),
    CONSTRAINT UQ_Bus_Asiento UNIQUE (id_bus, numero_asiento)
);

-- Rutas Comerciales
CREATE TABLE Ruta (
    id_ruta INT IDENTITY(1,1) PRIMARY KEY,
    id_origen INT NOT NULL,
    id_destino INT NOT NULL,
    duracion_horas DECIMAL(4, 2) NOT NULL,
    precio_base DECIMAL(8, 2) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT FK_Ruta_Origen FOREIGN KEY (id_origen) REFERENCES Ciudades(id_ciudad),
    CONSTRAINT FK_Ruta_Destino FOREIGN KEY (id_destino) REFERENCES Ciudades(id_ciudad)
);

-- Clientes
CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    dni VARCHAR(8) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NULL,
    email VARCHAR(150) NULL,
    fecha_registro DATE NOT NULL DEFAULT GETDATE(),
    id_usuario INT NULL,
    CONSTRAINT FK_Cliente_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

-- =========================================================================
-- 5. TABLAS OPERATIVAS Y TRANSACCIONALES (Con dependencias de nivel 2)
-- =========================================================================

-- El Viaje
CREATE TABLE Viaje (
    id_viaje INT IDENTITY(1,1) PRIMARY KEY,
    fecha_hora_salida DATETIME2(7) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADO',
    id_bus INT NOT NULL,
    id_ruta INT NOT NULL,
    fecha_hora_llegada_estimada DATETIME2(7) NULL,
    CONSTRAINT FK_Viaje_Bus FOREIGN KEY (id_bus) REFERENCES Bus(id_bus),
    CONSTRAINT FK_Viaje_Ruta FOREIGN KEY (id_ruta) REFERENCES Ruta(id_ruta)
);

-- Tripulación
CREATE TABLE Viaje_Conductor (
    id_viaje_conductor INT IDENTITY(1,1) PRIMARY KEY,
    id_viaje INT NOT NULL,
    id_conductor INT NOT NULL,
    rol_tripulacion VARCHAR(50) NOT NULL,
    CONSTRAINT FK_VC_Viaje FOREIGN KEY (id_viaje) REFERENCES Viaje(id_viaje),
    CONSTRAINT FK_VC_Conductor FOREIGN KEY (id_conductor) REFERENCES Conductores(id_conductor),
    CONSTRAINT UQ_Viaje_Conductor UNIQUE (id_viaje, id_conductor)
);

-- Pasajes Vendidos
CREATE TABLE Pasaje (
    id_pasaje INT IDENTITY(1,1) PRIMARY KEY,
    fecha_emision DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    precio_pagado DECIMAL(8, 2) NOT NULL, -- Se calcula dinámicamente sumando: Base Ruta + Tipo_Asiento + Recargo_Ubicacion
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    id_viaje INT NOT NULL,
    id_cliente INT NOT NULL,
    id_bus_asiento INT NOT NULL, 
    CONSTRAINT FK_Pasaje_Viaje FOREIGN KEY (id_viaje) REFERENCES Viaje(id_viaje),
    CONSTRAINT FK_Pasaje_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Pasaje_Asiento FOREIGN KEY (id_bus_asiento) REFERENCES Bus_Asiento(id_bus_asiento),
    CONSTRAINT UQ_Viaje_Asiento UNIQUE (id_viaje, id_bus_asiento)
);

-- Pagos de los Pasajes
-- NOTA: id_vendedor puede ser NULL (compra web del cliente) 
-- o tener un id de usuario (venta por ADMINISTRADOR/VENDEDOR)
CREATE TABLE Pago (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
    monto_total DECIMAL(8, 2) NOT NULL,
    metodo_pago VARCHAR(30) NOT NULL,
    fecha_pago DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    numero_operacion VARCHAR(50) NULL,
    id_pasaje INT NOT NULL,
    id_vendedor INT NULL,  -- NULL = compra por cliente web; con ID = venta por administrador/vendedor
    CONSTRAINT FK_Pago_Pasaje FOREIGN KEY (id_pasaje) REFERENCES Pasaje(id_pasaje),
    CONSTRAINT FK_Pago_Vendedor FOREIGN KEY (id_vendedor) REFERENCES Usuarios(id_usuario)
);
GO
PRINT 'Estructura de tablas recreada correctamente.';
GO

-- =========================================================================
-- TABLA DE ENCOMIENDAS (Envío de paquetes)
-- =========================================================================
CREATE TABLE Encomienda (
    id_encomienda INT IDENTITY(1,1) PRIMARY KEY,
    descripcion_contenido VARCHAR(255) NOT NULL,  -- Ej: "Caja de repuestos", "Documentos"
    peso_kg DECIMAL(6, 2) NOT NULL,
    precio_envio DECIMAL(8, 2) NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'REGISTRADO',  -- 'REGISTRADO', 'EN VIAJE', 'ENTREGADO', 'ANULADO'
    fecha_envio DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    fecha_entrega_real DATETIME2(7) NULL,
    
    -- Relaciones clave
    id_viaje INT NOT NULL,                           -- En qué viaje/bus se transporta
    id_remitente INT NOT NULL,                       -- Quién envía (FK a Cliente)
    id_destinatario INT NOT NULL,                     -- Quién recibe (FK a Cliente)
    
    CONSTRAINT FK_Encomienda_Viaje FOREIGN KEY (id_viaje) REFERENCES Viaje(id_viaje),
    CONSTRAINT FK_Encomienda_Remitente FOREIGN KEY (id_remitente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Encomienda_Destinatario FOREIGN KEY (id_destinatario) REFERENCES Cliente(id_cliente)
);
GO

-- Modificar Pago para soportar también encomiendas
ALTER TABLE Pago
ALTER COLUMN id_pasaje INT NULL;  -- Ahora un pago puede no tener pasaje (si es encomienda)
GO

ALTER TABLE Pago
ADD id_encomienda INT NULL;  -- Nueva FK opcional para encomiendas
GO

ALTER TABLE Pago
ADD CONSTRAINT FK_Pago_Encomienda FOREIGN KEY (id_encomienda) REFERENCES Encomienda(id_encomienda);
GO

PRINT 'Tabla Encomienda creada y Pago modificado correctamente.';
GO

-- =========================================================================
-- TABLA DE CITAS DE ENCOMIENDA (Agenda para clientes)
-- =========================================================================
CREATE TABLE Cita_Encomienda (
    id_cita INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_origen INT NOT NULL,
    id_destino INT NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    peso_estimado DECIMAL(6,2) NOT NULL DEFAULT 1.0,
    fecha_preferida DATE NOT NULL,
    hora_preferida VARCHAR(5) NOT NULL,  -- HH:mm
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',  -- PENDIENTE, CONFIRMADA, CANCELADA, COMPLETADA
    fecha_registro DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    observaciones VARCHAR(500) NULL,
    
    CONSTRAINT FK_Cita_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Cita_Origen FOREIGN KEY (id_origen) REFERENCES Ciudades(id_ciudad),
    CONSTRAINT FK_Cita_Destino FOREIGN KEY (id_destino) REFERENCES Ciudades(id_ciudad)
);
GO

PRINT 'Tabla Cita_Encomienda creada correctamente.';
GO

-- =========================================================================
-- 6. INSERCIÓN DE DATOS INICIALES (DATA SEMILLA)
-- =========================================================================

-- Roles Base
INSERT INTO Roles (nombre_rol) VALUES 
('ADMINISTRADOR'), 
('VENDEDOR'), 
('CLIENTE_WEB');

-- Usuarios Iniciales
INSERT INTO Usuarios (username, password, nombre, apellido, id_rol) VALUES 
('admin', '123456', 'Juan', 'Perez', 1),
('vendedor1', '123456', 'Maria', 'Gomez', 2);

-- Ciudades de Origen y Destino
INSERT INTO Ciudades (nombre, departamento) VALUES 
('Chiclayo', 'Lambayeque'), -- ID 1
('Lima', 'Lima'),           -- ID 2
('Trujillo', 'La Libertad'),-- ID 3
('Piura', 'Piura');         -- ID 4

-- Servicios
INSERT INTO Servicio (nombre_servicio, descripcion) VALUES
('EJECUTIVO VIP', 'Buses cómodos de 1 o 2 pisos, combinaciones de asientos 140° y 160°'), -- ID 1
('PRESIDENCIAL', 'Buses de lujo en distribución 3 columnas, asientos 160° y 180°'),     -- ID 2
('PREMIER', 'Servicio exclusivo de alta gama, asientos ultra confort y privacidad');      -- ID 3

-- Rutas Comerciales
INSERT INTO Ruta (id_origen, id_destino, duracion_horas, precio_base) VALUES 
(1, 2, 12.50, 80.00), -- Ruta 1: Chiclayo -> Lima (Precio base: S/ 80.00)
(1, 4, 3.50, 30.00);  -- Ruta 2: Chiclayo -> Piura (Precio base: S/ 30.00)

-- Tipos de Asiento
INSERT INTO Tipo_Asiento (descripcion, precio_adicional) VALUES 
('Regular 140°', 0.00),     -- ID 1
('Cama Vip 160°', 20.00),   -- ID 2
('Full Flat 180°', 40.00);  -- ID 3

-- ========================================================
-- CREACIÓN DE BUS DE PRUEBAS 1: EJECUTIVO VIP (12 ASIENTOS)
-- ========================================================
INSERT INTO Bus (placa, marca, modelo, capacidad_asientos, cantidad_pisos, id_servicio) VALUES 
('T3B-123', 'Scania', 'K410', 12, 1, 1); -- ID 1

-- Obtener el ID dinámicamente para el Bus 1
DECLARE @idBus1 INT = SCOPE_IDENTITY();

INSERT INTO Bus_Asiento (id_bus, numero_asiento, piso, fila, columna, id_tipo_asiento, recargo_ubicacion) VALUES 
-- Fila 1 (Asientos VIP de S/ 100.00: Base 80.00 + Adicional 20.00)
(@idBus1, 1, 1, 1, 1, 2, 0.00), (@idBus1, 2, 1, 1, 2, 2, 0.00), (@idBus1, 3, 1, 1, 3, 2, 0.00), (@idBus1, 4, 1, 1, 4, 2, 0.00),
-- Fila 2 (Asientos Standard de S/ 80.00)
(@idBus1, 5, 1, 2, 1, 1, 0.00), (@idBus1, 6, 1, 2, 2, 1, 0.00), (@idBus1, 7, 1, 2, 3, 1, 0.00), (@idBus1, 8, 1, 2, 4, 1, 0.00),
-- Fila 3 (Asientos Standard de S/ 80.00)
(@idBus1, 9, 1, 3, 1, 1, 0.00), (@idBus1, 10, 1, 3, 2, 1, 0.00), (@idBus1, 11, 1, 3, 3, 1, 0.00), (@idBus1, 12, 1, 3, 4, 1, 0.00);


-- Conductores de Prueba
INSERT INTO Conductores (dni, nombre, apellido, nro_licencia)
SELECT '77777777', 'Carlos', 'Ramirez', 'Q-12345678' UNION ALL
SELECT '88888888', 'Luis', 'Fernandez', 'Q-87654321';

-- Programar un Viaje para dentro de 2 días (Chiclayo a Lima) usando el Bus 1 y la Ruta 1
INSERT INTO Viaje (fecha_hora_salida, id_bus, id_ruta) VALUES 
(DATEADD(day, 2, GETDATE()), 1, 1); -- Viaje ID 1

-- Tripulación
INSERT INTO Viaje_Conductor (id_viaje, id_conductor, rol_tripulacion) VALUES 
(1, 1, 'PILOTO PRINCIPAL'),
(1, 2, 'PILOTO DE RELEVO');

-- ========================================================
-- CREACIÓN DE BUS DE PRUEBAS 2: EJECUTIVO VIP (32 ASIENTOS)
-- ========================================================
INSERT INTO Bus (placa, marca, modelo, capacidad_asientos, cantidad_pisos, id_servicio) VALUES 
('T3B-1243', 'Scania', 'K410', 32, 1, 1); -- ID 2

-- Obtener el ID dinámicamente para el Bus 2 (Evita errores de ID harcodeado)
DECLARE @idBus2 INT = SCOPE_IDENTITY();

-- Plantilla de Asientos corregida (Se añade la columna de recargo_ubicacion)
INSERT INTO Bus_Asiento (id_bus, numero_asiento, piso, fila, columna, id_tipo_asiento, recargo_ubicacion) VALUES 
-- Fila 1 (VIP - Cama 160°)
(@idBus2, 1, 1, 1, 1, 2, 0.00), (@idBus2, 2, 1, 1, 2, 2, 0.00), (@idBus2, 3, 1, 1, 3, 2, 0.00), (@idBus2, 4, 1, 1, 4, 2, 0.00),
-- Fila 2 (VIP - Cama 160°)
(@idBus2, 5, 1, 2, 1, 2, 0.00), (@idBus2, 6, 1, 2, 2, 2, 0.00), (@idBus2, 7, 1, 2, 3, 2, 0.00), (@idBus2, 8, 1, 2, 4, 2, 0.00),
-- Fila 3 (Regular 140°)
(@idBus2, 9, 1, 3, 1, 1, 0.00), (@idBus2, 10, 1, 3, 2, 1, 0.00), (@idBus2, 11, 1, 3, 3, 1, 0.00), (@idBus2, 12, 1, 3, 4, 1, 0.00),
-- Fila 4 (Regular 140°)
(@idBus2, 13, 1, 4, 1, 1, 0.00), (@idBus2, 14, 1, 4, 2, 1, 0.00), (@idBus2, 15, 1, 4, 3, 1, 0.00), (@idBus2, 16, 1, 4, 4, 1, 0.00),
-- Fila 5 (Regular 140°)
(@idBus2, 17, 1, 5, 1, 1, 0.00), (@idBus2, 18, 1, 5, 2, 1, 0.00), (@idBus2, 19, 1, 5, 3, 1, 0.00), (@idBus2, 20, 1, 5, 4, 1, 0.00),
-- Fila 6 (Regular 140°)
(@idBus2, 21, 1, 6, 1, 1, 0.00), (@idBus2, 22, 1, 6, 2, 1, 0.00), (@idBus2, 23, 1, 6, 3, 1, 0.00), (@idBus2, 24, 1, 6, 4, 1, 0.00),
-- Fila 7 (Regular 140°)
(@idBus2, 25, 1, 7, 1, 1, 0.00), (@idBus2, 26, 1, 7, 2, 1, 0.00), (@idBus2, 27, 1, 7, 3, 1, 0.00), (@idBus2, 28, 1, 7, 4, 1, 0.00),
-- Fila 8 (Regular 140°)
(@idBus2, 29, 1, 8, 1, 1, 0.00), (@idBus2, 30, 1, 8, 2, 1, 0.00), (@idBus2, 31, 1, 8, 3, 1, 0.00), (@idBus2, 32, 1, 8, 4, 1, 0.00);
GO

PRINT 'Datos semilla cargados con éxito. ¡Listo para pruebas!';