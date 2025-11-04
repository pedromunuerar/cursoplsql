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
