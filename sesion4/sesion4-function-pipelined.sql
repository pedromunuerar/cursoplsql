-- Versión sencilla
-- Crear tipo de tabla
CREATE OR REPLACE TYPE nombres_t AS TABLE OF VARCHAR2(100);
/

-- Función PIPELINED
CREATE OR REPLACE FUNCTION obtener_nombres
RETURN nombres_t PIPELINED IS
BEGIN
    PIPE ROW('Juan');
    PIPE ROW('Maria');
    PIPE ROW('Pedro');
    PIPE ROW('Ana');
    RETURN;
END;
/

-- Usar como tabla en SQL
SELECT * FROM TABLE(obtener_nombres());

-- Puedes usar todas las funciones de SQL
SELECT column_value nombre
FROM TABLE(obtener_nombres())
WHERE column_value LIKE 'M%';

---------------------------------------------------------------
---Ahora algo mas complicado

-- Tipo objeto para empleados
CREATE OR REPLACE TYPE empleado_obj AS OBJECT (
    id NUMBER,
    nombre VARCHAR2(100),
    salario NUMBER,
    departamento VARCHAR2(50)
);
/

-- Tipo tabla de empleados
CREATE OR REPLACE TYPE empleados_t AS TABLE OF empleado_obj;
/

-- Tabla de ejemplo
CREATE TABLE empleados_demo AS
SELECT 1 id, 'Carlos' nombre, 5000 salario, 'Ventas' depto FROM DUAL UNION ALL
SELECT 2, 'Laura', 6000, 'IT' FROM DUAL UNION ALL
SELECT 3, 'Miguel', 4500, 'Ventas' FROM DUAL UNION ALL
SELECT 4, 'Elena', 7000, 'IT' FROM DUAL;

CREATE OR REPLACE FUNCTION obtener_empleados_filtrados(
    p_departamento VARCHAR2 DEFAULT NULL,
    p_salario_min NUMBER DEFAULT 0
) RETURN empleados_t PIPELINED IS

    CURSOR c_empleados IS
        SELECT id, nombre, salario, depto
        FROM empleados_demo
        WHERE (p_departamento IS NULL OR depto = p_departamento)
          AND salario >= p_salario_min;

BEGIN
    FOR emp IN c_empleados LOOP
        -- Podemos agregar lógica adicional
        IF emp.salario > 6000 THEN
            PIPE ROW(empleado_obj(emp.id, emp.nombre || ' (Senior)', emp.salario, emp.depto));
        ELSE
            PIPE ROW(empleado_obj(emp.id, emp.nombre, emp.salario, emp.depto));
        END IF;
    END LOOP;
    
    RETURN;
END;
/

-- Todos los empleados
SELECT * FROM TABLE(obtener_empleados_filtrados());

-- Solo empleados de IT
SELECT * FROM TABLE(obtener_empleados_filtrados('IT'));

-- Empleados con salario >= 5500
SELECT * FROM TABLE(obtener_empleados_filtrados(p_salario_min => 5500));

-- Combinando filtros
SELECT * 
FROM TABLE(obtener_empleados_filtrados('IT', 5000))
WHERE salario > 6000;

-- Con JOIN con otras tablas
SELECT e.*, d.ubicacion
FROM TABLE(obtener_empleados_filtrados('Ventas')) e
CROSS JOIN (SELECT 'Madrid' ubicacion FROM DUAL) d;

-- Con funciones de agregación
SELECT 
    departamento,
    COUNT(*) as cantidad,
    AVG(salario) as salario_promedio
FROM TABLE(obtener_empleados_filtrados())
GROUP BY departamento;

