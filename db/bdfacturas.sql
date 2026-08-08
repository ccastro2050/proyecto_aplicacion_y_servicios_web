-- ============================================================
-- Script de creación de base de datos: bdfacturas_sqlserver_local
-- Compatible con SQL Server 2016+
-- Incluye: tablas, restricciones, triggers y datos de ejemplo
-- ============================================================

USE bdfacturas_sqlserver_local;
GO

-- ============================================================
-- LIMPIEZA: Eliminar objetos existentes en orden correcto
-- ============================================================

-- Triggers
IF OBJECT_ID('trg_prodfact_insert', 'TR') IS NOT NULL DROP TRIGGER trg_prodfact_insert;
IF OBJECT_ID('trg_prodfact_update', 'TR') IS NOT NULL DROP TRIGGER trg_prodfact_update;
IF OBJECT_ID('trg_prodfact_delete', 'TR') IS NOT NULL DROP TRIGGER trg_prodfact_delete;
GO

-- Procedimientos almacenados
IF OBJECT_ID('sp_insertar_factura_y_productosporfactura', 'P') IS NOT NULL DROP PROCEDURE sp_insertar_factura_y_productosporfactura;
IF OBJECT_ID('sp_consultar_factura_y_productosporfactura', 'P') IS NOT NULL DROP PROCEDURE sp_consultar_factura_y_productosporfactura;
IF OBJECT_ID('sp_listar_facturas_y_productosporfactura', 'P') IS NOT NULL DROP PROCEDURE sp_listar_facturas_y_productosporfactura;
IF OBJECT_ID('sp_actualizar_factura_y_productosporfactura', 'P') IS NOT NULL DROP PROCEDURE sp_actualizar_factura_y_productosporfactura;
IF OBJECT_ID('sp_borrar_factura_y_productosporfactura', 'P') IS NOT NULL DROP PROCEDURE sp_borrar_factura_y_productosporfactura;
IF OBJECT_ID('sp_anular_factura', 'P') IS NOT NULL DROP PROCEDURE sp_anular_factura;
IF OBJECT_ID('crear_usuario_con_roles', 'P') IS NOT NULL DROP PROCEDURE crear_usuario_con_roles;
IF OBJECT_ID('actualizar_usuario_con_roles', 'P') IS NOT NULL DROP PROCEDURE actualizar_usuario_con_roles;
IF OBJECT_ID('eliminar_usuario_con_roles', 'P') IS NOT NULL DROP PROCEDURE eliminar_usuario_con_roles;
IF OBJECT_ID('actualizar_roles_usuario', 'P') IS NOT NULL DROP PROCEDURE actualizar_roles_usuario;
IF OBJECT_ID('consultar_usuario_con_roles', 'P') IS NOT NULL DROP PROCEDURE consultar_usuario_con_roles;
IF OBJECT_ID('listar_usuarios_con_roles', 'P') IS NOT NULL DROP PROCEDURE listar_usuarios_con_roles;
IF OBJECT_ID('verificar_acceso_ruta', 'P') IS NOT NULL DROP PROCEDURE verificar_acceso_ruta;
IF OBJECT_ID('listar_rutarol', 'P') IS NOT NULL DROP PROCEDURE listar_rutarol;
IF OBJECT_ID('crear_rutarol', 'P') IS NOT NULL DROP PROCEDURE crear_rutarol;
IF OBJECT_ID('eliminar_rutarol', 'P') IS NOT NULL DROP PROCEDURE eliminar_rutarol;
GO

-- Tablas dependientes primero
IF OBJECT_ID('rutarol', 'U') IS NOT NULL DROP TABLE rutarol;
IF OBJECT_ID('rol_usuario', 'U') IS NOT NULL DROP TABLE rol_usuario;
IF OBJECT_ID('productosporfactura', 'U') IS NOT NULL DROP TABLE productosporfactura;
IF OBJECT_ID('factura', 'U') IS NOT NULL DROP TABLE factura;
IF OBJECT_ID('cliente', 'U') IS NOT NULL DROP TABLE cliente;
IF OBJECT_ID('vendedor', 'U') IS NOT NULL DROP TABLE vendedor;
IF OBJECT_ID('empresa', 'U') IS NOT NULL DROP TABLE empresa;
IF OBJECT_ID('persona', 'U') IS NOT NULL DROP TABLE persona;
IF OBJECT_ID('producto', 'U') IS NOT NULL DROP TABLE producto;
IF OBJECT_ID('rol', 'U') IS NOT NULL DROP TABLE rol;
IF OBJECT_ID('ruta', 'U') IS NOT NULL DROP TABLE ruta;
IF OBJECT_ID('usuario', 'U') IS NOT NULL DROP TABLE usuario;
GO

-- ============================================================
-- TABLAS INDEPENDIENTES (sin foreign keys)
-- ============================================================

CREATE TABLE empresa (
    codigo NVARCHAR(10) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    CONSTRAINT pk_empresa PRIMARY KEY (codigo)
);

CREATE TABLE persona (
    codigo NVARCHAR(10) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL,
    telefono NVARCHAR(20) NOT NULL,
    CONSTRAINT pk_persona PRIMARY KEY (codigo)
);

CREATE TABLE producto (
    codigo NVARCHAR(10) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    stock INT NOT NULL,
    valorunitario DECIMAL(18,2) NOT NULL,
    CONSTRAINT pk_producto PRIMARY KEY (codigo)
);

CREATE TABLE rol (
    id INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_rol PRIMARY KEY (id)
);

CREATE TABLE ruta (
    id INT IDENTITY(1,1) NOT NULL,
    ruta NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(200) NOT NULL,
    CONSTRAINT pk_ruta PRIMARY KEY (id),
    CONSTRAINT uq_ruta UNIQUE (ruta)
);

CREATE TABLE usuario (
    email NVARCHAR(100) NOT NULL,
    contrasena NVARCHAR(200) NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (email)
);
GO

-- ============================================================
-- TABLAS DEPENDIENTES (con foreign keys)
-- ============================================================

CREATE TABLE cliente (
    id INT IDENTITY(1,1) NOT NULL,
    credito DECIMAL(18,2) NOT NULL DEFAULT 0,
    fkcodpersona NVARCHAR(10) NOT NULL,
    fkcodempresa NVARCHAR(10),
    CONSTRAINT pk_cliente PRIMARY KEY (id),
    CONSTRAINT fk_cliente_persona FOREIGN KEY (fkcodpersona) REFERENCES persona(codigo),
    CONSTRAINT fk_cliente_empresa FOREIGN KEY (fkcodempresa) REFERENCES empresa(codigo)
);

CREATE TABLE vendedor (
    id INT IDENTITY(1,1) NOT NULL,
    carnet INT NOT NULL,
    direccion NVARCHAR(100) NOT NULL,
    fkcodpersona NVARCHAR(10) NOT NULL,
    CONSTRAINT pk_vendedor PRIMARY KEY (id),
    CONSTRAINT fk_vendedor_persona FOREIGN KEY (fkcodpersona) REFERENCES persona(codigo)
);

