-- Crear tabla temporal
CREATE GLOBAL TEMPORARY TABLE temp_employees (
    salary NUMBER
) ON COMMIT PRESERVE ROWS;

-- Insertar datos de ejemplo
INSERT INTO temp_employees 
SELECT LEVEL * 100 FROM DUAL CONNECT BY LEVEL <= 400000;

COMMIT;

-- 1. CON CAMBIOS DE CONTEXTO (Lento)
DECLARE
    v_total NUMBER := 0;
    v_start TIMESTAMP;
BEGIN
    v_start := SYSTIMESTAMP;
    
    FOR r IN (SELECT salary FROM temp_employees) LOOP
        v_total := v_total + r.salary;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('CON CAMBIOS: ' || (SYSTIMESTAMP - v_start));
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_total);
END;
/

-- 2. SIN CAMBIOS DE CONTEXTO (Óptimo)
DECLARE
    v_total NUMBER;
    v_start TIMESTAMP;
BEGIN
    v_start := SYSTIMESTAMP;
    
    SELECT SUM(salary) INTO v_total FROM temp_employees;
    
    DBMS_OUTPUT.PUT_LINE('SIN CAMBIOS: ' || (SYSTIMESTAMP - v_start));
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_total);
END;
