ALTER SESSION SET "_optimizer_squ_bottomup" = FALSE;
ALTER SESSION SET "_optimizer_cost_based_transformation" = OFF;
ALTER SESSION SET QUERY_REWRITE_ENABLED = FALSE;

DROP TABLE empleados;

CREATE TABLE empleados (
    empleado_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    salario NUMBER(10,2),
    activo char(1)
);

INSERT INTO empleados (empleado_id, nombre, salario, activo)
SELECT 
    ROWNUM AS empleado_id,
    'Empleado ' || ROWNUM AS nombre,
    -- Salarios variados por departamento para hacer la consulta interesante
    CASE 
        WHEN MOD(ROWNUM, 8) = 1 THEN ROUND(DBMS_RANDOM.VALUE(30000, 80000), 2)  -- Ventas
        WHEN MOD(ROWNUM, 8) = 2 THEN ROUND(DBMS_RANDOM.VALUE(50000, 120000), 2) -- TI
        WHEN MOD(ROWNUM, 8) = 3 THEN ROUND(DBMS_RANDOM.VALUE(40000, 90000), 2)  -- Finanzas
        WHEN MOD(ROWNUM, 8) = 4 THEN ROUND(DBMS_RANDOM.VALUE(35000, 70000), 2)  -- RH
        WHEN MOD(ROWNUM, 8) = 5 THEN ROUND(DBMS_RANDOM.VALUE(38000, 85000), 2)  -- Marketing
        ELSE ROUND(DBMS_RANDOM.VALUE(30000, 75000), 2)
    END AS salario,
    -- Columna 'activo' - alternando entre 'S' y 'N'
    CASE WHEN MOD(ROWNUM, 3) = 0 THEN 'N' ELSE 'S' END AS activo
FROM dual
CONNECT BY LEVEL <= 5000000; 
/
WITH empleados_ordenados AS (
    SELECT *
    FROM empleados
    ORDER BY salario DESC
)
/

WITH empleados_activos AS (
  SELECT * FROM empleados WHERE activo = 'S'
)
SELECT nombre, salario
FROM empleados_activos
WHERE salario > 4000;
