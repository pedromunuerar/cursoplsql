-- Función que calcula IVA
CREATE OR REPLACE FUNCTION calcular_iva(p_precio NUMBER) RETURN NUMBER IS
    v_iva_porcentaje NUMBER := 0.21;  -- 21% IVA
BEGIN
    RETURN p_precio * v_iva_porcentaje;
END;
/

-- TEST sin INLINE (llamadas normales a función)
DECLARE
    v_precio NUMBER := 100;
    v_iva NUMBER;
    v_total NUMBER;
BEGIN
    FOR i IN 1..1000000 LOOP
        v_iva := calcular_iva(v_precio + i);  -- 1,000,000 llamadas
        v_total := (v_precio + i) + v_iva;
    END LOOP;
END;
/

-- TEST con INLINE (el compilador optimiza)
DECLARE
    v_precio NUMBER := 100;
    v_iva NUMBER;
    v_total NUMBER;
    PRAGMA INLINE(calcular_iva, 'YES');  -- INLINE activado
BEGIN
    FOR i IN 1..1000000 LOOP
        v_iva := calcular_iva(v_precio + i);  -- Se convierte en: (v_precio + i) * 0.21
        v_total := (v_precio + i) + v_iva;
    END LOOP;
END;
/
