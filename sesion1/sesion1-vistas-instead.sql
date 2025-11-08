-- =============================================
-- EJERCICIO: VISTA ACTUALIZABLE CON TRIGGER
-- =============================================

-- Paso 1: Crear tablas base
CREATE TABLE departamentos (
    dept_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    presupuesto NUMBER(10,2)
);

CREATE TABLE empleados (
    emp_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    salario NUMBER(10,2),
    dept_id NUMBER REFERENCES departamentos(dept_id)
);

-- Paso 2: Insertar datos de ejemplo
INSERT INTO departamentos VALUES (10, 'VENTAS', 500000);
INSERT INTO departamentos VALUES (20, 'TI', 800000);
INSERT INTO departamentos VALUES (30, 'FINANZAS', 400000);

INSERT INTO empleados VALUES (1001, 'Ana García', 50000, 10);
INSERT INTO empleados VALUES (1002, 'Carlos López', 60000, 20);
INSERT INTO empleados VALUES (1003, 'María Rodríguez', 55000, 30);

COMMIT;

-- Paso 3: Ver datos insertados
SELECT * FROM departamentos;
SELECT * FROM empleados;

-- Paso 4: Crear vista compleja (NO actualizable por defecto)
CREATE VIEW v_empleados_detalle AS
SELECT 
    e.emp_id,
    e.nombre as empleado,
    e.salario,
    d.dept_id,
    d.nombre as departamento,
    d.presupuesto
FROM empleados e
JOIN departamentos d ON e.dept_id = d.dept_id;

-- Paso 5: Verificar que la vista NO es actualizable
SELECT column_name, updatable, insertable, deletable
FROM user_updatable_columns
WHERE table_name = 'V_EMPLEADOS_DETALLE';

-- Paso 6: Intentar INSERT sin trigger (debe fallar)
--  ESTO FALLARÁ:
INSERT INTO v_empleados_detalle (emp_id, empleado, salario, dept_id, departamento, presupuesto)
VALUES (1004, 'Pedro Martinez', 48000, 10, 'VENTAS', 500000);

-- Paso 7: Crear INSTEAD OF TRIGGER para hacer la vista actualizable
CREATE OR REPLACE TRIGGER tr_v_emp_detalle_insert
INSTEAD OF INSERT ON v_empleados_detalle
FOR EACH ROW
DECLARE
    v_dept_id NUMBER;
BEGIN
    -- Verificar si el departamento existe
    BEGIN
        SELECT dept_id INTO v_dept_id 
        FROM departamentos 
        WHERE dept_id = :NEW.dept_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Departamento no existe: ' || :NEW.dept_id);
    END;
    
    -- Insertar en la tabla empleados
    INSERT INTO empleados (emp_id, nombre, salario, dept_id)
    VALUES (:NEW.emp_id, :NEW.empleado, :NEW.salario, :NEW.dept_id);
    
    DBMS_OUTPUT.PUT_LINE('Empleado insertado correctamente: ' || :NEW.empleado);
END;
/

-- Paso 8: Habilitar salida para ver mensajes
SET SERVEROUTPUT ON;

-- Paso 9:  PROBAR INSERT (ahora debe funcionar)
INSERT INTO v_empleados_detalle (emp_id, empleado, salario, dept_id, departamento, presupuesto)
VALUES (1004, 'Pedro Martinez', 48000, 10, 'VENTAS', 500000);

COMMIT;

-- Paso 10: Verificar que el empleado se insertó
SELECT * FROM v_empleados_detalle;
SELECT * FROM empleados;

-- Paso 11: Crear trigger para UPDATE
CREATE OR REPLACE TRIGGER tr_v_emp_detalle_update
INSTEAD OF UPDATE ON v_empleados_detalle
FOR EACH ROW
BEGIN
    -- Actualizar empleado
    UPDATE empleados 
    SET nombre = :NEW.empleado,
        salario = :NEW.salario,
        dept_id = :NEW.dept_id
    WHERE emp_id = :OLD.emp_id;
    
    DBMS_OUTPUT.PUT_LINE('Empleado actualizado: ' || :OLD.empleado || ' -> ' || :NEW.empleado);
END;
/

-- Paso 12: PROBAR UPDATE
UPDATE v_empleados_detalle 
SET salario = 52000, empleado = 'Pedro Martínez' 
WHERE emp_id = 1004;

COMMIT;

-- Paso 13: Verificar cambios
SELECT * FROM v_empleados_detalle WHERE emp_id = 1004;

-- Paso 14: Crear trigger para DELETE
CREATE OR REPLACE TRIGGER tr_v_emp_detalle_delete
INSTEAD OF DELETE ON v_empleados_detalle
FOR EACH ROW
BEGIN
    DELETE FROM empleados WHERE emp_id = :OLD.emp_id;
    DBMS_OUTPUT.PUT_LINE('Empleado eliminado: ' || :OLD.empleado);
END;
/

-- Paso 15: PROBAR DELETE
DELETE FROM v_empleados_detalle WHERE emp_id = 1004;

COMMIT;

-- Paso 16: Verificar eliminación
SELECT * FROM v_empleados_detalle WHERE emp_id = 1004;
SELECT * FROM empleados WHERE emp_id = 1004;


-- =============================================
-- LIMPIAR (opcional)
-- =============================================
/*
-- Descomentar estas líneas si quieres eliminar todo:

DROP TRIGGER tr_v_emp_detalle_insert;
DROP TRIGGER tr_v_emp_detalle_update;
DROP TRIGGER tr_v_emp_detalle_delete;
DROP VIEW v_empleados_detalle;
DROP TABLE empleados CASCADE CONSTRAINTS;
DROP TABLE departamentos CASCADE CONSTRAINTS;
*/
