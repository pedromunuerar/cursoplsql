CREATE TABLE logs (
   id NUMBER GENERATED ALWAYS AS IDENTITY,
   evento VARCHAR2(200),
   fecha_evento DATE DEFAULT SYSDATE
)
PARTITION BY RANGE (fecha_evento) (
   PARTITION p_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')),
   PARTITION p_2025 VALUES LESS THAN (TO_DATE('2026-01-01', 'YYYY-MM-DD')),
   PARTITION p_max  VALUES LESS THAN (MAXVALUE)
);

/


-- Insertar datos en la partición p_2024 (año 2024)
INSERT INTO logs (evento, fecha_evento) VALUES ('Login usuario', TO_DATE('2024-03-15', 'YYYY-MM-DD'));
INSERT INTO logs (evento, fecha_evento) VALUES ('Error BD', TO_DATE('2024-06-20', 'YYYY-MM-DD'));
INSERT INTO logs (evento, fecha_evento) VALUES ('Backup completo', TO_DATE('2024-12-31', 'YYYY-MM-DD'));
-- Insertar datos en la partición p_2025 (año 2025)
INSERT INTO logs (evento, fecha_evento) VALUES ('Nuevo registro', TO_DATE('2025-01-01', 'YYYY-MM-DD'));
INSERT INTO logs (evento, fecha_evento) VALUES ('Actualización', TO_DATE('2025-07-15', 'YYYY-MM-DD'));
INSERT INTO logs (evento, fecha_evento) VALUES ('Consulta API', TO_DATE('2025-11-30', 'YYYY-MM-DD'));
-- Insertar datos en la partición p_max (años futuros)
INSERT INTO logs (evento, fecha_evento) VALUES ('Evento futuro', TO_DATE('2026-05-20', 'YYYY-MM-DD'));
INSERT INTO logs (evento, fecha_evento) VALUES ('Mantenimiento', TO_DATE('2027-01-10', 'YYYY-MM-DD'));
INSERT INTO logs (evento, fecha_evento) VALUES ('Auditoría', TO_DATE('2030-12-25', 'YYYY-MM-DD'));


-- Insertar múltiples registros de una vez
INSERT INTO logs (evento, fecha_evento)
SELECT 
    'Evento batch ' || LEVEL,
    CASE 
        WHEN LEVEL <= 3 THEN TO_DATE('2024-08-' || LEVEL, 'YYYY-MM-DD')
        WHEN LEVEL <= 6 THEN TO_DATE('2025-08-' || (LEVEL-3), 'YYYY-MM-DD')
        ELSE TO_DATE('2026-08-' || (LEVEL-6), 'YYYY-MM-DD')
    END
FROM dual CONNECT BY LEVEL <= 9;

SELECT * FROM logs PARTITION (p_2024);
SELECT * FROM logs PARTITION (p_2025); 
SELECT * FROM logs PARTITION (p_max);

select * from logs;

-- Método 1: TRUNCATE PARTITION (MÁS EFICIENTE - no genera undo logs)
ALTER TABLE logs TRUNCATE PARTITION p_2024;
-- Esto elimina todos los datos de la partición p_2024 inmediatamente

-- Método 2: DROP PARTITION (elimina la partición y sus datos)
ALTER TABLE logs DROP PARTITION p_2025;
-- Esto elimina la partición p_2025 y todos sus datos

-- Método 3: DELETE tradicional (menos eficiente para muchas filas)
DELETE FROM logs PARTITION (p_max);
-- COMMIT; -- Si usas transacciones

-- Crear nueva partición para 2026 (antes de que lleguen datos) FALLARA
ALTER TABLE logs ADD PARTITION p_2026 
VALUES LESS THAN (TO_DATE('2027-01-01', 'YYYY-MM-DD'));

-- Dividir la partición p_max para organizar mejor los datos futuros
ALTER TABLE logs SPLIT PARTITION p_max AT (TO_DATE('2027-01-01', 'YYYY-MM-DD'))
INTO (PARTITION p_2026, PARTITION p_max);

-- Ver información de las particiones
SELECT partition_name, high_value, num_rows
FROM user_tab_partitions 
WHERE table_name = 'LOGS';
