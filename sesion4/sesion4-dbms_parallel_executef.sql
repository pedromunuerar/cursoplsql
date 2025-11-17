--Tabla de ejemplo:

CREATE TABLE test_parallel AS
SELECT level AS id, 'OLD' AS status
FROM dual
CONNECT BY level <= 100000;

-- PASO 1 — Crear la tarea
BEGIN
  DBMS_PARALLEL_EXECUTE.CREATE_TASK('task_update_status');
END;
/
--Verificar que ha sido creada
SELECT task_name FROM user_parallel_execute_tasks WHERE task_name = 'task_proc_parallel';

-- Crear los chunks (dividir tabla en trozos)

--La forma más simple: por ROWID.

BEGIN
  DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_ROWID(
      task_name   => 'task_update_status',
      table_owner => USER,
      table_name  => 'TEST_PARALLEL',
      by_row      => TRUE,
      chunk_size  => 20000   -- 20k filas por chunk
  );
END;
/

--Esto va a crear ~50 chunks para 1 millón de filas.
-- PASO 3 — Ejecutar la operación en paralelo
DECLARE
 l_sql_stmt varchar2(200);
BEGIN
   l_sql_stmt := 'UPDATE test_parallel SET status = ''NEW'' WHERE rowid BETWEEN :start_id AND :end_id';
  DBMS_PARALLEL_EXECUTE.RUN_TASK('task_update_status',l_sql_stmt, DBMS_SQL.NATIVE, parallel_level => 8);
END;
/ --Otra opcion con PLSQL
DECLARE
 l_sql_stmt varchar2(200);
BEGIN
   l_sql_stmt := 'BEGIN UPDATE test_parallel SET status = ''NEW'' WHERE rowid BETWEEN :start_id AND :end_id; END;';
  DBMS_PARALLEL_EXECUTE.RUN_TASK('task_update_status',l_sql_stmt, DBMS_SQL.NATIVE, parallel_level => 8);
END;
/
--Otra opcion con PROCEDIMIENTO
--CREAMOS EL PROC
  CREATE OR REPLACE PROCEDURE process_chunk (
    p_start IN ROWID,
    p_end   IN ROWID
) AS
BEGIN
    UPDATE test_parallel
    SET status = 'PROC'
    WHERE rowid BETWEEN p_start AND p_end;

    COMMIT;
END;
----------Y lo llamamos
DECLARE
l_pl_sql varchar2(200);
BEGIN
 l_pl_sql:='BEGIN process_chunk(:start_id, :end_id); END;';
  DBMS_PARALLEL_EXECUTE.RUN_TASK('task_update_status',l_pl_sql, DBMS_SQL.NATIVE,parallel_level => 8 );
END;
/

--Oracle lanzará 8 procesos concurrentes, cada uno procesando chunks hasta terminar.
--Revisar Estado
   SELECT chunk_id, status FROM user_parallel_execute_chunks WHERE task_name = 'task_update_status';
--Si hay que relanzar
BEGIN
  DBMS_PARALLEL_EXECUTE.RESTART_TASK('task_update_status');
END;

-- PASO 4 — Finalizar y limpiar la tarea
BEGIN
  DBMS_PARALLEL_EXECUTE.DROP_TASK('task_update_status');
END;
/

SELECT status, COUNT(*)
FROM test_parallel
GROUP BY status;
