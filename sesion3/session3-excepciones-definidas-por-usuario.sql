DECLARE
    e_salario_invalido EXCEPTION;
BEGIN
    -- Validar salario
    IF 500 < 1000 THEN  -- Salario muy bajo
        RAISE e_salario_invalido;
    END IF;
    
EXCEPTION
    WHEN e_salario_invalido THEN
        DBMS_OUTPUT.PUT_LINE('Error: El salario no puede ser menor a 1000');
END;
/


DECLARE
    v_salario NUMBER := 500;
BEGIN
    -- Validar salario con mensaje personalizado
    IF v_salario < 1000 THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Salario $' || v_salario || ' inválido. Mínimo permitido: $1000');
    END IF;
END;
/
