-- ######################################################################
-- SCRIPT FINAL DDL: IMPLEMENTACIÓN HOSPITAL (V2.0 - con ALTER TABLE)
-- Este script crea la base de datos completa para el sistema de recetas.
-- NOTA: Ejecutar de una sola vez para asegurar la secuencia de creación/modificación.
-- ######################################################################

-- ======================================================================
-- 1. LIMPIEZA INICIAL: Borrar tablas para evitar conflictos de FK/PK
-- Si es la primera ejecución, ignorar los errores ORA-00942 (tabla no existe).
-- ======================================================================

DROP TABLE PAGO CASCADE CONSTRAINTS;
DROP TABLE RECETA_MEDICAMENTO CASCADE CONSTRAINTS;
DROP TABLE RECETA CASCADE CONSTRAINTS;
DROP TABLE PACIENTE CASCADE CONSTRAINTS;
DROP TABLE MEDICO CASCADE CONSTRAINTS;
DROP TABLE DIGITADOR CASCADE CONSTRAINTS;
DROP TABLE ESPECIALIDAD CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE MEDICAMENTO CASCADE CONSTRAINTS;


-- ======================================================================
-- 2. CREACIÓN DE LA ESTRUCTURA DE TABLAS (DDL BASE)
-- ======================================================================

-- Tabla COMUNA: El catálogo base para direcciones
CREATE TABLE COMUNA (
    -- La PK es IDENTITY, y debe empezar en 1101 por requisito.
    id_com NUMBER
        GENERATED ALWAYS AS IDENTITY (START WITH 1101 INCREMENT BY 1)
        CONSTRAINT PK_COMUNA PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL
);

-- Tabla ESPECIALIDAD: El catálogo de las áreas médicas
CREATE TABLE ESPECIALIDAD (
    -- PK simple, autoincremental por defecto.
    id_esp NUMBER
        GENERATED ALWAYS AS IDENTITY
        CONSTRAINT PK_ESPECIALIDAD PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

-- Tabla DIGITADOR: El personal administrativo que registra las recetas
CREATE TABLE DIGITADOR (
    id_dig NUMBER CONSTRAINT PK_DIGITADOR PRIMARY KEY,
    rut NUMBER(10) NOT NULL UNIQUE,
    dv_dig CHAR(1) NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    apellido_pat VARCHAR2(50) NOT NULL,
    id_comuna NUMBER NOT NULL,
    -- Restricción para asegurar que el DV sea un número o 'K'.
    CONSTRAINT CK_DIGITADOR_DV CHECK (dv_dig IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'K')),
    CONSTRAINT FK_DIGITADOR_COMUNA FOREIGN KEY (id_comuna) REFERENCES COMUNA (id_com)
);

-- Tabla MÉDICO: El profesional que emite la receta
CREATE TABLE MEDICO (
    id_med NUMBER CONSTRAINT PK_MEDICO PRIMARY KEY,
    rut NUMBER(10) NOT NULL UNIQUE,
    dv_med CHAR(1) NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    apellido_pat VARCHAR2(50) NOT NULL,
    telefono NUMBER(9) NOT NULL,
    id_comuna NUMBER NOT NULL,
    id_especialidad NUMBER NOT NULL,
    -- Teléfono debe ser único para evitar duplicados en contacto.
    CONSTRAINT UN_MEDICO_TELEFONO UNIQUE (telefono),
    -- Restricción para el dígito verificador.
    CONSTRAINT CK_MEDICO_DV CHECK (dv_med IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'K')),
    CONSTRAINT FK_MEDICO_COMUNA FOREIGN KEY (id_comuna) REFERENCES COMUNA (id_com),
    CONSTRAINT FK_MEDICO_ESPECIALIDAD FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD (id_esp)
);

