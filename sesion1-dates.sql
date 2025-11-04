--Creamos la tabla eventos
CREATE TABLE eventos (
   id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   nombre varchar2(100),
   fecha_creacion DATE DEFAULT SYSDATE,
   fecha_detallada TIMESTAMP DEFAULT SYSTIMESTAMP,
   fecha_global TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
   fecha_local TIMESTAMP WITH LOCAL TIME ZONE DEFAULT SYSTIMESTAMP);


INSERT INTO eventos (nombre) values ('ddd');

--Probamos
SELECT * FROM eventos;

-- DATE → TIMESTAMP
CAST(fecha AS TIMESTAMP)

-- TIMESTAMP → DATE (trunca precisión)
CAST(fecha_ts AS DATE)

-- Conversión de zonas horarias
FROM_TZ(TIMESTAMP '2025-10-27 12:00:00', 'Europe/Madrid')
   AT TIME ZONE 'America/Mexico_City';

SELECT CAST(fecha_creacion AS TIMESTAMP)  FROM eventos;

SELECT CAST(fecha_detallada AS DATE)  FROM eventos;

SELECT fecha_creacion
   AT TIME ZONE 'America/Mexico_City'  FROM eventos;
   
SELECT fecha_global
   AT TIME ZONE 'America/Mexico_City'  FROM eventos;
