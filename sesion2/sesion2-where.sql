-- Tabla de departamentos
CREATE TABLE departamentos (
    departamento_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(50)
);


-- Tabla de empleados
CREATE TABLE empleados (
    empleado_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    salario NUMBER(10,2),
    departamento_id NUMBER,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(departamento_id)
);

INSERT INTO departamentos (departamento_id, nombre)
SELECT 
    LEVEL AS departamento_id,
    CASE LEVEL
        WHEN 1 THEN 'Ventas'
        WHEN 2 THEN 'TI'
        WHEN 3 THEN 'Finanzas'
        WHEN 4 THEN 'RH'
        WHEN 5 THEN 'Marketing'
        ELSE 'Departamento ' || LEVEL
    END AS nombre
FROM dual
CONNECT BY LEVEL <= 8;

-- Insertar empleados con datos sintéticos
INSERT INTO empleados (empleado_id, nombre, salario, departamento_id)
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
    END AS salario,
    MOD(LEVEL, 8) + 1 AS departamento_id
FROM dual
CONNECT BY LEVEL <= 5000000;


COMMIT;
/
select count(*) from empleados;
/
SELECT e.nombre, e.salario
FROM empleados e
WHERE salario > (
  SELECT AVG(s.salario)
  FROM empleados s
  WHERE s.departamento_id = e.departamento_id
)
and  e.departamento_id=1;  

with empleados_filtrado as (select EMPLEADO_ID,
NOMBRE,
SALARIO,
DEPARTAMENTO_ID from empleados where departamento_id=1)
SELECT e.nombre, e.salario
FROM empleados_filtrado e
WHERE salario > (
  SELECT AVG(s.salario)
  FROM empleados_filtrado s
  WHERE s.departamento_id = e.departamento_id
); --


WITH departamento_promedio AS (
    SELECT AVG(salario) as avg_salario
    FROM empleados 
    WHERE departamento_id = 1  --  Calcula el promedio UNA vez
)
SELECT   e.nombre, e.salario
FROM empleados e
 CROSS JOIN departamento_promedio dp
WHERE e.departamento_id = 1
AND e.salario > dp.avg_salario; --

---------------------------------------
/*Ahora a ver lo real*/

SELECT /*+ NO_REWRITE */  e.nombre, e.salario
FROM empleados e
WHERE salario > (
  SELECT /*+ NO_REWRITE */  AVG(s.salario)
  FROM empleados s
  WHERE s.departamento_id = e.departamento_id
)
and  e.departamento_id=1;
/
with empleados_filtrado as (select /*+ NO_REWRITE */  EMPLEADO_ID,
NOMBRE,
SALARIO,
DEPARTAMENTO_ID from empleados where departamento_id=1)
SELECT /*+ NO_REWRITE */ e.nombre, e.salario
FROM empleados_filtrado e
WHERE salario > (
  SELECT AVG(s.salario)
  FROM empleados_filtrado s
  WHERE s.departamento_id = e.departamento_id
);

/
WITH departamento_promedio AS (
    SELECT /*+ NO_REWRITE */ AVG(salario) as avg_salario
    FROM empleados 
    WHERE departamento_id = 1  --  Calcula el promedio UNA vez
)
SELECT /*+ NO_REWRITE */  e.nombre, e.salario
FROM empleados e
 CROSS JOIN departamento_promedio dp
WHERE e.departamento_id = 1
AND e.salario > dp.avg_salario;
