-- Generado por Oracle SQL Developer Data Modeler 24.3.1.351.0831
--   en:        2025-10-06 17:54:09 CLST
--   sitio:      Oracle Database 21c
--   tipo:      Oracle Database 21c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE administrativo 
    ( 
     id_empleado NUMBER (4)  NOT NULL 
    ) 
;

ALTER TABLE administrativo 
    ADD CONSTRAINT administrativo_pk PRIMARY KEY ( id_empleado ) ;

CREATE TABLE afp 
    ( 
     id_afp  NUMBER (5)  NOT NULL , 
     nom_afp VARCHAR2 (255)  NOT NULL 
    ) 
;

ALTER TABLE afp 
    ADD CONSTRAINT afp_pk PRIMARY KEY ( id_afp ) ;

CREATE TABLE categoria 
    ( 
     id_categoria     NUMBER (3)  NOT NULL , 
     nombre_categoria VARCHAR2 (255)  NOT NULL 
    ) 
;

ALTER TABLE categoria 
    ADD CONSTRAINT categoria_pk PRIMARY KEY ( id_categoria ) ;

CREATE TABLE comuna 
    ( 
     id_comuna  NUMBER (4)  NOT NULL , 
     nom_comuna VARCHAR2 (100)  NOT NULL , 
     cod_region NUMBER (4)  NOT NULL 
    ) 
;

ALTER TABLE comuna 
    ADD CONSTRAINT comuna_pk PRIMARY KEY ( id_comuna ) ;

CREATE TABLE detalle_venta 
    ( 
     cod_venta    NUMBER (4)  NOT NULL , 
     cod_producto NUMBER (4)  NOT NULL , 
     cantidad     NUMBER (6)  NOT NULL 
    ) 
;

ALTER TABLE detalle_venta 
    ADD CONSTRAINT detalle_venta_pk PRIMARY KEY ( cod_venta, cod_producto ) ;

CREATE TABLE empleado 
    ( 
     id_empleado        NUMBER (4)  NOT NULL , 
     rut_empleado       VARCHAR2 (10)  NOT NULL , 
     nombre_empleado    VARCHAR2 (25)  NOT NULL , 
     apellido_paterno   VARCHAR2 (25)  NOT NULL , 
     apellido_materno   VARCHAR2 (25)  NOT NULL , 
     fecha_contratacion DATE  NOT NULL , 
     sueldo_base        NUMBER (10)  NOT NULL , 
     bono_jefatura      NUMBER (10) , 
     activo             CHAR (1)  NOT NULL , 
     tipo_empleado      VARCHAR2 (25)  NOT NULL , 
     cod_empleado       NUMBER (4) , 
     cod_salud          NUMBER (4)  NOT NULL , 
     cod_afp            NUMBER (5)  NOT NULL 
    ) 
;

ALTER TABLE empleado 
    ADD CONSTRAINT empleado_pk PRIMARY KEY ( id_empleado ) ;

CREATE TABLE marca 
    ( 
     id_marca     NUMBER (3)  NOT NULL , 
     nombre_marca VARCHAR2 (25)  NOT NULL 
    ) 
;

ALTER TABLE marca 
    ADD CONSTRAINT marca_pk PRIMARY KEY ( id_marca ) ;

CREATE TABLE medio_pago 
    ( 
     id_mpago     NUMBER (3)  NOT NULL , 
     nombre_mpago VARCHAR2 (50)  NOT NULL 
    ) 
;

ALTER TABLE medio_pago 
    ADD CONSTRAINT medio_pago_pk PRIMARY KEY ( id_mpago ) ;

CREATE TABLE producto 
    ( 
     id_producto     NUMBER (4)  NOT NULL , 
     nombre_producto VARCHAR2 (100)  NOT NULL , 
     precio_unitario NUMBER  NOT NULL , 
     origen_nacional CHAR (1)  NOT NULL , 
     stock_minimo    NUMBER (3)  NOT NULL , 
     activo          CHAR (1)  NOT NULL , 
     cod_marca       NUMBER (3)  NOT NULL , 
     cod_categoria   NUMBER (3)  NOT NULL , 
     cod_proveedor   NUMBER (5)  NOT NULL 
    ) 
;

ALTER TABLE producto 
    ADD CONSTRAINT producto_pk PRIMARY KEY ( id_producto ) ;

CREATE TABLE proveedor 
    ( 
     id_proveedor     NUMBER (5)  NOT NULL , 
     nombre_proveedor VARCHAR2 (150)  NOT NULL , 
     rut_proveedor    VARCHAR2 (10)  NOT NULL , 
     telefono         VARCHAR2 (10)  NOT NULL , 
     email            VARCHAR2 (200)  NOT NULL , 
     direccion        VARCHAR2 (200)  NOT NULL , 
     cod_comuna       NUMBER (4)  NOT NULL 
    ) 
;

ALTER TABLE proveedor 
    ADD CONSTRAINT proveedor_pk PRIMARY KEY ( id_proveedor ) ;

CREATE TABLE region 
    ( 
     id_region  NUMBER (4)  NOT NULL , 
     nom_region VARCHAR2 (255)  NOT NULL 
    ) 
;