CREATE TABLE factura (
    numero INT IDENTITY(1,1) NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    total DECIMAL(18,2) NOT NULL DEFAULT 0,
    estado NVARCHAR(10) NOT NULL DEFAULT N'activa',
    fkidcliente INT NOT NULL,
    fkidvendedor INT NOT NULL,
    CONSTRAINT pk_factura PRIMARY KEY (numero),
    CONSTRAINT fk_factura_cliente FOREIGN KEY (fkidcliente) REFERENCES cliente(id),
    CONSTRAINT fk_factura_vendedor FOREIGN KEY (fkidvendedor) REFERENCES vendedor(id)
);

CREATE TABLE productosporfactura (
    fknumfactura INT NOT NULL,
    fkcodproducto NVARCHAR(10) NOT NULL,
    cantidad INT NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT pk_productosporfactura PRIMARY KEY (fknumfactura, fkcodproducto),
    CONSTRAINT fk_prodfact_factura FOREIGN KEY (fknumfactura) REFERENCES factura(numero) ON DELETE CASCADE,
    CONSTRAINT fk_prodfact_producto FOREIGN KEY (fkcodproducto) REFERENCES producto(codigo)
);

CREATE TABLE rol_usuario (
    fkemail NVARCHAR(100) NOT NULL,
    fkidrol INT NOT NULL,
    CONSTRAINT pk_rol_usuario PRIMARY KEY (fkemail, fkidrol),
    CONSTRAINT fk_rolusuario_usuario FOREIGN KEY (fkemail) REFERENCES usuario(email),
    CONSTRAINT fk_rolusuario_rol FOREIGN KEY (fkidrol) REFERENCES rol(id)
);

CREATE TABLE rutarol (
    fkidruta INT NOT NULL,
    fkidrol INT NOT NULL,
    CONSTRAINT pk_rutarol PRIMARY KEY (fkidruta, fkidrol),
    CONSTRAINT fk_rutarol_ruta FOREIGN KEY (fkidruta) REFERENCES ruta(id) ON DELETE CASCADE,
    CONSTRAINT fk_rutarol_rol FOREIGN KEY (fkidrol) REFERENCES rol(id) ON DELETE CASCADE
);
GO

-- ============================================================
-- TRIGGERS: Actualizar totales de factura y stock de producto
-- SQL Server requiere triggers AFTER separados por operación.
-- Se usan las tablas virtuales INSERTED y DELETED.
-- ============================================================

-- TRIGGER INSERT
CREATE TRIGGER trg_prodfact_insert
ON productosporfactura
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar stock suficiente para cada producto insertado
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN producto p ON p.codigo = i.fkcodproducto
        WHERE p.stock < i.cantidad
    )
    BEGIN
        DECLARE @v_codigo_err NVARCHAR(10), @v_stock_err INT, @v_cantidad_err INT;
        SELECT TOP 1 @v_codigo_err = i.fkcodproducto, @v_stock_err = p.stock, @v_cantidad_err = i.cantidad
        FROM inserted i
        JOIN producto p ON p.codigo = i.fkcodproducto
        WHERE p.stock < i.cantidad;

        DECLARE @v_msg_err NVARCHAR(500);
        SET @v_msg_err = CONCAT(N'Stock insuficiente para producto ', @v_codigo_err,
            N'. Stock disponible: ', @v_stock_err, N', cantidad solicitada: ', @v_cantidad_err);
        THROW 50001, @v_msg_err, 1;
    END

    -- Calcular subtotal = cantidad * valorunitario y actualizar la fila insertada
    UPDATE pf
    SET pf.subtotal = i.cantidad * p.valorunitario
    FROM productosporfactura pf
    JOIN inserted i ON pf.fknumfactura = i.fknumfactura AND pf.fkcodproducto = i.fkcodproducto
    JOIN producto p ON p.codigo = i.fkcodproducto;

    -- Descontar stock del producto
    UPDATE p
    SET p.stock = p.stock - i.cantidad
    FROM producto p
    JOIN inserted i ON p.codigo = i.fkcodproducto;

    -- Recalcular total de la factura
    UPDATE f
    SET f.total = ISNULL(sub.suma, 0)
    FROM factura f
    JOIN (
        SELECT pf.fknumfactura, SUM(pf.subtotal) AS suma
        FROM productosporfactura pf
        WHERE pf.fknumfactura IN (SELECT DISTINCT fknumfactura FROM inserted)
        GROUP BY pf.fknumfactura
    ) sub ON f.numero = sub.fknumfactura;
END;
GO

-- TRIGGER UPDATE
CREATE TRIGGER trg_prodfact_update
ON productosporfactura
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar stock suficiente (considerando la devolucion del stock anterior)
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.fknumfactura = d.fknumfactura AND i.fkcodproducto = d.fkcodproducto
        JOIN producto p ON p.codigo = i.fkcodproducto
        WHERE p.stock + d.cantidad < i.cantidad
    )
    BEGIN
        DECLARE @v_codigo_err NVARCHAR(10), @v_stock_err INT, @v_cantidad_err INT;
        SELECT TOP 1 @v_codigo_err = i.fkcodproducto, @v_stock_err = p.stock + d.cantidad, @v_cantidad_err = i.cantidad
        FROM inserted i
        JOIN deleted d ON i.fknumfactura = d.fknumfactura AND i.fkcodproducto = d.fkcodproducto
        JOIN producto p ON p.codigo = i.fkcodproducto
        WHERE p.stock + d.cantidad < i.cantidad;

        DECLARE @v_msg_err NVARCHAR(500);
        SET @v_msg_err = CONCAT(N'Stock insuficiente para producto ', @v_codigo_err,
            N'. Stock disponible: ', @v_stock_err, N', cantidad solicitada: ', @v_cantidad_err);
        THROW 50001, @v_msg_err, 1;
    END

    -- Recalcular subtotal
    UPDATE pf
    SET pf.subtotal = i.cantidad * p.valorunitario
    FROM productosporfactura pf
    JOIN inserted i ON pf.fknumfactura = i.fknumfactura AND pf.fkcodproducto = i.fkcodproducto
    JOIN producto p ON p.codigo = i.fkcodproducto;

    -- Ajustar stock: devolver old.cantidad y descontar new.cantidad
    UPDATE p
    SET p.stock = p.stock + d.cantidad - i.cantidad
    FROM producto p
    JOIN inserted i ON p.codigo = i.fkcodproducto
    JOIN deleted d ON d.fknumfactura = i.fknumfactura AND d.fkcodproducto = i.fkcodproducto;

    -- Recalcular total de la factura
    UPDATE f
    SET f.total = ISNULL(sub.suma, 0)
    FROM factura f
    JOIN (
        SELECT pf.fknumfactura, SUM(pf.subtotal) AS suma
        FROM productosporfactura pf
        WHERE pf.fknumfactura IN (SELECT DISTINCT fknumfactura FROM inserted)
        GROUP BY pf.fknumfactura
    ) sub ON f.numero = sub.fknumfactura;
END;
GO

