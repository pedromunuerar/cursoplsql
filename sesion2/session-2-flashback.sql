-- FLASHBACK QUERY COMPLETO
--1 Crear tabla de ejemplo
DROP TABLE ventas_demo PURGE;

CREATE TABLE ventas_demo (
    id        NUMBER PRIMARY KEY,
    producto  VARCHAR2(50),
    cantidad  NUMBER,
    precio    NUMBER
);

--2 Insertar 20 registros
INSERT INTO ventas_demo
SELECT level,
       'Producto ' || level,
       10 + level,
       5 * level
FROM dual
CONNECT BY level <= 20;

COMMIT;

--3 Esperar unos segundos

Flashback Query usa UNDO, así que necesitamos una diferencia temporal.

BEGIN
  DBMS_LOCK.SLEEP(5);
END;
/

--4 Registrar el tiempo antes de modificar datos
VAR t_old VARCHAR2(30)
EXEC :t_old := TO_CHAR(SYSTIMESTAMP - INTERVAL '2' SECOND, 'YYYY-MM-DD HH24:MI:SS.FF');
PRINT t_old


--Esto captura un timestamp 2 segundos antes, garantizando datos en UNDO.

--5 Modificar algunos registros
UPDATE ventas_demo
SET cantidad = cantidad + 100,
    precio = precio * 2
WHERE id IN (5, 6, 7);

COMMIT;

--6 Ver datos actuales
SELECT * FROM ventas_demo ORDER BY id;

--7 Recuperar datos históricos (Flashback Query)
SELECT *
FROM ventas_demo AS OF TIMESTAMP
      TO_TIMESTAMP(:t_old, 'YYYY-MM-DD HH24:MI:SS.FF')
ORDER BY id;


--Aquí verás los valores originales antes del UPDATE.
--8 Crear una copia de la tabla histórica
CREATE TABLE ventas_demo_old AS
SELECT *
FROM ventas_demo AS OF TIMESTAMP
      TO_TIMESTAMP(:t_old, 'YYYY-MM-DD HH24:MI:SS.FF');

--9 Ver copia histórica
SELECT * FROM ventas_demo_old ORDER BY id;
