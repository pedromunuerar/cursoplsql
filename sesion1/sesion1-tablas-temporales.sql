CREATE GLOBAL TEMPORARY TABLE tmp_resultados (
   id NUMBER,
   valor NUMBER
) ON COMMIT DELETE ROWS;

INSERT INTO tmp_resultados VALUES (1, 42);

SELECT * FROM tmp_resultados; 

COMMIT;

SELECT * FROM tmp_resultados;  -- No devuelve filas (se borraron al commit)

DROP TABLE tmp_resultados;

CREATE GLOBAL TEMPORARY TABLE tmp_resultados (
   id NUMBER,
   valor NUMBER
) ON COMMIT PRESERVE ROWS;

INSERT INTO tmp_resultados VALUES (1, 42);

SELECT * FROM tmp_resultados; 

COMMIT;

SELECT * FROM tmp_resultados;  -En la misma sesion si devuelve filas
