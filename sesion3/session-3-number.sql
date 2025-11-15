DECLARE
    v_start TIMESTAMP;
    v_end   TIMESTAMP;
    x NUMBER := 0; -- NUMBER vs PLS_INTEGER vs SIMPLE_INTEGER
BEGIN
    v_start := SYSTIMESTAMP;
    FOR i IN 1 .. 50000000 LOOP
        x := x + 1;
    END LOOP;
    v_end := SYSTIMESTAMP;
    DBMS_OUTPUT.PUT_LINE('Tiempo: ' || (v_end - v_start));
END;
