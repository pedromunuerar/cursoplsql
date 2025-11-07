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

/********************************************************/
--Recursivo

CREATE TABLE empleados (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    salario NUMBER(10,2),
    activo CHAR(1),
    jefe_id NUMBER REFERENCES empleados(id),
    departamento VARCHAR2(50),
    puesto VARCHAR2(50)
);

BEGIN
INSERT INTO empleados VALUES (1, 'Carlos Mendoza', 150000, 'S', NULL, 'Dirección', 'CEO');
-- Nivel 2: Directores (reportan al CEO)
INSERT INTO empleados VALUES (2, 'Ana López', 120000, 'S', 1, 'TI', 'Directora de TI');
INSERT INTO empleados VALUES (3, 'Pedro Ramírez', 110000, 'S', 1, 'Ventas', 'Director de Ventas');
INSERT INTO empleados VALUES (4, 'María García', 100000, 'S', 1, 'Finanzas', 'Directora Financiera');
-- Nivel 3: Gerentes (reportan a directores)
INSERT INTO empleados VALUES (5, 'Laura Torres', 90000, 'S', 2, 'TI', 'Gerente Desarrollo');
INSERT INTO empleados VALUES (6, 'Roberto Sánchez', 85000, 'S', 2, 'TI', 'Gerente Infraestructura');
INSERT INTO empleados VALUES (7, 'Sofía Chen', 80000, 'S', 3, 'Ventas', 'Gerente Ventas Nacional');
INSERT INTO empleados VALUES (8, 'Diego Morales', 75000, 'S', 4, 'Finanzas', 'Gerente Contabilidad');
-- Nivel 4: Team Leads y Senior (reportan a gerentes)
INSERT INTO empleados VALUES (9, 'Elena Ruiz', 70000, 'S', 5, 'TI', 'Líder Técnico');
INSERT INTO empleados VALUES (10, 'Javier Kim', 65000, 'S', 7, 'Ventas', 'Supervisor Ventas');
INSERT INTO empleados VALUES (11, 'Carmen Vega', 60000, 'S', 8, 'Finanzas', 'Contador Senior');
-- Nivel 5: Desarrollador (reporta a team lead)
INSERT INTO empleados VALUES (12, 'David Ortiz', 55000, 'S', 9, 'TI', 'Desarrollador');
END;

WITH rec_emps (id, nombre, jefe_id, nivel) AS (
  SELECT id, nombre, jefe_id, 1
  FROM empleados
  WHERE jefe_id IS NULL
  UNION ALL
  SELECT e.id, e.nombre, e.jefe_id, r.nivel + 1
  FROM empleados e
  JOIN rec_emps r ON e.jefe_id = r.id
)
SELECT * FROM rec_emps ORDER BY nivel;


---Añadimos unos cambios
WITH rec_emps (id, nombre, jefe_id, nivel, ruta) AS (
  SELECT id, nombre, jefe_id, 1, nombre
  FROM empleados
  WHERE jefe_id IS NULL
  UNION ALL
  SELECT e.id, e.nombre, e.jefe_id, r.nivel + 1, r.ruta || ' -> ' || e.nombre
  FROM empleados e
  JOIN rec_emps r ON e.jefe_id = r.id
)
SELECT 
    id,
    LPAD(' ', (nivel-1)*3) || nombre AS nombre_indentado,
    jefe_id,
    nivel,
    ruta
FROM rec_emps 
ORDER BY nivel, id;

/**Formas de explotarlo**/
--1. Jerarquía Completa 
WITH jerarquia_empleados (id, nombre, jefe_id, nivel, ruta) AS (
    -- Raíz: empleados sin jefe
    SELECT id, nombre, jefe_id, 1, nombre
    FROM empleados
    WHERE jefe_id IS NULL
    UNION ALL
    -- Parte recursiva: subordinados
    SELECT e.id, e.nombre, e.jefe_id, j.nivel + 1, 
           j.ruta || ' -> ' || e.nombre
    FROM empleados e
    JOIN jerarquia_empleados j ON e.jefe_id = j.id
)
SELECT 
    id,
    LPAD(' ', (nivel-1)*4) || nombre AS estructura,
    nivel,
    ruta
FROM jerarquia_empleados
ORDER BY nivel, id;

--2. Subordinados de un Jefe Específico
WITH subordinados_de (id, nombre, jefe_id, nivel) AS (
    SELECT id, nombre, jefe_id, 1
    FROM empleados
    WHERE id = 2  -- Ana López
    UNION ALL
    SELECT e.id, e.nombre, e.jefe_id, s.nivel + 1
    FROM empleados e
    JOIN subordinados_de s ON e.jefe_id = s.id
)
SELECT * FROM subordinados_de;

--3. Cadena de Mando
WITH cadena_mando (id, nombre, jefe_id, nivel) AS (
    SELECT id, nombre, jefe_id, 1
    FROM empleados
    WHERE id = 12  -- David Ortiz
    UNION ALL
    SELECT e.id, e.nombre, e.jefe_id, c.nivel + 1
    FROM empleados e
    JOIN cadena_mando c ON e.id = c.jefe_id
)
SELECT 
    nivel,
    nombre,
    CASE 
        WHEN nivel = 1 THEN 'Empleado'
        WHEN nivel = 2 THEN 'Jefe Directo'
        ELSE 'Superior Nivel ' || (nivel-2)
    END AS tipo
FROM cadena_mando
ORDER BY nivel DESC;

--4. Estadísticas por Nivel 
WITH jerarquia (id, nombre, jefe_id, nivel, salario) AS (
    SELECT id, nombre, jefe_id, 1, salario
    FROM empleados
    WHERE jefe_id IS NULL
    UNION ALL
    SELECT e.id, e.nombre, e.jefe_id, j.nivel + 1, e.salario
    FROM empleados e
    JOIN jerarquia j ON e.jefe_id = j.id
)
SELECT 
    nivel,
    COUNT(*) as cantidad_empleados,
    ROUND(AVG(salario), 2) as salario_promedio,
    SUM(salario) as total_salarios
FROM jerarquia
GROUP BY nivel
ORDER BY nivel;
