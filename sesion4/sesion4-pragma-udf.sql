--1. Función compleja con UDF
CREATE OR REPLACE FUNCTION no_det_udf(n NUMBER) RETURN NUMBER IS
    PRAGMA UDF;
BEGIN
    -- Usar SYSDATE hace que no sea determinística
    RETURN n * DBMS_RANDOM.VALUE(1, 10) + (SYSDATE - TRUNC(SYSDATE));
END;
/

CREATE OR REPLACE FUNCTION no_det_normal(n NUMBER) RETURN NUMBER IS
BEGIN
    RETURN n * DBMS_RANDOM.VALUE(1, 10) + (SYSDATE - TRUNC(SYSDATE));
END;
/
--3. Probar con MUCHAS iteraciones

SET TIMING ON

-- UDF (más rápido en SQL)
SELECT  sum(salida) FROM (
    SELECT no_det_udf(LEVEL) as salida FROM DUAL CONNECT BY LEVEL <= 1000000
);

-- Normal (más lento en SQL)  
SELECT  sum(salida) FROM (
    SELECT no_det_normal(LEVEL) as salida FROM DUAL CONNECT BY LEVEL <= 1000000
);

SET TIMING OFF