-- TRIGGER DELETE
CREATE TRIGGER trg_prodfact_delete
ON productosporfactura
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Restaurar stock del producto
    UPDATE p
    SET p.stock = p.stock + d.cantidad
    FROM producto p
    JOIN deleted d ON p.codigo = d.fkcodproducto;

    -- Recalcular total de la factura
    UPDATE f
    SET f.total = ISNULL(sub.suma, 0)
    FROM factura f
    JOIN (
        SELECT d.fknumfactura,
               ISNULL((SELECT SUM(pf.subtotal) FROM productosporfactura pf WHERE pf.fknumfactura = d.fknumfactura), 0) AS suma
        FROM (SELECT DISTINCT fknumfactura FROM deleted) d
    ) sub ON f.numero = sub.fknumfactura;
END;
GO

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS - FACTURAS Y PRODUCTOS POR FACTURA
-- Los resultados se retornan via parámetro OUTPUT tipo NVARCHAR(MAX)
-- ============================================================

-- ------------------------------------------------------------
-- 1. SP INSERTAR FACTURA Y PRODUCTOSPORFACTURA
-- Recibe: id cliente, id vendedor, y un JSON array de productos
-- Retorna: JSON con la factura creada y sus productos
-- Nota: El trigger se encarga de calcular subtotal, descontar
--       stock y actualizar total factura.
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "sp_insertar_factura_y_productosporfactura",
--     "p_fkidcliente": 1, "p_fkidvendedor": 1,
--     "p_productos": "[{\"codigo\":\"PR001\",\"cantidad\":2},{\"codigo\":\"PR003\",\"cantidad\":3}]",
--     "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE sp_insertar_factura_y_productosporfactura
    @p_fkidcliente INT,
    @p_fkidvendedor INT,
    @p_productos NVARCHAR(MAX),
    @p_minimo_detalle INT = 1,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_numero INT;
    DECLARE @v_codigo NVARCHAR(10);
    DECLARE @v_cantidad INT;
    DECLARE @v_minimo INT;
    DECLARE @v_count INT;
    DECLARE @v_msg NVARCHAR(500);

    -- Validar minimo de productos (antes de abrir transaccion)
    -- COALESCE(NULLIF(@p_minimo_detalle, 0), 1): la API envia 0 cuando no se pasa el parametro
    SET @v_minimo = COALESCE(NULLIF(@p_minimo_detalle, 0), 1);

    IF @p_productos IS NULL
    BEGIN
        SET @v_msg = CONCAT(N'La factura requiere minimo ', @v_minimo, N' producto(s).');
        THROW 50002, @v_msg, 1;
    END

    SELECT @v_count = COUNT(*) FROM OPENJSON(@p_productos);
    IF @v_count < @v_minimo
    BEGIN
        SET @v_msg = CONCAT(N'La factura requiere minimo ', @v_minimo, N' producto(s).');
        THROW 50002, @v_msg, 1;
    END

    -- ── TRANSACCION: todo o nada ──
    -- Si un trigger falla (ej: stock insuficiente en el 2do producto),
    -- se revierte la factura y todos los productos insertados previamente.
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Crear la factura con total 0 (el trigger actualiza el total)
        INSERT INTO factura (fkidcliente, fkidvendedor, total)
        VALUES (@p_fkidcliente, @p_fkidvendedor, 0);

        SET @v_numero = SCOPE_IDENTITY();

        -- Recorrer cada producto del JSON e insertar detalle
        -- El trigger calcula subtotal, descuenta stock y actualiza total
        DECLARE producto_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT
                JSON_VALUE(value, '$.codigo'),
                CAST(JSON_VALUE(value, '$.cantidad') AS INT)
            FROM OPENJSON(@p_productos);

        OPEN producto_cursor;
        FETCH NEXT FROM producto_cursor INTO @v_codigo, @v_cantidad;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO productosporfactura (fknumfactura, fkcodproducto, cantidad, subtotal)
            VALUES (@v_numero, @v_codigo, @v_cantidad, 0);

            FETCH NEXT FROM producto_cursor INTO @v_codigo, @v_cantidad;
        END

        CLOSE producto_cursor;
        DEALLOCATE producto_cursor;

        -- Retornar resultado como JSON
        DECLARE @v_factura_json NVARCHAR(MAX);
        DECLARE @v_productos_json NVARCHAR(MAX);

        SELECT @v_factura_json = (
            SELECT f.numero, f.fecha, f.total, f.estado, f.fkidcliente, f.fkidvendedor
            FROM factura f WHERE f.numero = @v_numero
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        SELECT @v_productos_json = (
            SELECT pf.fkcodproducto AS codigo_producto, pr.nombre AS nombre_producto,
                   pf.cantidad, pr.valorunitario, pf.subtotal
            FROM productosporfactura pf
            JOIN producto pr ON pr.codigo = pf.fkcodproducto
            WHERE pf.fknumfactura = @v_numero
            FOR JSON PATH
        );

        SET @p_resultado = N'{"factura":' + @v_factura_json + N',"productos":' + ISNULL(@v_productos_json, N'[]') + N'}';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Cerrar cursor si quedo abierto
        IF CURSOR_STATUS('local', 'producto_cursor') >= 0
        BEGIN
            CLOSE producto_cursor;
            DEALLOCATE producto_cursor;
        END;

        -- Relanzar el error original (del trigger u otro)
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------
-- 2. SP CONSULTAR FACTURA Y PRODUCTOSPORFACTURA
-- Consulta una factura por número con detalle de productos,
-- nombre del cliente y nombre del vendedor
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "sp_consultar_factura_y_productosporfactura",
--     "p_numero": 1, "p_resultado": "" }
-- ------------------------------------------------------------
CREATE PROCEDURE sp_consultar_factura_y_productosporfactura
    @p_numero INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM factura WHERE numero = @p_numero)
    BEGIN
        DECLARE @v_msg NVARCHAR(500);
        SET @v_msg = CONCAT(N'Factura ', @p_numero, N' no existe');
        THROW 50003, @v_msg, 1;
    END

    DECLARE @v_factura_json NVARCHAR(MAX);
    DECLARE @v_productos_json NVARCHAR(MAX);

    SELECT @v_factura_json = (
        SELECT f.numero, f.fecha, f.total, f.estado, f.fkidcliente,
               pc.nombre AS nombre_cliente,
               f.fkidvendedor,
               pv.nombre AS nombre_vendedor
        FROM factura f
        JOIN cliente c ON c.id = f.fkidcliente
        JOIN persona pc ON pc.codigo = c.fkcodpersona
        JOIN vendedor v ON v.id = f.fkidvendedor
        JOIN persona pv ON pv.codigo = v.fkcodpersona
        WHERE f.numero = @p_numero
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT @v_productos_json = (
        SELECT pr.codigo AS codigo_producto, pr.nombre AS nombre_producto,
               pf.cantidad, pr.valorunitario, pf.subtotal
        FROM productosporfactura pf
        JOIN producto pr ON pr.codigo = pf.fkcodproducto
        WHERE pf.fknumfactura = @p_numero
        FOR JSON PATH
    );

    SET @p_resultado = N'{"factura":' + @v_factura_json + N',"productos":' + ISNULL(@v_productos_json, N'[]') + N'}';
END;
GO

-- ------------------------------------------------------------
-- 3. SP LISTAR FACTURAS Y PRODUCTOSPORFACTURA
-- Lista todas las facturas con sus productos, cliente y vendedor
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "sp_listar_facturas_y_productosporfactura",
--     "p_resultado": "" }
-- ------------------------------------------------------------
CREATE PROCEDURE sp_listar_facturas_y_productosporfactura
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_result NVARCHAR(MAX) = N'[';
    DECLARE @v_numero INT;
    DECLARE @v_factura_json NVARCHAR(MAX);
    DECLARE @v_productos_json NVARCHAR(MAX);
    DECLARE @v_first BIT = 1;

    DECLARE factura_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT f.numero
        FROM factura f
        ORDER BY f.numero;

    OPEN factura_cursor;
    FETCH NEXT FROM factura_cursor INTO @v_numero;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @v_first = 0
            SET @v_result = @v_result + N',';
        SET @v_first = 0;

        SELECT @v_factura_json = (
            SELECT f.numero, f.fecha, f.total, f.fkidcliente,
                   pc.nombre AS nombre_cliente,
                   f.fkidvendedor,
                   pv.nombre AS nombre_vendedor
            FROM factura f
            JOIN cliente c ON c.id = f.fkidcliente
            JOIN persona pc ON pc.codigo = c.fkcodpersona
            JOIN vendedor v ON v.id = f.fkidvendedor
            JOIN persona pv ON pv.codigo = v.fkcodpersona
            WHERE f.numero = @v_numero
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        SELECT @v_productos_json = (
            SELECT pr.codigo AS codigo_producto, pr.nombre AS nombre_producto,
                   pf.cantidad, pr.valorunitario, pf.subtotal
            FROM productosporfactura pf
            JOIN producto pr ON pr.codigo = pf.fkcodproducto
            WHERE pf.fknumfactura = @v_numero
            FOR JSON PATH
        );

        SET @v_result = @v_result + N'{' +
            N'"numero":' + CAST(@v_numero AS NVARCHAR) + N',' +
            N'"fecha":"' + CONVERT(NVARCHAR(30), (SELECT fecha FROM factura WHERE numero = @v_numero), 126) + N'",' +
            N'"total":' + CAST((SELECT total FROM factura WHERE numero = @v_numero) AS NVARCHAR) + N',' +
            N'"estado":"' + (SELECT estado FROM factura WHERE numero = @v_numero) + N'",' +
            N'"fkidcliente":' + CAST((SELECT fkidcliente FROM factura WHERE numero = @v_numero) AS NVARCHAR) + N',' +
            N'"nombre_cliente":"' + (SELECT pc.nombre FROM factura f JOIN cliente c ON c.id = f.fkidcliente JOIN persona pc ON pc.codigo = c.fkcodpersona WHERE f.numero = @v_numero) + N'",' +
            N'"fkidvendedor":' + CAST((SELECT fkidvendedor FROM factura WHERE numero = @v_numero) AS NVARCHAR) + N',' +
            N'"nombre_vendedor":"' + (SELECT pv.nombre FROM factura f JOIN vendedor v ON v.id = f.fkidvendedor JOIN persona pv ON pv.codigo = v.fkcodpersona WHERE f.numero = @v_numero) + N'",' +
            N'"productos":' + ISNULL(@v_productos_json, N'[]') +
            N'}';

        FETCH NEXT FROM factura_cursor INTO @v_numero;
    END

    CLOSE factura_cursor;
    DEALLOCATE factura_cursor;

    SET @v_result = @v_result + N']';

    -- Si no hay facturas, retornar array vacio
    IF @v_first = 1
        SET @v_result = N'[]';

    SET @p_resultado = @v_result;
END;
GO

-- ------------------------------------------------------------
-- 4. SP ACTUALIZAR FACTURA Y PRODUCTOSPORFACTURA
-- Reemplaza los productos de una factura existente.
-- Nota: El trigger se encarga de restaurar stock (DELETE),
--       descontar stock (INSERT) y recalcular subtotales/total.
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "sp_actualizar_factura_y_productosporfactura",
--     "p_numero": 1, "p_fkidcliente": 2, "p_fkidvendedor": 1,
--     "p_productos": "[{\"codigo\":\"PR002\",\"cantidad\":1},{\"codigo\":\"PR004\",\"cantidad\":5}]",
--     "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE sp_actualizar_factura_y_productosporfactura
    @p_numero INT,
    @p_fkidcliente INT,
    @p_fkidvendedor INT,
    @p_productos NVARCHAR(MAX),
    @p_minimo_detalle INT = 1,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_codigo NVARCHAR(10);
    DECLARE @v_cantidad INT;
    DECLARE @v_minimo INT;
    DECLARE @v_count INT;
    DECLARE @v_msg NVARCHAR(500);

    -- Validaciones antes de abrir transaccion
    IF NOT EXISTS (SELECT 1 FROM factura WHERE numero = @p_numero)
    BEGIN
        SET @v_msg = CONCAT(N'Factura ', @p_numero, N' no existe');
        THROW 50004, @v_msg, 1;
    END

    SET @v_minimo = COALESCE(NULLIF(@p_minimo_detalle, 0), 1);

    IF @p_productos IS NULL
    BEGIN
        SET @v_msg = CONCAT(N'La factura requiere minimo ', @v_minimo, N' producto(s).');
        THROW 50004, @v_msg, 1;
    END

    SELECT @v_count = COUNT(*) FROM OPENJSON(@p_productos);
    IF @v_count < @v_minimo
    BEGIN
        SET @v_msg = CONCAT(N'La factura requiere minimo ', @v_minimo, N' producto(s).');
        THROW 50004, @v_msg, 1;
    END

    -- ── TRANSACCION: todo o nada ──
    -- Si un trigger falla al insertar un nuevo producto (ej: stock insuficiente),
    -- se revierten todos los cambios: el DELETE previo, los INSERTs parciales y el UPDATE.
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Eliminar detalle anterior (el trigger restaura stock y recalcula total)
        DELETE FROM productosporfactura WHERE fknumfactura = @p_numero;

        -- Insertar nuevos productos (el trigger calcula subtotal, descuenta stock, actualiza total)
        DECLARE producto_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT
                JSON_VALUE(value, '$.codigo'),
                CAST(JSON_VALUE(value, '$.cantidad') AS INT)
            FROM OPENJSON(@p_productos);

        OPEN producto_cursor;
        FETCH NEXT FROM producto_cursor INTO @v_codigo, @v_cantidad;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO productosporfactura (fknumfactura, fkcodproducto, cantidad, subtotal)
            VALUES (@p_numero, @v_codigo, @v_cantidad, 0);

            FETCH NEXT FROM producto_cursor INTO @v_codigo, @v_cantidad;
        END

        CLOSE producto_cursor;
        DEALLOCATE producto_cursor;

        -- Actualizar cliente y vendedor de la factura
        UPDATE factura
        SET fkidcliente = @p_fkidcliente,
            fkidvendedor = @p_fkidvendedor
        WHERE numero = @p_numero;

        -- Retornar resultado como JSON
        DECLARE @v_factura_json NVARCHAR(MAX);
        DECLARE @v_productos_json NVARCHAR(MAX);

        SELECT @v_factura_json = (
            SELECT f.numero, f.fecha, f.total, f.estado, f.fkidcliente, f.fkidvendedor
            FROM factura f WHERE f.numero = @p_numero
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        SELECT @v_productos_json = (
            SELECT pf.fkcodproducto AS codigo_producto, pr.nombre AS nombre_producto,
                   pf.cantidad, pr.valorunitario, pf.subtotal
            FROM productosporfactura pf
            JOIN producto pr ON pr.codigo = pf.fkcodproducto
            WHERE pf.fknumfactura = @p_numero
            FOR JSON PATH
        );

        SET @p_resultado = N'{"factura":' + @v_factura_json + N',"productos":' + ISNULL(@v_productos_json, N'[]') + N'}';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF CURSOR_STATUS('local', 'producto_cursor') >= 0
        BEGIN
            CLOSE producto_cursor;
            DEALLOCATE producto_cursor;
        END;

        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------
-- 5. SP BORRAR FACTURA Y PRODUCTOSPORFACTURA
-- ON DELETE CASCADE elimina productosporfactura automáticamente.
-- El trigger restaura stock al borrar cada producto de la factura.
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "sp_borrar_factura_y_productosporfactura",
--     "p_numero": 1, "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE sp_borrar_factura_y_productosporfactura
    @p_numero INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_total DECIMAL(18,2);
    DECLARE @v_cantidad_productos INT;
    DECLARE @v_msg NVARCHAR(500);

    -- Validacion antes de abrir transaccion
    IF NOT EXISTS (SELECT 1 FROM factura WHERE numero = @p_numero)
    BEGIN
        SET @v_msg = CONCAT(N'Factura ', @p_numero, N' no existe');
        THROW 50005, @v_msg, 1;
    END

    -- ── TRANSACCION: todo o nada ──
    -- El DELETE CASCADE dispara el trigger de delete para cada producto,
    -- restaurando stock. Si algo falla, se revierte todo.
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Guardar info antes de borrar para el JSON de respuesta
        SELECT @v_cantidad_productos = COUNT(*)
        FROM productosporfactura WHERE fknumfactura = @p_numero;

        SELECT @v_total = f.total FROM factura f WHERE f.numero = @p_numero;

        -- Borrar factura (ON DELETE CASCADE borra productosporfactura,
        -- y el trigger restaura stock por cada producto eliminado)
        DELETE FROM factura WHERE numero = @p_numero;

        -- Retornar resultado como JSON
        SET @p_resultado = N'{"mensaje":"Factura eliminada exitosamente",' +
            N'"numero_eliminado":' + CAST(@p_numero AS NVARCHAR) + N',' +
            N'"total_eliminado":' + CAST(@v_total AS NVARCHAR) + N',' +
            N'"productos_eliminados":' + CAST(@v_cantidad_productos AS NVARCHAR) + N'}';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------
-- 6. SP ANULAR FACTURA (borrado lógico)
-- Cambia el estado de la factura a 'anulada' y restaura el stock
-- de todos los productos. NO elimina la factura de la BD.
-- El borrado físico (DELETE) solo lo puede hacer el admin via
-- sp_borrar_factura_y_productosporfactura.
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "sp_anular_factura",
--     "p_numero": 1, "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE sp_anular_factura
    @p_numero INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_total DECIMAL(18,2);
    DECLARE @v_cantidad_productos INT;
    DECLARE @v_estado NVARCHAR(10);
    DECLARE @v_msg NVARCHAR(500);

    -- Validar que la factura existe
    IF NOT EXISTS (SELECT 1 FROM factura WHERE numero = @p_numero)
    BEGIN
        SET @v_msg = CONCAT(N'Factura ', @p_numero, N' no existe');
        THROW 50010, @v_msg, 1;
    END

    -- Validar que no esté ya anulada
    SELECT @v_estado = estado FROM factura WHERE numero = @p_numero;
    IF @v_estado = N'anulada'
    BEGIN
        SET @v_msg = CONCAT(N'Factura ', @p_numero, N' ya está anulada');
        THROW 50010, @v_msg, 1;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Restaurar stock de todos los productos de la factura
        UPDATE p
        SET p.stock = p.stock + pf.cantidad
        FROM producto p
        JOIN productosporfactura pf ON p.codigo = pf.fkcodproducto
        WHERE pf.fknumfactura = @p_numero;

        -- Guardar info para la respuesta
        SELECT @v_total = total FROM factura WHERE numero = @p_numero;
        SELECT @v_cantidad_productos = COUNT(*) FROM productosporfactura WHERE fknumfactura = @p_numero;

        -- Cambiar estado a 'anulada'
        UPDATE factura SET estado = N'anulada' WHERE numero = @p_numero;

        -- Retornar resultado como JSON
        SET @p_resultado = N'{"mensaje":"Factura anulada exitosamente",' +
            N'"numero_anulado":' + CAST(@p_numero AS NVARCHAR) + N',' +
            N'"total_anulado":' + CAST(@v_total AS NVARCHAR) + N',' +
            N'"productos_afectados":' + CAST(@v_cantidad_productos AS NVARCHAR) + N',' +
            N'"estado":"anulada"}';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS - USUARIOS CON ROLES
-- Nota: El cifrado lo hace la API C# con el parámetro camposEncriptar
-- ============================================================

-- ------------------------------------------------------------
-- 6. SP CREAR USUARIO CON ROLES
-- Recibe: email, contraseña y JSON array de roles [{"fkidrol":1},...]
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "crear_usuario_con_roles",
--     "p_email": "user@correo.com", "p_contrasena": "pass123",
--     "p_roles_json": "[{\"fkidrol\":1},{\"fkidrol\":2}]",
--     "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE crear_usuario_con_roles
    @p_email NVARCHAR(100),
    @p_contrasena NVARCHAR(200),
    @p_roles_json NVARCHAR(MAX),
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_idrol INT;
    DECLARE @v_roles_json NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar el usuario
        INSERT INTO usuario (email, contrasena) VALUES (@p_email, @p_contrasena);

        -- Insertar los roles del usuario
        DECLARE rol_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT CAST(JSON_VALUE(value, '$.fkidrol') AS INT)
            FROM OPENJSON(@p_roles_json);

        OPEN rol_cursor;
        FETCH NEXT FROM rol_cursor INTO @v_idrol;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO rol_usuario (fkemail, fkidrol) VALUES (@p_email, @v_idrol);
            FETCH NEXT FROM rol_cursor INTO @v_idrol;
        END

        CLOSE rol_cursor;
        DEALLOCATE rol_cursor;

        -- Retornar resultado como JSON
        SELECT @v_roles_json = (
            SELECT r.id AS idrol, r.nombre
            FROM rol_usuario ru
            JOIN rol r ON r.id = ru.fkidrol
            WHERE ru.fkemail = @p_email
            FOR JSON PATH
        );

        SET @p_resultado = N'{"email":"' + @p_email + N'","roles":' + ISNULL(@v_roles_json, N'[]') + N'}';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF CURSOR_STATUS('local', 'rol_cursor') >= 0
        BEGIN
            CLOSE rol_cursor;
            DEALLOCATE rol_cursor;
        END;

        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------
-- 7. SP ACTUALIZAR USUARIO CON ROLES
-- Actualiza contraseña (si no está vacía) y reemplaza roles
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "actualizar_usuario_con_roles",
--     "p_email": "user@correo.com", "p_contrasena": "newpass",
--     "p_roles": "[{\"fkidrol\":1},{\"fkidrol\":3}]",
--     "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE actualizar_usuario_con_roles
    @p_email NVARCHAR(100),
    @p_contrasena NVARCHAR(200),
    @p_roles NVARCHAR(MAX),
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_idrol INT;
    DECLARE @v_roles_json NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar la contraseña solo si no está vacía
        IF @p_contrasena IS NOT NULL AND @p_contrasena != N''
            UPDATE usuario SET contrasena = @p_contrasena WHERE email = @p_email;

        -- Eliminar los roles anteriores
        DELETE FROM rol_usuario WHERE fkemail = @p_email;

        -- Insertar los nuevos roles
        DECLARE rol_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT CAST(JSON_VALUE(value, '$.fkidrol') AS INT)
            FROM OPENJSON(@p_roles);

        OPEN rol_cursor;
        FETCH NEXT FROM rol_cursor INTO @v_idrol;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO rol_usuario (fkemail, fkidrol) VALUES (@p_email, @v_idrol);
            FETCH NEXT FROM rol_cursor INTO @v_idrol;
        END

        CLOSE rol_cursor;
        DEALLOCATE rol_cursor;

        -- Retornar resultado como JSON
        SELECT @v_roles_json = (
            SELECT r.id AS idrol, r.nombre
            FROM rol_usuario ru
            JOIN rol r ON r.id = ru.fkidrol
            WHERE ru.fkemail = @p_email
            FOR JSON PATH
        );

        SET @p_resultado = N'{"email":"' + @p_email + N'","roles":' + ISNULL(@v_roles_json, N'[]') + N'}';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF CURSOR_STATUS('local', 'rol_cursor') >= 0
        BEGIN
            CLOSE rol_cursor;
            DEALLOCATE rol_cursor;
        END;

        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------
-- 8. SP ELIMINAR USUARIO CON ROLES
-- Elimina el usuario (ON DELETE CASCADE borra sus roles)
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "eliminar_usuario_con_roles",
--     "p_email": "user@correo.com", "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE eliminar_usuario_con_roles
    @p_email NVARCHAR(100),
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_msg NVARCHAR(500);

    IF NOT EXISTS (SELECT 1 FROM usuario WHERE email = @p_email)
    BEGIN
        SET @v_msg = CONCAT(N'Usuario ', @p_email, N' no existe');
        THROW 50006, @v_msg, 1;
    END

    -- Eliminar roles del usuario primero (FK sin CASCADE)
    DELETE FROM rol_usuario WHERE fkemail = @p_email;
    DELETE FROM usuario WHERE email = @p_email;

    SET @p_resultado = N'{"mensaje":"Usuario eliminado exitosamente","email_eliminado":"' + @p_email + N'"}';
END;
GO

-- ------------------------------------------------------------
-- 9. SP ACTUALIZAR ROLES DE USUARIO
-- Solo reemplaza los roles sin tocar la contraseña
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "actualizar_roles_usuario",
--     "p_email": "user@correo.com",
--     "p_roles_json": "[{\"fkidrol\":1},{\"fkidrol\":2}]",
--     "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE actualizar_roles_usuario
    @p_email NVARCHAR(100),
    @p_roles_json NVARCHAR(MAX),
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_idrol INT;
    DECLARE @v_roles_json NVARCHAR(MAX);
    DECLARE @v_msg NVARCHAR(500);

    IF NOT EXISTS (SELECT 1 FROM usuario WHERE email = @p_email)
    BEGIN
        SET @v_msg = CONCAT(N'Usuario ', @p_email, N' no existe');
        THROW 50007, @v_msg, 1;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Eliminar los roles anteriores
        DELETE FROM rol_usuario WHERE fkemail = @p_email;

        -- Insertar los nuevos roles
        DECLARE rol_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT CAST(JSON_VALUE(value, '$.fkidrol') AS INT)
            FROM OPENJSON(@p_roles_json);

        OPEN rol_cursor;
        FETCH NEXT FROM rol_cursor INTO @v_idrol;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO rol_usuario (fkemail, fkidrol) VALUES (@p_email, @v_idrol);
            FETCH NEXT FROM rol_cursor INTO @v_idrol;
        END

        CLOSE rol_cursor;
        DEALLOCATE rol_cursor;

        -- Retornar resultado como JSON
        SELECT @v_roles_json = (
            SELECT r.id AS idrol, r.nombre
            FROM rol_usuario ru
            JOIN rol r ON r.id = ru.fkidrol
            WHERE ru.fkemail = @p_email
            FOR JSON PATH
        );

        SET @p_resultado = N'{"email":"' + @p_email + N'","roles":' + ISNULL(@v_roles_json, N'[]') + N'}';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF CURSOR_STATUS('local', 'rol_cursor') >= 0
        BEGIN
            CLOSE rol_cursor;
            DEALLOCATE rol_cursor;
        END;

        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------
-- 10. SP CONSULTAR USUARIO CON ROLES
-- Retorna JSON con email y array de roles
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "consultar_usuario_con_roles",
--     "p_email": "admin@correo.com", "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE consultar_usuario_con_roles
    @p_email NVARCHAR(100),
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_roles_json NVARCHAR(MAX);
    DECLARE @v_msg NVARCHAR(500);

    IF NOT EXISTS (SELECT 1 FROM usuario WHERE email = @p_email)
    BEGIN
        SET @v_msg = CONCAT(N'Usuario ', @p_email, N' no existe');
        THROW 50008, @v_msg, 1;
    END

    SELECT @v_roles_json = (
        SELECT r.id AS idrol, r.nombre
        FROM rol_usuario ru
        JOIN rol r ON r.id = ru.fkidrol
        WHERE ru.fkemail = @p_email
        FOR JSON PATH
    );

    SET @p_resultado = N'{"email":"' + @p_email + N'","roles":' + ISNULL(@v_roles_json, N'[]') + N'}';
END;
GO

-- ------------------------------------------------------------
-- 11. SP LISTAR USUARIOS CON ROLES
-- Retorna JSON array con todos los usuarios y sus roles
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "listar_usuarios_con_roles", "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE listar_usuarios_con_roles
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_result NVARCHAR(MAX) = N'[';
    DECLARE @v_email NVARCHAR(100);
    DECLARE @v_roles_json NVARCHAR(MAX);
    DECLARE @v_first BIT = 1;

    DECLARE usuario_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT email FROM usuario ORDER BY email;

    OPEN usuario_cursor;
    FETCH NEXT FROM usuario_cursor INTO @v_email;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @v_first = 0
            SET @v_result = @v_result + N',';
        SET @v_first = 0;

        SELECT @v_roles_json = (
            SELECT r.id AS idrol, r.nombre
            FROM rol_usuario ru
            JOIN rol r ON r.id = ru.fkidrol
            WHERE ru.fkemail = @v_email
            FOR JSON PATH
        );

        SET @v_result = @v_result + N'{"email":"' + @v_email + N'","roles":' + ISNULL(@v_roles_json, N'[]') + N'}';

        FETCH NEXT FROM usuario_cursor INTO @v_email;
    END

    CLOSE usuario_cursor;
    DEALLOCATE usuario_cursor;

    SET @v_result = @v_result + N']';

    IF @v_first = 1
        SET @v_result = N'[]';

    SET @p_resultado = @v_result;
END;
GO

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS - PERMISOS (RBAC)
-- ============================================================

-- ------------------------------------------------------------
-- 12. SP VERIFICAR ACCESO A RUTA
-- Verifica si un usuario tiene permiso para acceder a una ruta
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "verificar_acceso_ruta",
--     "p_email": "admin@correo.com", "p_fkidruta": 2,
--     "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE verificar_acceso_ruta
    @p_email NVARCHAR(100),
    @p_fkidruta INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_tiene_acceso BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM usuario u
        INNER JOIN rol_usuario ur ON u.email = ur.fkemail
        INNER JOIN rutarol rr ON ur.fkidrol = rr.fkidrol
        WHERE u.email = @p_email AND rr.fkidruta = @p_fkidruta
    )
        SET @v_tiene_acceso = 1;

    SET @p_resultado = N'{"tiene_acceso":' + CAST(@v_tiene_acceso AS NVARCHAR) +
        N',"email":"' + @p_email + N'","fkidruta":' + CAST(@p_fkidruta AS NVARCHAR) + N'}';
END;
GO

-- ------------------------------------------------------------
-- 13. SP LISTAR RUTAROL
-- Lista todos los permisos ruta-rol con nombres
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "listar_rutarol", "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE listar_rutarol
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @p_resultado = (
        SELECT rr.fkidruta, rt.ruta, rr.fkidrol, r.nombre AS rol
        FROM rutarol rr
        JOIN ruta rt ON rt.id = rr.fkidruta
        JOIN rol r ON r.id = rr.fkidrol
        ORDER BY rt.ruta, r.nombre
        FOR JSON PATH
    );

    SET @p_resultado = ISNULL(@p_resultado, N'[]');
END;
GO

-- ------------------------------------------------------------
-- 14. SP CREAR RUTAROL
-- Asigna un rol a una ruta por IDs
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "crear_rutarol",
--     "p_fkidruta": 8, "p_fkidrol": 3,
--     "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE crear_rutarol
    @p_fkidruta INT,
    @p_fkidrol INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la ruta existe
    IF NOT EXISTS (SELECT 1 FROM ruta WHERE id = @p_fkidruta)
    BEGIN
        SET @p_resultado = N'{"success":false,"message":"La ruta especificada no existe"}';
        RETURN;
    END

    -- Verificar si el rol existe
    IF NOT EXISTS (SELECT 1 FROM rol WHERE id = @p_fkidrol)
    BEGIN
        SET @p_resultado = N'{"success":false,"message":"El rol especificado no existe"}';
        RETURN;
    END

    -- Verificar si el permiso ya existe
    IF EXISTS (SELECT 1 FROM rutarol WHERE fkidruta = @p_fkidruta AND fkidrol = @p_fkidrol)
    BEGIN
        SET @p_resultado = N'{"success":false,"message":"El permiso ya existe"}';
        RETURN;
    END

    INSERT INTO rutarol (fkidruta, fkidrol) VALUES (@p_fkidruta, @p_fkidrol);
    SET @p_resultado = N'{"success":true,"message":"Permiso creado exitosamente"}';
END;
GO

-- ------------------------------------------------------------
-- 15. SP ELIMINAR RUTAROL
-- Quita un permiso ruta-rol por IDs
-- Ejemplo via API:
--   POST /api/procedimientos/ejecutarsp
--   { "nombreSP": "eliminar_rutarol",
--     "p_fkidruta": 8, "p_fkidrol": 3,
--     "p_resultado": null }
-- ------------------------------------------------------------
CREATE PROCEDURE eliminar_rutarol
    @p_fkidruta INT,
    @p_fkidrol INT,
    @p_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el permiso existe
    IF NOT EXISTS (SELECT 1 FROM rutarol WHERE fkidruta = @p_fkidruta AND fkidrol = @p_fkidrol)
    BEGIN
        SET @p_resultado = N'{"success":false,"message":"El permiso no existe"}';
        RETURN;
    END

    DELETE FROM rutarol WHERE fkidruta = @p_fkidruta AND fkidrol = @p_fkidrol;
    SET @p_resultado = N'{"success":true,"message":"Permiso eliminado exitosamente"}';
END;
GO

-- ============================================================
-- DATOS
-- ============================================================

-- Empresas
INSERT INTO empresa (codigo, nombre) VALUES
(N'E001', N'Comercial Los Andes S.A.'),
(N'E002', N'Distribuciones El Centro S.A.'),
(N'E999', N'Empresa Test');

-- Personas
INSERT INTO persona (codigo, nombre, email, telefono) VALUES
(N'P001', N'Ana Torres', N'ana.torres@correo.com', N'3011111111'),
(N'P002', N'Carlos Pérez', N'carlos.perez@correo.com', N'3022222222'),
(N'P003', N'María Gómez', N'maria.gomez@correo.com', N'3033333333'),
(N'P004', N'Juan Díaz', N'juan.diaz@correo.com', N'3044444444'),
(N'P005', N'Laura Rojas', N'laura.rojas@correo.com', N'3055555555'),
(N'P006', N'Pedro Castillo', N'pedro.castillo@correo.com', N'3066666666');

-- Productos
INSERT INTO producto (codigo, nombre, stock, valorunitario) VALUES
(N'PR001', N'Laptop Lenovo IdeaPad', 17, 2500000),
(N'PR002', N'Monitor Samsung 24"', 27, 800000),
(N'PR003', N'Teclado Logitech K380', 42, 150000),
(N'PR004', N'Mouse HP', 55, 90000),
(N'PR005', N'Impresora Epson EcoTank1', 14, 1100000),
(N'PR006', N'Auriculares Sony WH-CH510', 23, 240000),
(N'PR007', N'Tablet Samsung Tab A9', 15, 950000),
(N'PR008', N'Disco Duro Seagate 1TB', 32, 280000);

-- Roles (con IDENTITY_INSERT para IDs explícitos)
SET IDENTITY_INSERT rol ON;
INSERT INTO rol (id, nombre) VALUES
(1, N'Administrador'),
(2, N'Vendedor'),
(3, N'Cajero'),
(4, N'Contador'),
(5, N'Cliente');
SET IDENTITY_INSERT rol OFF;

-- Rutas
INSERT INTO ruta (ruta, descripcion) VALUES
(N'/home', N'Página principal - Dashboard'),
(N'/usuario', N'Gestión de usuarios'),
(N'/factura', N'Gestión de facturas'),
(N'/cliente', N'Gestión de clientes'),
(N'/vendedor', N'Gestión de vendedores'),
(N'/persona', N'Gestión de personas'),
(N'/empresa', N'Gestión de empresas'),
(N'/producto', N'Gestión de productos'),
(N'/rol', N'Gestión de roles'),
(N'/permiso', N'Gestión de permisos (asignación rol-ruta)'),
(N'/permiso/crear', N'Crear permiso (POST)'),
(N'/permiso/eliminar', N'Eliminar permiso (POST)'),
(N'/ruta', N'Gestión de rutas del sistema'),
(N'/ruta/crear', N'Crear ruta (POST)'),
(N'/ruta/eliminar', N'Eliminar ruta (POST)');

-- Usuarios
INSERT INTO usuario (email, contrasena) VALUES
(N'admin@correo.com', N'$2a$12$3UgI.Eof.FhzsYUWESI9n.qFaqkV2JPhvW3L/1GTKowNJnGaD8F.G'),
(N'vendedor1@correo.com', N'$2a$12$Dgog4VaHqMzhliPVJy1BcOMd6.izEGNeRDtZ.O7SPmBLc6UVthVTG'),
(N'jefe@correo.com', N'jefe123'),
(N'cliente1@correo.com', N'cli123'),
(N'test_encript@correo.com', N'$2a$11$Ci0J2yBltDgQHfjadgkl0OtbcF5pUf97vTq/4Xr0KEU/86l8ybjBe'),
(N'nuevo@correo.com', N'$2a$11$cmtGBxllwc7MCzpnKVSWuumiOgCaG6PaKWcN1z9N0bjjnkobbFDzO'),
(N'carlos.castro@usbmed.edu.co', N'$2a$10$YYl6bHCflCnk8suUrms3ie.rnpLvfD9nHJtehZwhcSkINelGwt6iC'),
(N'carloscastro5033@correo.itm.edu.co', N'$2a$10$YYl6bHCflCnk8suUrms3ie.rnpLvfD9nHJtehZwhcSkINelGwt6iC');

-- Clientes (con IDENTITY_INSERT para IDs explícitos)
SET IDENTITY_INSERT cliente ON;
INSERT INTO cliente (id, credito, fkcodpersona, fkcodempresa) VALUES
(1, 520000, N'P001', N'E001'),
(2, 250000, N'P003', N'E002'),
(3, 400000, N'P005', N'E001'),
(5, 700000, N'P006', N'E001');
SET IDENTITY_INSERT cliente OFF;

-- Vendedores (con IDENTITY_INSERT para IDs explícitos)
SET IDENTITY_INSERT vendedor ON;
INSERT INTO vendedor (id, carnet, direccion, fkcodpersona) VALUES
(1, 1001, N'Calle 10 #5-33', N'P002'),
(2, 1002, N'Carrera 15 #7-20', N'P004'),
(3, 1003, N'Avenida 30 #18-09', N'P006');
SET IDENTITY_INSERT vendedor OFF;

-- Facturas (con IDENTITY_INSERT para IDs explícitos)
-- Nota: los totales se insertan como 0, pero como los triggers están
-- deshabilitados para la carga de datos semilla, insertamos los totales directamente.
-- Primero deshabilitamos los triggers para la carga de datos semilla.
DISABLE TRIGGER trg_prodfact_insert ON productosporfactura;
DISABLE TRIGGER trg_prodfact_update ON productosporfactura;
DISABLE TRIGGER trg_prodfact_delete ON productosporfactura;
GO

SET IDENTITY_INSERT factura ON;
INSERT INTO factura (numero, fecha, total, fkidcliente, fkidvendedor) VALUES
(1, N'2025-12-03 12:57:19.2759200', 5000000, 1, 1),
(2, N'2025-12-03 12:57:19.2759200', 1250000, 2, 2),
(3, N'2025-12-03 12:57:19.2759200', 2030000, 3, 3),
(4, N'2025-12-03 13:04:59.0286130', 950000, 1, 1),
(5, N'2025-12-03 13:05:17.8743850', 2740000, 2, 2),
(6, N'2025-12-03 13:05:35.0284600', 4850000, 3, 3);
SET IDENTITY_INSERT factura OFF;

-- Productos por factura (triggers deshabilitados, insertamos subtotales directamente)
INSERT INTO productosporfactura (fknumfactura, fkcodproducto, cantidad, subtotal) VALUES
(1, N'PR001', 2, 5000000),
(2, N'PR002', 1, 800000),
(2, N'PR003', 3, 450000),
(3, N'PR004', 5, 450000),
(3, N'PR005', 1, 1100000),
(3, N'PR006', 2, 480000),
(4, N'PR007', 1, 950000),
(5, N'PR007', 2, 1900000),
(5, N'PR008', 3, 840000),
(6, N'PR001', 1, 2500000),
(6, N'PR002', 2, 1600000),
(6, N'PR003', 5, 750000);

-- Rehabilitar triggers
ENABLE TRIGGER trg_prodfact_insert ON productosporfactura;
ENABLE TRIGGER trg_prodfact_update ON productosporfactura;
ENABLE TRIGGER trg_prodfact_delete ON productosporfactura;
GO

-- Roles por usuario
INSERT INTO rol_usuario (fkemail, fkidrol) VALUES
(N'admin@correo.com', 1),
(N'vendedor1@correo.com', 2),
(N'vendedor1@correo.com', 3),
(N'jefe@correo.com', 1),
(N'jefe@correo.com', 3),
(N'jefe@correo.com', 4),
(N'cliente1@correo.com', 5),
(N'test_encript@correo.com', 1),
(N'nuevo@correo.com', 1),
(N'nuevo@correo.com', 2),
(N'nuevo@correo.com', 3),
(N'carlos.castro@usbmed.edu.co', 1),
(N'carlos.castro@usbmed.edu.co', 2),
(N'carlos.castro@usbmed.edu.co', 3),
(N'carlos.castro@usbmed.edu.co', 4),
(N'carlos.castro@usbmed.edu.co', 5),
(N'carloscastro5033@correo.itm.edu.co', 1),
(N'carloscastro5033@correo.itm.edu.co', 2),
(N'carloscastro5033@correo.itm.edu.co', 3),
(N'carloscastro5033@correo.itm.edu.co', 4),
(N'carloscastro5033@correo.itm.edu.co', 5);

-- Rutas por rol
-- Rutas por rol (fkidruta, fkidrol)
-- Rutas: 1=/home,2=/usuarios,3=/facturas,4=/clientes,5=/vendedores,6=/personas,7=/empresas,8=/productos,9=/roles,10=/permisos,11=/permisos/crear,12=/permisos/eliminar,13=/rutas,14=/rutas/crear,15=/rutas/eliminar
-- Roles: 1=Administrador,2=Vendedor,3=Cajero,4=Contador,5=Cliente
INSERT INTO rutarol (fkidruta, fkidrol) VALUES
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1), (8, 1), (9, 1), (10, 1), (11, 1), (12, 1), (13, 1), (14, 1), (15, 1),
(1, 2), (3, 2), (4, 2),
(1, 3), (3, 3),
(1, 4), (4, 4), (8, 4),
(1, 5), (8, 5);
GO
