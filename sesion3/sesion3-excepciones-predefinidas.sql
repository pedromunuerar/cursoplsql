-- 1. CREAR TABLA EMPLOYEES
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100) UNIQUE,
    hire_date DATE,
    job_id VARCHAR2(20),
    salary NUMBER(8,2),
    department_id NUMBER
);
/
begin
-- 2. INSERTAR DATOS DE PRUEBA
INSERT INTO employees VALUES (100, 'Steven', 'King', 'sking@email.com', SYSDATE, 'IT_PROG', 24000, 90);
INSERT INTO employees VALUES (101, 'Neena', 'Kochhar', 'nkochhar@email.com', SYSDATE, 'IT_PROG', 17000, 90);
INSERT INTO employees VALUES (102, 'Lex', 'De Haan', 'ldehaan@email.com', SYSDATE, 'IT_PROG', 17000, 90);
INSERT INTO employees VALUES (103, 'Alexander', 'Hunold', 'ahunold@email.com', SYSDATE, 'IT_PROG', 9000, 60);
INSERT INTO employees VALUES (104, 'Bruce', 'Ernst', 'bernst@email.com', SYSDATE, 'IT_PROG', 6000, 60);
INSERT INTO employees VALUES (105, 'David', 'Austin', 'daustin@email.com', SYSDATE, 'IT_PROG', 4800, 60);

-- Insertar múltiples empleados en department_id = 50 para probar TOO_MANY_ROWS
INSERT INTO employees VALUES (106, 'John', 'Doe', 'jdoe@email.com', SYSDATE, 'SA_REP', 5000, 50);
INSERT INTO employees VALUES (107, 'Jane', 'Smith', 'jsmith@email.com', SYSDATE, 'SA_REP', 5500, 50);
INSERT INTO employees VALUES (108, 'Bob', 'Johnson', 'bjohnson@email.com', SYSDATE, 'SA_REP', 5200, 50);
end;
/
COMMIT;

-- 3. EJECUTAR EL BLOQUE PL/SQL CON LAS EXCEPCIONES
DECLARE
    v_empleado employees%ROWTYPE;
    v_salario NUMBER;
    v_resultado NUMBER;
BEGIN
    -- Ejemplo 1: NO_DATA_FOUND
    DBMS_OUTPUT.PUT_LINE('=== EJEMPLO NO_DATA_FOUND ===');
    BEGIN
        SELECT * INTO v_empleado 
        FROM employees 
        WHERE employee_id = -1; -- ID que no existe
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró el empleado solicitado');
            DBMS_OUTPUT.PUT_LINE('Código Oracle: ' || SQLCODE || ', Mensaje: ' || SQLERRM);
    END;

    -- Ejemplo 2: TOO_MANY_ROWS
    DBMS_OUTPUT.PUT_LINE('=== EJEMPLO TOO_MANY_ROWS ===');
    BEGIN
        SELECT salary INTO v_salario 
        FROM employees 
        WHERE department_id = 50; -- Múltiples empleados
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Error: La consulta retornó múltiples filas');
            DBMS_OUTPUT.PUT_LINE('Use BULK COLLECT o un cursor para manejar múltiples resultados');
    END;

    -- Ejemplo 3: DUP_VAL_ON_INDEX
    DBMS_OUTPUT.PUT_LINE('=== EJEMPLO DUP_VAL_ON_INDEX ===');
    BEGIN
        INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id)
        VALUES (100, 'Juan', 'Perez', 'juan.perez@email.com', SYSDATE, 'IT_PROG');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Error: Violación de índice único');
            DBMS_OUTPUT.PUT_LINE('El employee_id o email ya existe en la base de datos');
    END;

    -- Ejemplo 4: INVALID_CURSOR
    DBMS_OUTPUT.PUT_LINE('=== EJEMPLO INVALID_CURSOR ===');
    DECLARE
        CURSOR c_emp IS SELECT * FROM employees WHERE department_id = 10;
        v_emp c_emp%ROWTYPE;
    BEGIN
        OPEN c_emp;
        CLOSE c_emp;
        FETCH c_emp INTO v_emp; -- Error: cursor ya cerrado
    EXCEPTION
        WHEN INVALID_CURSOR THEN
            DBMS_OUTPUT.PUT_LINE('Error: Operación inválida con cursor');
            DBMS_OUTPUT.PUT_LINE('Verifique que el cursor esté abierto antes de FETCH');
    END;

    DBMS_OUTPUT.PUT_LINE('=== TODAS LAS PRUEBAS COMPLETADAS ===');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLCODE || ' - ' || SQLERRM);
END;
/

-- 4. LIMPIAR (OPCIONAL)
-- DROP TABLE employees;
