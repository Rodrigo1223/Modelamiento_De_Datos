
-- LIMPIEZA Y DROP DE OBJETOS EXISTENTES (DDL - SANITIZADO)

-- Se utiliza CASCADE CONSTRAINTS para asegurar la eliminación de tablas con dependencias.
DROP TABLE DETALLE_VENTA;
DROP TABLE VENTA;
DROP TABLE VENDEDOR;
DROP TABLE ADMINISTRATIVO;
DROP TABLE PRODUCTO;
DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE PROVEEDOR CASCADE CONSTRAINTS;
DROP TABLE MARCA CASCADE CONSTRAINTS;
DROP TABLE CATEGORIA CASCADE CONSTRAINTS;
DROP TABLE MEDIO_PAGO CASCADE CONSTRAINTS;
DROP TABLE SALUD CASCADE CONSTRAINTS;
DROP TABLE AFP CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE REGION CASCADE CONSTRAINTS;

-- Eliminar secuencias (Corregido: Manejo de errores PL/SQL con slash /)
-- Esto corrige ORA-06550/PLS-00103 y ORA-00955 en las secuencias.
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEC_ID_SALUD';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEC_ID_EMPLEADO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/



-- CREACIÓN DE TABLAS Y SECUENCIAS (DDL - Corregido ORA-00911)

-- Tablas base
CREATE TABLE REGION (
    id_region NUMBER(3) PRIMARY KEY,
    nom_region VARCHAR2(100) NOT NULL
);

CREATE TABLE COMUNA (
    id_comuna NUMBER(5) PRIMARY KEY,
    nom_comuna VARCHAR2(100) NOT NULL,
    cod_region NUMBER(3) NOT NULL,
    CONSTRAINT fk_comuna_region FOREIGN KEY (cod_region) REFERENCES REGION (id_region)
);

-- AFP: usa IDENTITY (inicia en 210, incrementa en 6)
CREATE TABLE AFP (
    id_afp NUMBER(5) GENERATED ALWAYS AS IDENTITY
        START WITH 210
        MINVALUE 210
        INCREMENT BY 6
    NOT NULL PRIMARY KEY,
    nom_afp VARCHAR2(50) NOT NULL
);

-- SALUD: usa SEQUENCE (inicia en 2050, incrementa en 10)
CREATE SEQUENCE SEC_ID_SALUD START WITH 2050 INCREMENT BY 10 MINVALUE 2050;
CREATE TABLE SALUD (
    id_salud NUMBER(5) PRIMARY KEY,
    nom_salud VARCHAR2(50) NOT NULL
);

CREATE TABLE MEDIO_PAGO (
    id_mpago NUMBER(2) PRIMARY KEY,
    nom_mpago VARCHAR2(50) NOT NULL
);

CREATE TABLE CATEGORIA (
    id_categoria NUMBER(5) PRIMARY KEY,
    nom_categoria VARCHAR2(50) NOT NULL
);

CREATE TABLE MARCA (
    id_marca NUMBER(5) PRIMARY KEY,
    nom_marca VARCHAR2(50) NOT NULL
);

CREATE TABLE PROVEEDOR (
    id_proveedor NUMBER(5) PRIMARY KEY,
    nombre_proveedor VARCHAR2(100) NOT NULL,
    email_proveedor VARCHAR2(100)
);

-- EMPLEADO: usa SEQUENCE (inicia en 750, incrementa en 3)
CREATE SEQUENCE SEC_ID_EMPLEADO START WITH 750 INCREMENT BY 3 MINVALUE 750;
CREATE TABLE EMPLEADO (
    id_empleado NUMBER(5) PRIMARY KEY,
    rut_empleado VARCHAR2(12) UNIQUE NOT NULL,
    nombre_empleado VARCHAR2(50) NOT NULL,
    apellido_paterno VARCHAR2(50) NOT NULL,
    apellido_materno VARCHAR2(50) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    sueldo_base NUMBER(10) NOT NULL,
    bono_jefatura NUMBER(10),
    activo CHAR(1) NOT NULL,
    tipo_empleado VARCHAR2(20) NOT NULL,
    cod_empleado NUMBER(5), -- JEFE (FK a sí mismo)
    cod_salud NUMBER(5) NOT NULL,
    cod_afp NUMBER(5) NOT NULL,
    CONSTRAINT fk_empleado_jefe FOREIGN KEY (cod_empleado) REFERENCES EMPLEADO (id_empleado),
    CONSTRAINT fk_empleado_salud FOREIGN KEY (cod_salud) REFERENCES SALUD (id_salud),
    CONSTRAINT fk_empleado_afp FOREIGN KEY (cod_afp) REFERENCES AFP (id_afp)
);

