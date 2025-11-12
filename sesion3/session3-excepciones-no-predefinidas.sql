-- Crear tabla para probar excepciones no predefinidas
CREATE TABLE departamentos (
    departamento_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(50)
);

CREATE TABLE empleados (
    empleado_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(50),
    departamento_id NUMBER,
    CONSTRAINT fk_depto FOREIGN KEY (departamento_id) 
    REFERENCES departamentos(departamento_id)
);

-- Insertar datos
INSERT INTO departamentos VALUES (1, 'Ventas');
INSERT INTO empleados VALUES (100, 'Juan Pérez', 1);

COMMIT;

-- Bloque para probar excepciones no predefinidas
DECLARE
    e_fk_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_fk_violation, -2291);
BEGIN
    -- Intentar insertar empleado con departamento que no existe
    INSERT INTO empleados VALUES (101, 'María García', 999);
    
EXCEPTION
    WHEN e_fk_violation THEN
        DBMS_OUTPUT.PUT_LINE('Error FK: Departamento no existe');
        DBMS_OUTPUT.PUT_LINE('Código: ' || SQLCODE || ' - ' || SQLERRM);
END;
