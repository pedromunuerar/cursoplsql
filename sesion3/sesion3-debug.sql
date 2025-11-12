--Vamos a depurar este procedimiento
CREATE OR REPLACE PROCEDURE SP_CALCULAR_FACTORIAL (
    p_numero_in IN NUMBER,
    p_resultado_out OUT NUMBER
)
IS
    v_factorial NUMBER := 1;
    v_contador  NUMBER;
    v_mensaje   VARCHAR2(100);
BEGIN
    -- Punto de interrupción 1: Inicio del procedimiento
    v_contador := p_numero_in;

    IF v_contador <= 0 THEN
        p_resultado_out := 1;
        v_mensaje := 'El número es cero o menor. Factorial es 1.';
        DBMS_OUTPUT.PUT_LINE(v_mensaje);
        RETURN;
    END IF;

    -- Punto de interrupción 2: Antes del bucle
    WHILE v_contador > 0 LOOP
        v_factorial := v_factorial * v_contador;
        v_mensaje := 'Multiplicando por ' || v_contador || ', resultado actual: ' || v_factorial;
        DBMS_OUTPUT.PUT_LINE(v_mensaje); -- Para ver el progreso
        
        -- Punto de interrupción 3: Dentro del bucle
        v_contador := v_contador - 1;
    END LOOP;

    p_resultado_out := v_factorial;
    v_mensaje := 'Cálculo finalizado. Resultado final: ' || p_resultado_out;
    DBMS_OUTPUT.PUT_LINE(v_mensaje);

-- Punto de interrupción 4: Fin del procedimiento
END SP_CALCULAR_FACTORIAL;
