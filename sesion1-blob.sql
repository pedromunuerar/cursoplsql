/*
BLOB
*/

--En el mismo tablespace
CREATE TABLE documentos (
   id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   nombre VARCHAR2(200),
   archivo BLOB
);
/
--Mejor usar otro tablespace
-------------------------------------------------------------------------
--Para DBA as SYS
-- Crear tablespace para BLOBs
SELECT name FROM v$datafile;

ALTER SESSION SET CONTAINER = XEPDB1;

SELECT name, con_id FROM v$database;

SHOW CON_NAME;

CREATE TABLESPACE blob_ts
DATAFILE '/opt/oracle/oradata/XE/XEPDB1/blob_ts01.dbf' SIZE 50M
AUTOEXTEND ON NEXT 25M MAXSIZE 200M;

ALTER SYSTEM SET db_create_file_dest = '/opt/oracle/oradata/XE/XEPDB1';

CREATE TABLESPACE blob_data
DATAFILE SIZE 50M
AUTOEXTEND ON NEXT 25M MAXSIZE 200M;

SELECT tablespace_name, file_name, bytes/1024/1024 size_mb
FROM dba_data_files 
WHERE tablespace_name = 'BLOB_TS';


SELECT username, default_tablespace, created 
FROM dba_users;

-- Dar espacio ilimitado en el tablespace de BLOBs
ALTER USER C##DEVUSER1 QUOTA UNLIMITED ON blob_ts;

--------------------------------------------------------------------------
/

  
--Mover un BLOB existente  
ALTER TABLE documentos
MOVE LOB(archivo) STORE AS SECUREFILE 
(TABLESPACE blob_ts);
/
--Opciones avanzadas BLOB en otro tablespace
CREATE TABLE documentos_avanzados (
   id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   nombre VARCHAR2(200),
   archivo BLOB,
   miniatura BLOB,
   metadata CLOB
)
LOB(archivo) STORE AS SECUREFILE (
   TABLESPACE blob_large_ts
   COMPRESS HIGH                    -- Compresión
   CACHE                            -- Cachear en buffer
)
LOB(miniatura) STORE AS SECUREFILE (
   TABLESPACE blob_ts
   COMPRESS LOW
   CACHE
)
LOB(metadata) STORE AS SECUREFILE (
   TABLESPACE blob_ts
);
/

-- Consultar dónde se almacenan los LOBs
SELECT table_name, column_name, tablespace_name, segment_name
FROM user_lobs
WHERE table_name = 'DOCUMENTOS';
/
-- Ver espacios utilizados
SELECT tablespace_name, segment_name, bytes/1024/1024 as size_mb
FROM user_segments
WHERE tablespace_name = 'BLOB_TS';