-- Tabla PACIENTE: La persona que recibe la atención
CREATE TABLE PACIENTE (
    id_pac NUMBER CONSTRAINT PK_PACIENTE PRIMARY KEY,
    rut NUMBER(10) NOT NULL UNIQUE,
    dv_pac CHAR(1) NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    apellido_pat VARCHAR2(50) NOT NULL,
    apellido_mat VARCHAR2(50),
    id_comuna NUMBER NOT NULL,
    -- Columna 'edad' temporal: será reemplazada por fecha_nacimiento en la fase de ALTER.
    edad NUMBER(3),
    -- Restricción para el dígito verificador.
    CONSTRAINT CK_PACIENTE_DV CHECK (dv_pac IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'K')),
    CONSTRAINT FK_PACIENTE_COMUNA FOREIGN KEY (id_comuna) REFERENCES COMUNA (id_com)
);

-- Tabla MEDICAMENTO: El producto que se receta
CREATE TABLE MEDICAMENTO (
    id_medc NUMBER CONSTRAINT PK_MEDICAMENTO PRIMARY KEY,
    -- El nombre del medicamento debe ser único.
    nombre VARCHAR2(100) NOT NULL UNIQUE,
    descripcion VARCHAR2(255)
);

-- Tabla RECETA: El documento principal del sistema
CREATE TABLE RECETA (
    id_rec NUMBER CONSTRAINT PK_RECETA PRIMARY KEY,
    fecha_emision DATE NOT NULL,
    id_paciente NUMBER NOT NULL,
    id_medico NUMBER NOT NULL,
    id_digitador NUMBER NOT NULL,
    CONSTRAINT FK_RECETA_PACIENTE FOREIGN KEY (id_paciente) REFERENCES PACIENTE (id_pac),
    CONSTRAINT FK_RECETA_MEDICO FOREIGN KEY (id_medico) REFERENCES MEDICO (id_med),
    CONSTRAINT FK_RECETA_DIGITADOR FOREIGN KEY (id_digitador) REFERENCES DIGITADOR (id_dig)
);

-- Tabla RECETA_MEDICAMENTO: La tabla de unión N:M (Detalle de la receta)
CREATE TABLE RECETA_MEDICAMENTO (
    id_receta NUMBER NOT NULL,
    id_medicamento NUMBER NOT NULL,
    cantidad NUMBER NOT NULL,
    -- La PK es compuesta (receta + medicamento) para asegurar unicidad.
    CONSTRAINT PK_RECETA_MEDICAMENTO PRIMARY KEY (id_receta, id_medicamento),
    CONSTRAINT FK_RM_RECETA FOREIGN KEY (id_receta) REFERENCES RECETA (id_rec),
    CONSTRAINT FK_RM_MEDICAMENTO FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTO (id_medc)
);

-- Tabla PAGO: Registro de la transacción asociada a la receta
CREATE TABLE PAGO (
    id_pago NUMBER CONSTRAINT PK_PAGO PRIMARY KEY,
    monto NUMBER(10) NOT NULL,
    fecha_pago DATE NOT NULL,
    metodo_pago VARCHAR2(20) NOT NULL,
    id_receta NUMBER NOT NULL,
    CONSTRAINT FK_PAGO_RECETA FOREIGN KEY (id_receta) REFERENCES RECETA (id_rec)
);


-- ======================================================================
-- 3. MODIFICACIONES ESTRUCTURALES (Requerimientos de ALTER TABLE)
-- ======================================================================

-- 3.1 Modificar MEDICAMENTO: Agregar precio y un rango válido.
ALTER TABLE MEDICAMENTO ADD (
    precio_unitario NUMBER NOT NULL
);
ALTER TABLE MEDICAMENTO ADD CONSTRAINT CK_MEDICAMENTO_PRECIO CHECK (
    precio_unitario BETWEEN 1000 AND 2000000 -- El precio debe ser un valor razonable.
);

-- 3.2 Modificar PAGO: Restringir los métodos de pago aceptados.
ALTER TABLE PAGO ADD CONSTRAINT CK_PAGO_METODO CHECK (
    metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA')
);

-- 3.3 Modificar PACIENTE: Reemplazar 'edad' por 'fecha_nacimiento' (Mejor práctica).
-- Primero, borramos la columna antigua.
ALTER TABLE PACIENTE DROP COLUMN edad;

-- Luego, agregamos la columna nueva, que es NOT NULL.
ALTER TABLE PACIENTE ADD (
    fecha_nacimiento DATE NOT NULL
);