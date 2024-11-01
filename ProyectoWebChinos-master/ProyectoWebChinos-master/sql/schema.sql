sql completo: -- Crear la extensión para manejar UUIDs si es necesario (opcional)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla Clientes
CREATE TABLE Clientes (
    ClienteID SERIAL PRIMARY KEY,
    NombreCompleto VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Telefono VARCHAR(20),
    NombreUsuario VARCHAR(100) NOT NULL UNIQUE,
    Contrasena VARCHAR(255) NOT NULL
);

-- Tabla Direcciones
CREATE TABLE Direcciones (
    DireccionID SERIAL PRIMARY KEY,
    ClienteID INT NOT NULL,
    Calle VARCHAR(255) NOT NULL,
    Ciudad VARCHAR(100) NOT NULL,
    Estado VARCHAR(100),
    CodigoPostal VARCHAR(20),
    Pais VARCHAR(100) NOT NULL,
    Tipo VARCHAR(50), -- Por ejemplo, 'Envío', 'Facturación'
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID) ON DELETE CASCADE
);

-- Tabla CuentasPago
CREATE TABLE CuentasPago (
    CuentaPagoID SERIAL PRIMARY KEY,
    ClienteID INT NOT NULL,
    TipoCuenta VARCHAR(50) NOT NULL, -- Ejemplo: 'PayPal', 'Tarjeta de Crédito'
    DetalleCuenta VARCHAR(255) NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID) ON DELETE CASCADE
);

-- Tabla Categorias (postres)
CREATE TABLE Categorias (
    CategoriaID SERIAL PRIMARY KEY,
    NombreCategoria VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Marcas (marcas de postres)
CREATE TABLE Marcas (
    MarcaID SERIAL PRIMARY KEY,
    NombreMarca VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Proveedores (proveedores de ingredientes o productos de postres)
CREATE TABLE Proveedores (
    ProveedorID SERIAL PRIMARY KEY,
    NombreProveedor VARCHAR(255) NOT NULL UNIQUE,
    Contacto VARCHAR(255)
);

-- Tabla Productos (postres)
CREATE TABLE Productos (
    ProductoID SERIAL PRIMARY KEY,
    NombreProducto VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    CategoriaID INT NOT NULL,
    MarcaID INT NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    Ingredientes VARCHAR(255),
    Peso DECIMAL(10, 2),
    FOREIGN KEY (CategoriaID) REFERENCES Categorias(CategoriaID) ON DELETE SET NULL,
    FOREIGN KEY (MarcaID) REFERENCES Marcas(MarcaID) ON DELETE SET NULL
);

-- Tabla ProductoProveedores
CREATE TABLE ProductoProveedores (
    ProductoID INT NOT NULL,
    ProveedorID INT NOT NULL,
    PRIMARY KEY (ProductoID, ProveedorID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) ON DELETE CASCADE,
    FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID) ON DELETE CASCADE
);

-- Tabla ImagenesProducto
CREATE TABLE ImagenesProducto (
    ImagenID SERIAL PRIMARY KEY,
    ProductoID INT NOT NULL,
    URLImagen VARCHAR(255) NOT NULL,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) ON DELETE CASCADE
);

-- Tabla VariacionesProducto (tamaños y sabores de postres)
CREATE TABLE VariacionesProducto (
    VariacionID SERIAL PRIMARY KEY,
    ProductoID INT NOT NULL,
    Sabor VARCHAR(50),
    Tamaño VARCHAR(50), -- Tamaño puede ser 'Pequeño', 'Mediano', 'Grande'
    CantidadEnStock INT NOT NULL CHECK (CantidadEnStock >= 0),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) ON DELETE CASCADE
);

-- Tabla Pedidos
CREATE TABLE Pedidos (
    PedidoID SERIAL PRIMARY KEY,
    ClienteID INT NOT NULL,
    FechaHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TotalPrecio DECIMAL(10, 2) NOT NULL CHECK (TotalPrecio >= 0),
    EstadoPedido VARCHAR(50) NOT NULL,
    DireccionEnvioID INT NOT NULL,
    CuentaPagoID INT NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID) ON DELETE CASCADE,
    FOREIGN KEY (DireccionEnvioID) REFERENCES Direcciones(DireccionID) ON DELETE SET NULL,
    FOREIGN KEY (CuentaPagoID) REFERENCES CuentasPago(CuentaPagoID) ON DELETE SET NULL
);

-- Tabla DetallePedido
CREATE TABLE DetallePedido (
    DetallePedidoID SERIAL PRIMARY KEY,
    PedidoID INT NOT NULL,
    ProductoID INT NOT NULL,
    VariacionID INT,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10, 2) NOT NULL CHECK (PrecioUnitario >= 0),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID) ON DELETE CASCADE,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) ON DELETE CASCADE,
    FOREIGN KEY (VariacionID) REFERENCES VariacionesProducto(VariacionID) ON DELETE SET NULL
);

