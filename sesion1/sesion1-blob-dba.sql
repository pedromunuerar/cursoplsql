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
