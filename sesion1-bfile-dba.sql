-- Como SYS, crear directorio virtual
CREATE OR REPLACE DIRECTORY ARCHIVOS_DIR AS '/opt/oracle/archivos';

--El directorio tiene que existir y tener permisos en él

-- Dar permisos al usuario
GRANT READ, WRITE  ON DIRECTORY ARCHIVOS_DIR TO C##DEVUSER1;
GRANT READ, WRITE  ON DIRECTORY ARCHIVOS_DIR TO C##DEVUSER2;
