# Actividad Formativa: Poblamiento y Consultas en Base de Datos (PRY2204 - Semana 7)

## 📄 Descripción del Proyecto

Este repositorio contiene la solución completa para la actividad formativa "Realizando el poblamiento y consultas en la base de datos con sentencias SQL" de la asignatura **Modelamiento de Bases de Datos (PRY2204)**.

El script implementa el modelo relacional propuesto, incluyendo la definición de la estructura (DDL), la aplicación de restricciones de negocio (ALTER TABLE), el poblamiento de datos (DML INSERT) y la generación de reportes específicos (DML SELECT).

---

## 🛠️ Estructura del Script (`PRY2204_Script_Completo.sql`)

El script está diseñado para ejecutarse secuencialmente en un entorno **Oracle Database** (utilizando SQL Developer) y consta de las siguientes secciones:

### 0. Limpieza de Entorno
Bloque **PL/SQL** que elimina todas las tablas y secuencias del modelo (`DROP TABLE` / `DROP SEQUENCE`) para garantizar una ejecución limpia y repetible sin errores de objetos preexistentes.

### 1. Definición de Estructura (DDL)
- **Creación de Secuencias:** Se definen `SQ_COMUNA_ID` (Inicio 1101, Incremento 6) y `SQ_COMPANIA_ID` (Inicio 10, Incremento 5).
- **Creación de Tablas:** Implementación de las 10 tablas del modelo relacional.
    - Las tablas `REGION` e `IDIOMA` utilizan columnas `IDENTITY`.
    - Las tablas `COMUNA` y `PERSONAL` implementan claves foráneas compuestas.
    - Se definen todas las claves primarias (PK) y foráneas (FK) necesarias para la integridad referencial.

### 2. Modificación de Estructura (ALTER TABLE)
Implementación de las tres restricciones de negocio en la tabla `PERSONAL`:
1.  **Email único** (aunque opcional): `UNIQUE (EMAIL)`.
2.  **Validación del Dígito Verificador (DV):** `CHECK` que asegura que el DV sea ('0'-'9', 'K').
3.  **Sueldo Mínimo:** `CHECK` que valida que el sueldo sea igual o superior a $450.000.

### 3. Poblamiento de Datos (DML INSERT)
- Inserción de datos de prueba en las tablas `REGION`, `IDIOMA`, `COMUNA` y `COMPANIA`, utilizando las secuencias e `IDENTITY` creadas, manteniendo la integridad referencial.
- Uso de `COMMIT` para guardar los cambios.

### 4. Consultas y Reportes de Negocio (DML SELECT)

Se incluyen las sentencias `SELECT` para generar los dos informes solicitados.

#### **INFORME 1: Simulación de Renta Promedio**
Muestra la dirección, la renta promedio actual y una **Simulación de Renta** aplicando el `PCT_AUMENTO`.

#### **INFORME 2: Nueva Simulación Renta Promedio (Añadir 15% adicional)**
Muestra la renta promedio actual, el nuevo porcentaje de aumento (`PCT_AUMENTO + 0.15`) y la **Renta Aumentada** resultante.

---

## 🚀 Cómo Ejecutar el Script

1.  **Requisito:** Tener acceso a una base de datos **Oracle** (local o Cloud) y **SQL Developer**.
2.  **Conexión:** Conéctese al usuario `PRY2204_S7` (o el usuario de trabajo definido para la actividad).
3.  **Ejecución:** Abra el archivo `PRY2204_Script_Completo.sql` en SQL Developer y ejecute todo el script.

El resultado final debe mostrar los dos reportes de negocio generados por las sentencias `SELECT`.