--  ESTO SÍ FUNCIONA - TIPOS LOCALES EN PAQUETE
CREATE OR REPLACE PACKAGE pkg_tipos_locales AS
    TYPE empleado_rec IS RECORD (
        id NUMBER,
        nombre VARCHAR2(50),
        salario NUMBER
    );
    
    TYPE empleado_table IS TABLE OF empleado_rec;
    
    -- Funciones que usan los tipos locales
    FUNCTION crear_empleado RETURN empleado_rec;
    FUNCTION obtener_empleados RETURN empleado_table;
    PROCEDURE procesar_empleados(p_emps IN empleado_table);
END pkg_tipos_locales;
/

CREATE OR REPLACE PACKAGE BODY pkg_tipos_locales AS

    FUNCTION crear_empleado RETURN empleado_rec IS
        v_emp empleado_rec;
    BEGIN
        v_emp.id := 1;
        v_emp.nombre := 'Ana García';
        v_emp.salario := 3000;
        RETURN v_emp;
    END;

    FUNCTION obtener_empleados RETURN empleado_table IS
        v_empleados empleado_table := empleado_table();
    BEGIN
        v_empleados.EXTEND(2);
        v_empleados(1).id := 1;
        v_empleados(1).nombre := 'Juan Pérez';
        v_empleados(1).salario := 2500;
        
        v_empleados(2).id := 2;
        v_empleados(2).nombre := 'María López';
        v_empleados(2).salario := 3200;
        
        RETURN v_empleados;
    END;

    PROCEDURE procesar_empleados(p_emps IN empleado_table) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Procesando ' || p_emps.COUNT || ' empleados');
        FOR i IN 1..p_emps.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(p_emps(i).nombre || ' - $' || p_emps(i).salario);
        END LOOP;
    END;

END pkg_tipos_locales;