CREATE TABLE ADMINISTRATIVO (
    id_empleado NUMBER(5) PRIMARY KEY,
    CONSTRAINT fk_admin_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado)
);

CREATE TABLE VENDEDOR (
    id_empleado NUMBER(5) PRIMARY KEY,
    comision_venta NUMBER(3, 2) NOT NULL,
    CONSTRAINT fk_vendedor_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado)
);

CREATE TABLE PRODUCTO (
    id_producto NUMBER(5) PRIMARY KEY,
    nom_producto VARCHAR2(100) NOT NULL,
    precio_producto NUMBER(10) NOT NULL,
    stock_actual NUMBER(5) NOT NULL,
    stock_minimo NUMBER(5) NOT NULL,
    cod_categoria NUMBER(5) NOT NULL,
    cod_marca NUMBER(5) NOT NULL,
    cod_proveedor NUMBER(5) NOT NULL,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (cod_categoria) REFERENCES CATEGORIA (id_categoria),
    CONSTRAINT fk_producto_marca FOREIGN KEY (cod_marca) REFERENCES MARCA (id_marca),
    CONSTRAINT fk_producto_proveedor FOREIGN KEY (cod_proveedor) REFERENCES PROVEEDOR (id_proveedor)
);

CREATE TABLE VENTA (
    id_venta NUMBER(5) GENERATED ALWAYS AS IDENTITY
        START WITH 5050
        MINVALUE 5050
        INCREMENT BY 3
    NOT NULL PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    total_venta NUMBER(10) NOT NULL,
    cod_mpago NUMBER(2) NOT NULL,
    cod_empleado NUMBER(5) NOT NULL,
    CONSTRAINT fk_venta_mpago FOREIGN KEY (cod_mpago) REFERENCES MEDIO_PAGO (id_mpago),
    CONSTRAINT fk_venta_empleado FOREIGN KEY (cod_empleado) REFERENCES VENDEDOR (id_empleado)
);

CREATE TABLE DETALLE_VENTA (
    id_venta NUMBER(5) NOT NULL,
    id_producto NUMBER(5) NOT NULL,
    cantidad NUMBER(5) NOT NULL,
    precio_unitario NUMBER(10) NOT NULL,
    PRIMARY KEY (id_venta, id_producto),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta) REFERENCES VENTA (id_venta),
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) REFERENCES PRODUCTO (id_producto)
);



-- RESTRICCIONES ADICIONALES (DDL - CHECK y UNIQUE)

-- 1. CHECK en EMPLEADO: Sueldo base no inferior a $400.000
ALTER TABLE EMPLEADO
    ADD CONSTRAINT CK_EMPLEADO_SUELDO
    CHECK (sueldo_base >= 400000);

-- 2. CHECK en VENDEDOR: Comisión entre 0 y 0.25
ALTER TABLE VENDEDOR
    ADD CONSTRAINT CK_VENDEDOR_COMISION
    CHECK (comision_venta BETWEEN 0 AND 0.25);

-- 3. CHECK en PRODUCTO: Stock mínimo >= 3 unidades
ALTER TABLE PRODUCTO
    ADD CONSTRAINT CK_PRODUCTO_STOCK_MIN
    CHECK (stock_minimo >= 3);

-- 4. UNIQUE en PROVEEDOR: Correo Electrónico único
ALTER TABLE PROVEEDOR
    ADD CONSTRAINT UN_PROVEEDOR_EMAIL
    UNIQUE (email_proveedor);

-- 5. UNIQUE en MARCA: Nombre de marca único
ALTER TABLE MARCA
    ADD CONSTRAINT UN_MARCA_NOMBRE
    UNIQUE (nom_marca);

-- 6. CHECK en DETALLE_VENTA: Cantidad de productos > 0
ALTER TABLE DETALLE_VENTA
    ADD CONSTRAINT CK_DETALLE_CANTIDAD
    CHECK (cantidad > 0);



-- POBLAMIENTO DE DATOS (DML - Corregido ORA-00942)


-- REGION
INSERT INTO REGION (id_region, nom_region) VALUES (1, 'Región Metropolitana');
INSERT INTO REGION (id_region, nom_region) VALUES (2, 'Valparaíso');
INSERT INTO REGION (id_region, nom_region) VALUES (3, 'Biobío');
INSERT INTO REGION (id_region, nom_region) VALUES (4, 'Los Lagos');

