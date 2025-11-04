-- Como SYS, crear directorio virtual
CREATE OR REPLACE DIRECTORY ARCHIVOS_DIR AS '/opt/oracle/archivos';

--El directorio tiene que existir y tener permisos en él

-- Dar permisos al usuario
GRANT READ, WRITE  ON DIRECTORY ARCHIVOS_DIR TO C##DEVUSER1;
GRANT READ, WRITE  ON DIRECTORY ARCHIVOS_DIR TO C##DEVUSER2;

--Como tenemos problemas con directorios creados a mano por toda la dockerización usamos el DATA_PUMP_DIR

GRANT READ, WRITE  ON DIRECTORY DATA_PUMP_DIR TO C##DEVUSER1;
GRANT READ, WRITE  ON DIRECTORY DATA_PUMP_DIR TO C##DEVUSER2;

SELECT directory_name, directory_path FROM all_directories;

