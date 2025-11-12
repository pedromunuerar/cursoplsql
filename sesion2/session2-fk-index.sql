--Verificar si al crear un FK se crea el indice de la FK
-- Tabla PRINCIPAL: Departamentos
CREATE TABLE departamentos (
    departamento_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    presupuesto NUMBER(10,2),
    fecha_creacion DATE DEFAULT SYSDATE
);

-- Tabla SECUNDARIA: Empleados (relacionada con Departamentos)
CREATE TABLE empleados (
    empleado_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    apellido VARCHAR2(100) NOT NULL,
    email VARCHAR2(150) UNIQUE,
    salario NUMBER(8,2),
    fecha_contratacion DATE DEFAULT SYSDATE,
    departamento_id NUMBER NOT NULL,
    
    -- Definición de la FOREIGN KEY
    CONSTRAINT fk_empleado_departamento 
        FOREIGN KEY (departamento_id) 
        REFERENCES departamentos(departamento_id)
        ON DELETE CASCADE
);
