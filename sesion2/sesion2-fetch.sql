CREATE TABLE empleados (
    empleado_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    salario NUMBER(10,2)
);

INSERT INTO empleados (empleado_id, nombre, salario)
SELECT 
    ROWNUM AS empleado_id,
    'Empleado ' || ROWNUM AS nombre,
    -- Salarios variados por departamento para hacer la consulta interesante
    CASE 
        WHEN MOD(LEVEL, 8) = 1 THEN ROUND(DBMS_RANDOM.VALUE(30000, 80000), 2)  -- Ventas
        WHEN MOD(LEVEL, 8) = 2 THEN ROUND(DBMS_RANDOM.VALUE(50000, 120000), 2) -- TI
        WHEN MOD(LEVEL, 8) = 3 THEN ROUND(DBMS_RANDOM.VALUE(40000, 90000), 2)  -- Finanzas
        WHEN MOD(LEVEL, 8) = 4 THEN ROUND(DBMS_RANDOM.VALUE(35000, 70000), 2)  -- RH
        WHEN MOD(LEVEL, 8) = 5 THEN ROUND(DBMS_RANDOM.VALUE(38000, 85000), 2)  -- Marketing
        ELSE ROUND(DBMS_RANDOM.VALUE(30000, 75000), 2)
    END AS salario
FROM dual
CONNECT BY LEVEL <= 5000000;


CREATE TABLE empleados (
    empleado_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    salario NUMBER(10,2)
);

INSERT INTO empleados (empleado_id, nombre, salario)
SELECT 
    ROWNUM AS empleado_id,
    'Empleado ' || ROWNUM AS nombre,
    -- Salarios variados por departamento para hacer la consulta interesante
    CASE 
        WHEN MOD(LEVEL, 8) = 1 THEN ROUND(DBMS_RANDOM.VALUE(30000, 80000), 2)  -- Ventas
        WHEN MOD(LEVEL, 8) = 2 THEN ROUND(DBMS_RANDOM.VALUE(50000, 120000), 2) -- TI
        WHEN MOD(LEVEL, 8) = 3 THEN ROUND(DBMS_RANDOM.VALUE(40000, 90000), 2)  -- Finanzas
        WHEN MOD(LEVEL, 8) = 4 THEN ROUND(DBMS_RANDOM.VALUE(35000, 70000), 2)  -- RH
        WHEN MOD(LEVEL, 8) = 5 THEN ROUND(DBMS_RANDOM.VALUE(38000, 85000), 2)  -- Marketing
        ELSE ROUND(DBMS_RANDOM.VALUE(30000, 75000), 2)
    END AS salario
FROM dual
CONNECT BY LEVEL <= 5000000;
/
WITH empleados_ordenados AS (
    SELECT *
    FROM empleados
    ORDER BY salario DESC
)
SELECT *
FROM empleados_ordenados
WHERE ROWNUM <= 10;

SELECT * FROM empleados
ORDER BY salario DESC
FETCH FIRST 10 ROWS ONLY;

SELECT * FROM empleados
ORDER BY salario DESC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;