-- COMUNA (Se necesita poblar para la integridad referencial, se añade aquí)
INSERT INTO COMUNA (id_comuna, nom_comuna, cod_region) VALUES (101, 'Santiago', 1);
INSERT INTO COMUNA (id_comuna, nom_comuna, cod_region) VALUES (102, 'Providencia', 1);
INSERT INTO COMUNA (id_comuna, nom_comuna, cod_region) VALUES (201, 'Valparaíso', 2);
INSERT INTO COMUNA (id_comuna, nom_comuna, cod_region) VALUES (301, 'Concepción', 3);

-- SALUD (usa SEQUENCE SEC_ID_SALUD)
INSERT INTO SALUD (id_salud, nom_salud) VALUES (SEC_ID_SALUD.NEXTVAL, 'Fonasa'); -- ID 2050
INSERT INTO SALUD (id_salud, nom_salud) VALUES (SEC_ID_SALUD.NEXTVAL, 'Isapre Colmena'); -- ID 2060
INSERT INTO SALUD (id_salud, nom_salud) VALUES (SEC_ID_SALUD.NEXTVAL, 'Isapre Banmédica'); -- ID 2070
INSERT INTO SALUD (id_salud, nom_salud) VALUES (SEC_ID_SALUD.NEXTVAL, 'Isapre Cruz Blanca'); -- ID 2080

-- AFP (usa IDENTITY)
INSERT INTO AFP (nom_afp) VALUES ('Habitat'); -- ID 210
INSERT INTO AFP (nom_afp) VALUES ('Provida'); -- ID 216
INSERT INTO AFP (nom_afp) VALUES ('Capital'); -- ID 222
INSERT INTO AFP (nom_afp) VALUES ('PlanVital'); -- ID 228

-- MEDIO_PAGO
INSERT INTO MEDIO_PAGO (id_mpago, nom_mpago) VALUES (11, 'Efectivo');
INSERT INTO MEDIO_PAGO (id_mpago, nom_mpago) VALUES (12, 'Tarjeta Débito');
INSERT INTO MEDIO_PAGO (id_mpago, nom_mpago) VALUES (13, 'Tarjeta Crédito');
INSERT INTO MEDIO_PAGO (id_mpago, nom_mpago) VALUES (14, 'Cheque');

-- CATEGORIA
INSERT INTO CATEGORIA (id_categoria, nom_categoria) VALUES (10, 'Lácteos');
INSERT INTO CATEGORIA (id_categoria, nom_categoria) VALUES (20, 'Abarrotes');
INSERT INTO CATEGORIA (id_categoria, nom_categoria) VALUES (30, 'Bebidas');

-- MARCA
INSERT INTO MARCA (id_marca, nom_marca) VALUES (100, 'Nestlé');
INSERT INTO MARCA (id_marca, nom_marca) VALUES (200, 'CCU');
INSERT INTO MARCA (id_marca, nom_marca) VALUES (300, 'PF');

-- PROVEEDOR
INSERT INTO PROVEEDOR (id_proveedor, nombre_proveedor, email_proveedor) VALUES (501, 'Distribuidora A', 'contacto@dista.cl');
INSERT INTO PROVEEDOR (id_proveedor, nombre_proveedor, email_proveedor) VALUES (502, 'Logística B', 'ventas@logib.cl');
INSERT INTO PROVEEDOR (id_proveedor, nombre_proveedor, email_proveedor) VALUES (503, 'Mayorista C', 'info@mayorc.cl');

-- EMPLEADO (usa SEQUENCE SEC_ID_EMPLEADO)
INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '75811111-1', 'Marcela', 'González', 'Pérez', DATE '2022-03-15', 950000, 80000, 'S', 'Administrativo', NULL, 2050, 210); -- ID 750

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '75322222-2', 'José', 'Muñoz', 'Ramírez', DATE '2021-07-18', 900000, 75000, 'S', 'Administrativo', NULL, 2060, 216); -- ID 753

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '75633333-3', 'Verónica', 'Soto', 'Alarcón', DATE '2020-01-05', 880000, 70000, 'S', 'Vendedor', 750, 2060, 228); -- ID 756

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '75944444-4', 'Luis', 'Reyes', 'Fuentes', DATE '2023-04-01', 560000, NULL, 'S', 'Vendedor', 750, 2070, 228); -- ID 759

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '76255555-5', 'Claudia', 'Fernández', 'Lagos', DATE '2023-04-15', 600000, NULL, 'S', 'Vendedor', 753, 2070, 216); -- ID 762

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '76566666-6', 'Carlos', 'Navarro', 'Vega', DATE '2023-05-01', 610000, NULL, 'S', 'Administrativo', 753, 2060, 210); -- ID 765

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '76877777-7', 'Javiera', 'Pino', 'Rojas', DATE '2023-05-10', 650000, NULL, 'S', 'Administrativo', 750, 2050, 210); -- ID 768

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '77188888-8', 'Diego', 'Mella', 'Contreras', DATE '2023-05-12', 620000, NULL, 'S', 'Vendedor', 750, 2050, 210); -- ID 771

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '77499999-9', 'Fernanda', 'Salas', 'Herrera', DATE '2023-05-18', 570000, NULL, 'S', 'Vendedor', 753, 2070, 228); -- ID 774

