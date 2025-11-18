--Crear dos tablas idénticas (una con flash KEEP)
-- tabla normal
CREATE TABLE ventas_normal AS
SELECT level AS id, TRUNC(DBMS_RANDOM.VALUE(1,1000)) AS importe
FROM dual CONNECT BY level <= 5e6;

-- tabla en flash cache (solo Exadata)
CREATE TABLE ventas_flash
STORAGE (FLASH_CACHE KEEP) AS
SELECT * FROM ventas_normal;

--2 Forzar limpieza de buffer cache (solo DBA)
ALTER SYSTEM FLUSH BUFFER_CACHE;

-️-3 Activar estadísticas en la sesión
ALTER SESSION SET statistics_level = ALL;

--4 Medir estadísticas ANTES de la consulta
SELECT name, value
FROM v$sesstat s JOIN v$statname n USING(statistic#)
WHERE sid = SYS_CONTEXT('USERENV','SID')
  AND name LIKE 'flash%';

-- Ejecutar primera consulta (tabla normal)
SET TIMING ON

SELECT SUM(importe)
FROM ventas_normal;

SET TIMING OFF
--Apunta el tiempo.

--6 Ver estadísticas DESPUÉS
SELECT name, value
FROM v$sesstat s JOIN v$statname n USING(statistic#)
WHERE sid = SYS_CONTEXT('USERENV','SID')
  AND name LIKE 'flash%';


--Métrica clave:
physical read flash cache hits

flash cache read hits

--7 Repetir el mismo proceso con la tabla en flash
--Limpia nuevamente buffer cache:

ALTER SYSTEM FLUSH BUFFER_CACHE;

--Mide estadísticas, ejecuta:

SET TIMING ON

SELECT SUM(importe)
FROM ventas_flash;

SET TIMING OFF


--Mide estadísticas otra vez.