-- Tabla Pagos
CREATE TABLE Pagos (
    PagoID SERIAL PRIMARY KEY,
    PedidoID INT NOT NULL,
    FechaHoraPago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Monto DECIMAL(10, 2) NOT NULL CHECK (Monto >= 0),
    EstadoPago VARCHAR(50) NOT NULL,
    IDTransaccionProcesador VARCHAR(255),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID) ON DELETE CASCADE
);

-- Índices adicionales
CREATE INDEX idx_productos_categoria ON Productos(CategoriaID);
CREATE INDEX idx_productos_marca ON Productos(MarcaID);
CREATE INDEX idx_pedidos_cliente ON Pedidos(ClienteID);
CREATE INDEX idx_detallepedido_pedido ON DetallePedido(PedidoID);
CREATE INDEX idx_pagospedido ON Pagos(PedidoID);

-- ---------------------------------------------------------------
-- Inserción de Datos de Ejemplo
-- ---------------------------------------------------------------

-- Insertar categorías de postres
INSERT INTO Categorias (NombreCategoria) VALUES 
('Pasteles'),
('Galletas'),
('Dulces'),
('Panadería'),
('Helados');

-- Insertar marcas de postres
INSERT INTO Marcas (NombreMarca) VALUES 
('DulceManía'),
('Delicias Caseras'),
('Cielo de Chocolate'),
('Frozen Treats');

-- Insertar proveedores de ingredientes o productos
INSERT INTO Proveedores (NombreProveedor, Contacto) VALUES 
('Proveedor Azúcar', 'contacto@azucar.com'),
('Proveedor Cacao', 'contacto@cacao.com');

-- Insertar productos de ejemplo
INSERT INTO Productos (
    NombreProducto, 
    Descripcion, 
    CategoriaID, 
    MarcaID, 
    Precio, 
    Ingredientes, 
    Peso
) VALUES 
('Pastel de Chocolate', 'Delicioso pastel de chocolate con cobertura de crema', 1, 3, 15.99, 'Harina, Cacao, Azúcar, Huevo', 1.0),
('Galletas de Avena', 'Galletas caseras con avena y pasas', 2, 2, 4.99, 'Avena, Azúcar, Mantequilla', 0.5),
('Pan de Nuez', 'Pan dulce con trozos de nuez', 4, 1, 8.99, 'Harina, Nueces, Azúcar', 0.8),
('Helado de Vainilla', 'Helado cremoso de vainilla', 5, 4, 6.99, 'Leche, Azúcar, Vainilla', 0.4);

-- Insertar imágenes de productos (URLs de ejemplo para los postres)
INSERT INTO ImagenesProducto (ProductoID, URLImagen) VALUES
(1, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQSQE0OwmT2J3cRPW3dOtuO_nkb0m5eCtLSoA&s'),
(2, 'https://png.pngtree.com/png-clipart/20231003/original/pngtree-oatmeal-cookies-isolated-created-with-generative-ai-png-image_13247403.png'),
(3, 'https://vivamas.com.mx/wp-content/uploads/2021/03/PAN-FINO-CON-NUEZ.png'),
(4, 'https://froneri.es/img/helados-nestle/detail/xs/vainilla-0-azucares.png');

-- Insertar asociaciones entre productos y proveedores
INSERT INTO ProductoProveedores (ProductoID, ProveedorID) VALUES
(1, 2), -- Pastel de Chocolate (Proveedor de Cacao)
(2, 1), -- Galletas de Avena (Proveedor de Azúcar)
(3, 1), -- Pan de Nuez (Proveedor de Azúcar)
(4, 1); -- Helado de Vainilla (Proveedor de Azúcar)

-- Insertar variaciones de productos (ejemplos de tamaños y sabores)
INSERT INTO VariacionesProducto (ProductoID, Sabor, Tamaño, CantidadEnStock) VALUES
(1, 'Chocolate', 'Grande', 10),
(1, 'Chocolate', 'Mediano', 15),
(2, 'Avena con Pasas', 'Individual', 30),
(2, 'Avena con Pasas', 'Paquete Familiar', 20),
(3, 'Nuez', 'Grande', 5),
(4, 'Vainilla', '1 litro', 25),
(4, 'Vainilla', '500 ml', 40);

-- Insertar pedidos de ejemplo
INSERT INTO Pedidos (ClienteID, TotalPrecio, EstadoPedido, DireccionEnvioID, CuentaPagoID) VALUES
(1, 30.97, 'Procesando', 1, 1),
(2, 15.99, 'Enviado', 2, 2);

-- Insertar detalles de pedidos de ejemplo
INSERT INTO DetallePedido (PedidoID, ProductoID, VariacionID, Cantidad, PrecioUnitario) VALUES
(1, 1, 1, 1, 15.99), -- Pedido 1 con Pastel de Chocolate Grande
(1, 2, 3, 3, 4.99), -- Pedido 1 con 3 Galletas de Avena Individuales
(2, 3, NULL, 1, 8.99); -- Pedido 2 con Pan de Nuez Grande

-- Insertar pagos de ejemplo
INSERT INTO Pagos (PedidoID, Monto, EstadoPago, IDTransaccionProcesador) VALUES
(1, 30.97, 'Completado', 'txn_001'),
(2, 15.99, 'Completado', 'txn_002');