CREATE TABLE departamentos (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    presupuesto NUMBER(10,2)
);

CREATE TABLE empleados (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    salario NUMBER(10,2),
    departamento_id NUMBER REFERENCES departamentos(id),
    puesto VARCHAR2(50)
);

-- Paso 2: Insertar datos de ejemplo
-- Departamentos
INSERT INTO departamentos VALUES (1, 'VENTAS', 500000);
INSERT INTO departamentos VALUES (2, 'TI', 800000);
INSERT INTO departamentos VALUES (3, 'FINANZAS', 400000);
INSERT INTO departamentos VALUES (4, 'RECURSOS HUMANOS', 300000);

-- Empleados
INSERT INTO empleados VALUES (101, 'Ana García', 50000, 1, 'Vendedor');
INSERT INTO empleados VALUES (102, 'Carlos López', 60000, 2, 'Desarrollador');
INSERT INTO empleados VALUES (103, 'María Rodríguez', 55000, 3, 'Contador');
INSERT INTO empleados VALUES (104, 'Pedro Martínez', 48000, 1, 'Vendedor');
INSERT INTO empleados VALUES (105, 'Laura Sánchez', 70000, 2, 'Arquitecto');
INSERT INTO empleados VALUES (106, 'Diego Morales', 52000, 3, 'Analista');
-- Empleado sin departamento (no aparecerá en INNER JOIN)
INSERT INTO empleados VALUES (107, 'Sofia Chen', 45000, NULL, 'Practicante');

COMMIT;

-- Paso 3: Ver datos insertados
SELECT '=== DEPARTAMENTOS ===' as info FROM dual;
SELECT * FROM departamentos;

SELECT '=== EMPLEADOS ===' as info FROM dual;
SELECT * FROM empleados;

-- =============================================
-- 1. INNER JOIN
-- =============================================

-- Sintaxis ANSI
SELECT e.nombre, d.nombre as departamento
FROM empleados e
INNER JOIN departamentos d ON e.departamento_id = d.id;

-- Sintaxis antigua
SELECT e.nombre, d.nombre as departamento
FROM empleados e, departamentos d
WHERE e.departamento_id = d.id;

-- =============================================
-- 2. LEFT JOIN (LEFT OUTER JOIN)
-- =============================================

-- Sintaxis ANSI
SELECT e.nombre, d.nombre as departamento
FROM empleados e
LEFT JOIN departamentos d ON e.departamento_id = d.id;

-- Sintaxis antigua (+)
SELECT e.nombre, d.nombre as departamento
FROM empleados e, departamentos d
WHERE e.departamento_id = d.id(+);

-- =============================================
-- 3. RIGHT JOIN (RIGHT OUTER JOIN)
-- =============================================

-- Sintaxis ANSI
SELECT e.nombre, d.nombre as departamento
FROM empleados e
RIGHT JOIN departamentos d ON e.departamento_id = d.id;

-- Sintaxis antigua (+)
SELECT e.nombre, d.nombre as departamento
FROM empleados e, departamentos d
WHERE e.departamento_id(+) = d.id;

-- =============================================
-- 4. FULL OUTER JOIN
-- =============================================

-- Sintaxis ANSI
SELECT e.nombre, d.nombre as departamento
FROM empleados e
FULL OUTER JOIN departamentos d ON e.departamento_id = d.id;

-- Sintaxis antigua (NO EXISTE, hay que usar UNION)
SELECT e.nombre, d.nombre as departamento
FROM empleados e, departamentos d
WHERE e.departamento_id = d.id(+)
UNION
SELECT e.nombre, d.nombre as departamento
FROM empleados e, departamentos d
WHERE e.departamento_id(+) = d.id;

-- =============================================
-- 5. CROSS JOIN
-- =============================================

-- Sintaxis ANSI
SELECT e.nombre, d.nombre as departamento
FROM empleados e
CROSS JOIN departamentos d;

-- Sintaxis antigua (sin WHERE)
SELECT e.nombre, d.nombre as departamento
FROM empleados e, departamentos d;

-- =============================================
-- 6. SELF JOIN
-- =============================================

-- Agregar columna para self join
ALTER TABLE empleados ADD manager_id NUMBER;
UPDATE empleados SET manager_id = 101 WHERE id = 104;
UPDATE empleados SET manager_id = 102 WHERE id = 105;

-- Sintaxis ANSI
SELECT e.nombre as empleado, m.nombre as manager
FROM empleados e
LEFT JOIN empleados m ON e.manager_id = m.id;

-- Sintaxis antigua
SELECT e.nombre as empleado, m.nombre as manager
FROM empleados e, empleados m
WHERE e.manager_id = m.id(+);

-- =============================================
-- 7. NATURAL JOIN (NO RECOMENDADO)
-- =============================================

-- Solo funciona si las columnas tienen el mismo nombre
CREATE TABLE dept_natural (
    id_dept NUMBER PRIMARY KEY,
    nombre VARCHAR2(50)
);
/
BEGIN
INSERT INTO dept_natural VALUES (1, 'VENTAS');
INSERT INTO dept_natural VALUES (2, 'TI');
END;
/
CREATE TABLE emp_natural (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    id_dept NUMBER  -- Mismo nombre que en dept_natural
);

/
BEGIN
INSERT INTO emp_natural VALUES (101, 'Ana García', 1);
INSERT INTO emp_natural VALUES (102, 'Carlos López', 2);
END;
/
SELECT nombre, id_dept  -- No se pueden usar e.nombre o d.nombre
FROM emp_natural 
NATURAL JOIN dept_natural;
