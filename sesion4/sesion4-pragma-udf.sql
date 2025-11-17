--1. Crear función con UDF
CREATE OR REPLACE FUNCTION duplicar_udf(n NUMBER) RETURN NUMBER IS
    PRAGMA UDF;  -- ¡Solo esta línea la hace UDF!
BEGIN
    RETURN n * 2;
END;
/
--2. Crear función normal (para comparar)
CREATE OR REPLACE FUNCTION duplicar_normal(n NUMBER) RETURN NUMBER IS
BEGIN
    RETURN n * 2;
END;
/
--3. Probar en SQL (donde UDF es más rápido)
-- Comparar rendimiento en consulta SQL
SET TIMING ON

SELECT duplicar_udf(LEVEL) FROM DUAL CONNECT BY LEVEL <= 100000;    -- Rápido
SELECT duplicar_normal(LEVEL) FROM DUAL CONNECT BY LEVEL <= 100000; -- Lento

SET TIMING OFF