INSERT INTO EMPLEADO (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, cod_empleado, cod_salud, cod_afp)
VALUES (SEC_ID_EMPLEADO.NEXTVAL, '77710101-0', 'Tomás', 'Vidal', 'Espinoza', DATE '2023-06-01', 530000, NULL, 'S', 'Vendedor', NULL, 2050, 222); -- ID 777

-- VENDEDOR
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (756, 0.10);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (759, 0.10);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (762, 0.10);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (771, 0.10);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (774, 0.10);
INSERT INTO VENDEDOR (id_empleado, comision_venta) VALUES (777, 0.10);

-- ADMINISTRATIVO
INSERT INTO ADMINISTRATIVO (id_empleado) VALUES (750);
INSERT INTO ADMINISTRATIVO (id_empleado) VALUES (753);
INSERT INTO ADMINISTRATIVO (id_empleado) VALUES (765);
INSERT INTO ADMINISTRATIVO (id_empleado) VALUES (768);

-- PRODUCTO
INSERT INTO PRODUCTO (id_producto, nom_producto, precio_producto, stock_actual, stock_minimo, cod_categoria, cod_marca, cod_proveedor)
VALUES (1010, 'Leche Entera 1Lt', 1290, 50, 10, 10, 100, 501);
INSERT INTO PRODUCTO (id_producto, nom_producto, precio_producto, stock_actual, stock_minimo, cod_categoria, cod_marca, cod_proveedor)
VALUES (1020, 'Fideos Espirales 400g', 850, 120, 15, 20, 300, 502);
INSERT INTO PRODUCTO (id_producto, nom_producto, precio_producto, stock_actual, stock_minimo, cod_categoria, cod_marca, cod_proveedor)
VALUES (1030, 'Bebida Cola 3Lt', 2490, 80, 20, 30, 200, 503);

-- VENTA (usa IDENTITY)
INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado)
VALUES (DATE '2023-05-12', 22590, 12, 771); -- ID VENTA 5050

INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado)
VALUES (DATE '2023-10-23', 52490, 13, 777); -- ID VENTA 5053

INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado)
VALUES (DATE '2023-02-17', 46690, 11, 759); -- ID VENTA 5056

-- DETALLE_VENTA
INSERT INTO DETALLE_VENTA (id_venta, id_producto, cantidad, precio_unitario)
VALUES (5050, 1010, 10, 1290);
INSERT INTO DETALLE_VENTA (id_venta, id_producto, cantidad, precio_unitario)
VALUES (5050, 1030, 5, 2490);
INSERT INTO DETALLE_VENTA (id_venta, id_producto, cantidad, precio_unitario)
VALUES (5053, 1020, 25, 850);
INSERT INTO DETALLE_VENTA (id_venta, id_producto, cantidad, precio_unitario)
VALUES (5056, 1010, 10, 1290);



--INFORMES (DQL - Consultas SELECT)


-- INFORME 1: Simulación de Sueldo con Bono de Jefatura
SELECT
    id_empleado AS "IDENTIFICADOR",
    nombre_empleado || ' ' || apellido_paterno || ' ' || apellido_materno AS "NOMBRE COMPLETO",
    sueldo_base AS "SALARIO",
    bono_jefatura AS "BONIFICACION",
    sueldo_base + bono_jefatura AS "SALARIO SIMULADO"
FROM
    EMPLEADO
WHERE
    activo = 'S'
    AND bono_jefatura IS NOT NULL
ORDER BY
    "SALARIO SIMULADO" DESC, apellido_paterno DESC;

-- INFORME 2: Simulación de Aumento de Sueldo del 8%
SELECT
    nombre_empleado || ' ' || apellido_paterno || ' ' || apellido_materno AS "EMPLEADO",
    sueldo_base AS "SUELDO",
    sueldo_base * 0.08 AS "POSIBLE AUMENTO",
    sueldo_base * 1.08 AS "SALARIO SIMULADO"
FROM
    EMPLEADO
WHERE
    sueldo_base BETWEEN 550000 AND 800000
ORDER BY
    sueldo_base ASC;