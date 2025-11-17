CREATE OR REPLACE FUNCTION calcular_complejo_normal(x NUMBER) 
RETURN NUMBER IS
    resultado NUMBER;
BEGIN
    -- Simulamos un cálculo complejo
    FOR i IN 1..1000000 LOOP
        resultado := (x * i) / 3.1416 + SQRT(x + i);
    END LOOP;
    RETURN resultado;
END;
/

CREATE OR REPLACE FUNCTION calcular_complejo_parallel(x NUMBER) 
RETURN NUMBER PARALLEL_ENABLE DETERMINISTIC IS
    resultado NUMBER;
BEGIN
    -- Mismo cálculo complejo
    FOR i IN 1..1000000 LOOP
        resultado := (x * i) / 3.1416 + SQRT(x + i);
    END LOOP;
    RETURN resultado;
END;
/

-- Tabla con muchos datos
CREATE TABLE numeros_prueba AS
SELECT LEVEL as id, 
       DBMS_RANDOM.VALUE(1, 1000) as valor
FROM DUAL 
CONNECT BY LEVEL <= 1000;

SET TIMING ON

SELECT id, calcular_complejo_normal(valor) as resultado
FROM numeros_prueba
WHERE id <= 100;  -- Probamos con 100 registros

SET TIMING OFF
--------------------------------------------------------------------------
SET TIMING ON

SELECT /*+ PARALLEL(4) */ 
       id, calcular_complejo_parallel(valor) as resultado
FROM numeros_prueba
WHERE id <= 100;  -- Mismos 100 registros

SET TIMING OFF
-------------------------------------------------------------------------
SET TIMING ON

SELECT /*+ PARALLEL(8) */ 
       COUNT(*), 
       AVG(calcular_complejo_parallel(valor)) as promedio
FROM numeros_prueba;  -- Todos los registros

SET TIMING OFF
-------------------------------------------------------------------
-- En la misma sesión, llamadas repetidas deberían ser más rápidas
-- gracias a DETERMINISTIC (cuando se usa en mismo contexto SQL)

SELECT calcular_complejo_parallel(100) from dual;
SELECT calcular_complejo_parallel(100) from dual; -- Más rápido
SELECT calcular_complejo_parallel(100) from dual; -- Aún más rápido
--------------------------------------------------------------------
-- Ver si se está usando paralelismo
EXPLAIN PLAN FOR
SELECT /*+ PARALLEL(4) */ 
       id, calcular_complejo_parallel(valor)
FROM numeros_prueba WHERE id <= 50;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