ALTER TABLE region 
    ADD CONSTRAINT region_pk PRIMARY KEY ( id_region ) ;

CREATE TABLE salud 
    ( 
     id_salud  NUMBER (4)  NOT NULL , 
     nom_salud VARCHAR2 (40)  NOT NULL 
    ) 
;

ALTER TABLE salud 
    ADD CONSTRAINT salud_pk PRIMARY KEY ( id_salud ) ;

CREATE TABLE vendedor 
    ( 
     id_empleado    NUMBER (4)  NOT NULL , 
     comision_venta NUMBER (5,2)  NOT NULL 
    ) 
;

ALTER TABLE vendedor 
    ADD CONSTRAINT vendedor_pk PRIMARY KEY ( id_empleado ) ;

CREATE TABLE venta 
    ( 
     id_venta     NUMBER (4)  NOT NULL , 
     fecha_venta  DATE  NOT NULL , 
     total_venta  NUMBER (10)  NOT NULL , 
     cod_mpago    NUMBER (3)  NOT NULL , 
     cod_empleado NUMBER (4)  NOT NULL 
    ) 
;

ALTER TABLE venta 
    ADD CONSTRAINT venta_pk PRIMARY KEY ( id_venta ) ;

ALTER TABLE administrativo 
    ADD CONSTRAINT admin_fk_empleado FOREIGN KEY 
    ( 
     id_empleado
    ) 
    REFERENCES empleado 
    ( 
     id_empleado
    ) 
;

ALTER TABLE comuna 
    ADD CONSTRAINT comuna_fk_region FOREIGN KEY 
    ( 
     cod_region
    ) 
    REFERENCES region 
    ( 
     id_region
    ) 
;

ALTER TABLE detalle_venta 
    ADD CONSTRAINT det_venta_fk_producto FOREIGN KEY 
    ( 
     cod_producto
    ) 
    REFERENCES producto 
    ( 
     id_producto
    ) 
;

ALTER TABLE detalle_venta 
    ADD CONSTRAINT det_venta_fk_venta FOREIGN KEY 
    ( 
     cod_venta
    ) 
    REFERENCES venta 
    ( 
     id_venta
    ) 
;

ALTER TABLE empleado 
    ADD CONSTRAINT empleado_fk_afp FOREIGN KEY 
    ( 
     cod_afp
    ) 
    REFERENCES afp 
    ( 
     id_afp
    ) 
;

ALTER TABLE empleado 
    ADD CONSTRAINT empleado_fk_empleado FOREIGN KEY 
    ( 
     cod_empleado
    ) 
    REFERENCES empleado 
    ( 
     id_empleado
    ) 
;

ALTER TABLE empleado 
    ADD CONSTRAINT empleado_fk_salud FOREIGN KEY 
    ( 
     cod_salud
    ) 
    REFERENCES salud 
    ( 
     id_salud
    ) 
;

ALTER TABLE producto 
    ADD CONSTRAINT producto_fk_categoria FOREIGN KEY 
    ( 
     cod_categoria
    ) 
    REFERENCES categoria 
    ( 
     id_categoria
    ) 
;

ALTER TABLE producto 
    ADD CONSTRAINT producto_fk_marca FOREIGN KEY 
    ( 
     cod_marca
    ) 
    REFERENCES marca 
    ( 
     id_marca
    ) 
;

ALTER TABLE producto 
    ADD CONSTRAINT producto_fk_proveedor FOREIGN KEY 
    ( 
     cod_proveedor
    ) 
    REFERENCES proveedor 
    ( 
     id_proveedor
    ) 
;

ALTER TABLE proveedor 
    ADD CONSTRAINT proveedor_fk_comuna FOREIGN KEY 
    ( 
     cod_comuna
    ) 
    REFERENCES comuna 
    ( 
     id_comuna
    ) 
;

ALTER TABLE vendedor 
    ADD CONSTRAINT vendedor_fk_empleado FOREIGN KEY 
    ( 
     id_empleado
    ) 
    REFERENCES empleado 
    ( 
     id_empleado
    ) 
;

ALTER TABLE venta 
    ADD CONSTRAINT venta_fk_empleado FOREIGN KEY 
    ( 
     cod_empleado
    ) 
    REFERENCES empleado 
    ( 
     id_empleado
    ) 
;

ALTER TABLE venta 
    ADD CONSTRAINT venta_fk_medio_pago FOREIGN KEY 
    ( 
     cod_mpago
    ) 
    REFERENCES medio_pago 
    ( 
     id_mpago
    ) 
;

CREATE SEQUENCE afp_id_afp_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER afp_id_afp_TRG 
BEFORE INSERT ON afp 
FOR EACH ROW 
BEGIN 
    :NEW.id_afp := afp_id_afp_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE venta_id_venta_SEQ 
START WITH 1 
    NOCACHE ;

CREATE OR REPLACE TRIGGER venta_id_venta_TRG 
BEFORE INSERT ON venta 
FOR EACH ROW 
BEGIN 
    :NEW.id_venta := venta_id_venta_SEQ.NEXTVAL; 
END;
/



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            14
-- CREATE INDEX                             0
-- ALTER TABLE                             28
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           2
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          2
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
