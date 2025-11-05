-- Crear tablas de ejemplo
CREATE TABLE empleados (
  id NUMBER PRIMARY KEY,
  nombre VARCHAR2(50),
  salario NUMBER,
  departamento_id NUMBER,
  fecha_alta DATE DEFAULT SYSDATE
);

CREATE TABLE staging_empleados AS
SELECT LEVEL AS id, 'Empleado_' || LEVEL AS nombre,
       ROUND(DBMS_RANDOM.VALUE(1500, 6000),2) AS salario,
       TRUNC(DBMS_RANDOM.VALUE(1,4)) AS departamento_id
FROM dual CONNECT BY LEVEL <= 5000;

-- Inserción masiva optimizada
INSERT /*+ APPEND */ INTO empleados
SELECT * FROM staging_empleados;
COMMIT;

-- Inserción condicional
INSERT ALL
  WHEN salario < 2500 THEN INTO empleados_junior VALUES (id, nombre, salario, departamento_id, SYSDATE)
  WHEN salario >= 2500 THEN INTO empleados_senior VALUES (id, nombre, salario, departamento_id, SYSDATE)
SELECT * FROM staging_empleados WHERE ROWNUM <= 100;

-- Inserción con MERGE
MERGE INTO empleados e
USING staging_empleados s
ON (e.id = s.id)
WHEN MATCHED THEN UPDATE SET e.salario = s.salario * 1.02
WHEN NOT MATCHED THEN INSERT (id, nombre, salario, departamento_id)
VALUES (s.id, s.nombre, s.salario, s.departamento_id);

-- Inserción PL/SQL con FORALL y manejo de errores
DECLARE
  TYPE t_emps IS TABLE OF staging_empleados%ROWTYPE;
  v_data t_emps;
  dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(dml_errors, -24381);
BEGIN
  SELECT * BULK COLLECT INTO v_data FROM staging_empleados WHERE ROWNUM <= 1000;

  FORALL i IN v_data.FIRST .. v_data.LAST SAVE EXCEPTIONS
    INSERT INTO empleados VALUES v_data(i);

EXCEPTION
  WHEN dml_errors THEN
    FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('Error en fila ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
    END LOOP;
END;
/
