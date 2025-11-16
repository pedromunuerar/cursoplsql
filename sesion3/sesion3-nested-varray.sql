-- SCENARIO: Almacenar notas de estudiantes

-- 1. VARRAY - Tamaño fijo (máximo 5 notas por estudiante)
CREATE TYPE varray_notas AS VARRAY(5) OF NUMBER;
/

-- 2. Nested Table - Tamaño variable (notas ilimitadas)
CREATE TYPE nested_notas AS TABLE OF NUMBER;
/

-- TABLA CON VARRAY
CREATE TABLE estudiantes_varray (
    id NUMBER,
    nombre VARCHAR2(50),
    notas varray_notas
);

-- TABLA CON NESTED TABLE
CREATE TABLE estudiantes_nested (
    id NUMBER,
    nombre VARCHAR2(50),
    notas nested_notas
) NESTED TABLE notas STORE AS notas_nt;  -- ¡Tabla de almacenamiento!

-- INSERTS
INSERT INTO estudiantes_varray VALUES (1, 'Ana', varray_notas(8, 9, 7));
INSERT INTO estudiantes_nested VALUES (2, 'Luis', nested_notas(6, 7, 8, 9, 10, 5));

-- CONSULTAS
SELECT * FROM estudiantes_varray;
SELECT * FROM estudiantes_nested;

-- OPERACIONES ESPECÍFICAS
DECLARE
    v_notas_varray varray_notas := varray_notas(1, 2, 3);
    v_notas_nested nested_notas := nested_notas(1, 2, 3, 4, 5);
BEGIN
    -- VARRAY: límite fijo
    v_notas_varray.EXTEND(2);  -- Puedo extender hasta 5 total
    
    -- NESTED: límite flexible  
    v_notas_nested.EXTEND(10);  -- Puedo extender mucho más
    v_notas_nested.DELETE(3);   -- Puedo eliminar elementos
    
    DBMS_OUTPUT.PUT_LINE('VARRAY count: ' || v_notas_varray.COUNT);
    DBMS_OUTPUT.PUT_LINE('NESTED count: ' || v_notas_nested.COUNT);
END;
/

-- ACCESO A DATOS
DECLARE
    v_varray_data varray_notas;
    v_nested_data nested_notas;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ACCESO A DATOS ===');
    
    -- Acceder a VARRAY
    SELECT notas INTO v_varray_data FROM estudiantes_varray WHERE id = 1;
    DBMS_OUTPUT.PUT_LINE('VARRAY - Nota 1: ' || v_varray_data(1));
    DBMS_OUTPUT.PUT_LINE('VARRAY - Total notas: ' || v_varray_data.COUNT);
    
    -- Acceder a NESTED TABLE  
    SELECT notas INTO v_nested_data FROM estudiantes_nested WHERE id = 2;
    DBMS_OUTPUT.PUT_LINE('NESTED - Nota 3: ' || v_nested_data(3));
    DBMS_OUTPUT.PUT_LINE('NESTED - Total notas: ' || v_nested_data.COUNT);
END;
/

-- MODIFICACIÓN DE DATOS
DECLARE
    v_varray_data varray_notas;
    v_nested_data nested_notas;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== MODIFICACIÓN ===');
    
    -- Modificar VARRAY
    SELECT notas INTO v_varray_data FROM estudiantes_varray WHERE id = 1;
    v_varray_data(1) := 10;  -- Cambiar primera nota
    v_varray_data.EXTEND;    -- Añadir nueva nota
    v_varray_data(4) := 8;   -- Asignar valor a nueva posición
    
    UPDATE estudiantes_varray SET notas = v_varray_data WHERE id = 1;
    DBMS_OUTPUT.PUT_LINE('VARRAY modificado - Nueva nota 1: ' || v_varray_data(1));
    
    -- Modificar NESTED TABLE
    SELECT notas INTO v_nested_data FROM estudiantes_nested WHERE id = 2;
    v_nested_data(1) := 9;        -- Cambiar primera nota
    v_nested_data.DELETE(2);      -- Eliminar segunda nota
    v_nested_data.EXTEND(2);      -- Añadir 2 nuevas posiciones
    v_nested_data(6) := 7;        -- Asignar valores
    v_nested_data(7) := 8;
    
    UPDATE estudiantes_nested SET notas = v_nested_data WHERE id = 2;
    DBMS_OUTPUT.PUT_LINE('NESTED modificado - Nueva nota 1: ' || v_nested_data(1));
    DBMS_OUTPUT.PUT_LINE('NESTED - Count después de modificar: ' || v_nested_data.COUNT);
END;
/

-- CONSULTA DIRECTA DESDE SQL
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== CONSULTA SQL ===');
    
    -- Consultar VARRAY (se ve como columna normal)
    FOR r IN (SELECT * FROM estudiantes_varray) LOOP
        DBMS_OUTPUT.PUT_LINE('VARRAY ID: ' || r.id || ', Notas: ' || r.notas.COUNT);
    END LOOP;
    
    -- Consultar NESTED TABLE con TABLE()
    FOR r IN (
        SELECT e.id, e.nombre, n.column_value as nota
        FROM estudiantes_nested e, TABLE(e.notas) n
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('NESTED - Est: ' || r.nombre || ', Nota: ' || r.nota);
    END LOOP;
END;
/
