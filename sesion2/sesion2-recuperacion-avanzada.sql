-- =====================================================================
-- TABLAS BASE (reutilizamos las anteriores)
-- =====================================================================

-- Tabla de ventas mensuales
CREATE TABLE ventas (
    id           NUMBER PRIMARY KEY,
    empleado_id  NUMBER,
    mes          VARCHAR2(10),
    monto        NUMBER(10,2)
);

INSERT INTO ventas VALUES (1, 1, 'Ene', 2000);
INSERT INTO ventas VALUES (2, 1, 'Feb', 2500);
INSERT INTO ventas VALUES (3, 1, 'Mar', 3000);
INSERT INTO ventas VALUES (4, 2, 'Ene', 4000);
INSERT INTO ventas VALUES (5, 2, 'Feb', 3800);
INSERT INTO ventas VALUES (6, 3, 'Ene', 1500);
COMMIT;

--------------------------------------------------------------------------------
-- 1. Funciones de ventana para recorrer datos
--------------------------------------------------------------------------------
-- Acceder al registro anterior o siguiente sin self join
--------------------------------------------------------------------------------

SELECT empleado_id,
       mes,
       monto,
       LAG(monto) OVER (PARTITION BY empleado_id ORDER BY mes) AS anterior,
       LEAD(monto) OVER (PARTITION BY empleado_id ORDER BY mes) AS siguiente,
       monto - LAG(monto) OVER (PARTITION BY empleado_id ORDER BY mes) AS variacion
FROM ventas
ORDER BY empleado_id, mes;

-- Comentario:
-- LAG() → valor anterior; LEAD() → valor siguiente.
-- PARTITION BY define el grupo lógico (por empleado).
-- ORDER BY define la secuencia dentro del grupo.
-- Permite calcular diferencias intermensuales sin auto joins.


--------------------------------------------------------------------------------
-- 2. FIRST_VALUE / LAST_VALUE: primeros y últimos valores del grupo
--------------------------------------------------------------------------------

SELECT empleado_id,
       mes,
       monto,
       FIRST_VALUE(monto) OVER (PARTITION BY empleado_id ORDER BY mes
                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS primer_mes,
       LAST_VALUE(monto) OVER (PARTITION BY empleado_id ORDER BY mes
                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS ultimo_mes
FROM ventas
ORDER BY empleado_id, mes;

-- Comentario:
-- FIRST_VALUE y LAST_VALUE recuperan el valor inicial y final de la ventana.
-- IMPORTANTE: el frame (ROWS BETWEEN...) es clave para que funcione correctamente.
-- Oracle no asume por defecto "todo el grupo" para LAST_VALUE.


--------------------------------------------------------------------------------
-- 3. NTH_VALUE: acceder al enésimo registro de una partición
--------------------------------------------------------------------------------

SELECT empleado_id,
       mes,
       monto,
       NTH_VALUE(monto, 2) OVER (PARTITION BY empleado_id ORDER BY mes
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS segundo_mes
FROM ventas
ORDER BY empleado_id, mes;

-- Comentario:
-- Permite traer, por ejemplo, la venta del 2º mes sin joins ni subconsultas.
-- Útil en análisis de progresión o validación de secuencias temporales.


--------------------------------------------------------------------------------
-- 4. Recorrido con desplazamiento acumulado: SUM() OVER
--------------------------------------------------------------------------------

SELECT empleado_id,
       mes,
       monto,
       SUM(monto) OVER (PARTITION BY empleado_id ORDER BY mes
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS acumulado
FROM ventas
ORDER BY empleado_id, mes;

-- Comentario:
-- Calcula el acumulado progresivo por empleado.
-- No requiere GROUP BY, pero sigue el orden definido.


--------------------------------------------------------------------------------
-- 5. PIVOT: transponer filas a columnas (resumen horizontal)
--------------------------------------------------------------------------------

-- Queremos ver ventas mensuales como columnas por empleado

SELECT *
FROM (
    SELECT empleado_id, mes, monto
    FROM ventas
)
PIVOT (
    SUM(monto) FOR mes IN ('Ene' AS Enero, 'Feb' AS Febrero, 'Mar' AS Marzo)
)
ORDER BY empleado_id;

-- Comentario:
-- PIVOT convierte filas en columnas dinámicas (pivotado horizontal).
-- SUM(monto) es la agregación sobre la variable pivot.
-- Los alias (Enero, Febrero...) permiten etiquetas legibles.


--------------------------------------------------------------------------------
-- 6. UNPIVOT: transponer columnas a filas
--------------------------------------------------------------------------------

-- Revertimos la tabla anterior a formato vertical

SELECT empleado_id, mes, monto
FROM (
    SELECT *
    FROM (
        SELECT empleado_id, mes, monto FROM ventas
    )
    PIVOT (
        SUM(monto) FOR mes IN ('Ene' AS Enero, 'Feb' AS Febrero, 'Mar' AS Marzo)
    )
)
UNPIVOT (
    monto FOR mes IN (Enero AS 'Ene', Febrero AS 'Feb', Marzo AS 'Mar')
)
ORDER BY empleado_id, mes;

-- Comentario:
-- UNPIVOT hace el proceso inverso → transforma columnas en filas.
-- Muy útil para normalizar datos exportados de hojas Excel o informes planos.


--------------------------------------------------------------------------------
-- 7. LATERAL (CROSS APPLY / OUTER APPLY): consultas dependientes por fila
--------------------------------------------------------------------------------

-- Supongamos que queremos traer el mes con mayor monto por empleado.

SELECT e.empleado_id,
       v_top.mes,
       v_top.monto
FROM (SELECT DISTINCT empleado_id FROM ventas) e,
     LATERAL (
       SELECT mes, monto
       FROM ventas v
       WHERE v.empleado_id = e.empleado_id
       ORDER BY monto DESC
       FETCH FIRST 1 ROW ONLY
     ) v_top;

-- Comentario:
-- LATERAL permite usar columnas del SELECT principal dentro de la subconsulta.
-- Equivale a un "CROSS APPLY" en SQL Server.
-- Ideal para subconsultas por fila sin necesidad de funciones analíticas.


--------------------------------------------------------------------------------
-- 8. MODEL clause: recorrer y calcular filas como si fuera un array
--------------------------------------------------------------------------------
-- (Una de las características más potentes y menos conocidas de Oracle SQL)
--------------------------------------------------------------------------------

SELECT empleado_id,
       mes,
       monto,
       ROUND(prevision,2) AS proyeccion
FROM ventas
MODEL
  PARTITION BY (empleado_id)
  DIMENSION BY (mes)
  MEASURES (monto, 0 AS prevision)
  RULES (
    prevision['Ene'] = monto['Ene'],
    prevision['Feb'] = monto['Ene'] * 1.10,
    prevision['Mar'] = prevision['Feb'] * 1.10
  )
ORDER BY empleado_id, mes;

-- Comentario:
-- MODEL convierte el conjunto de resultados en una “matriz multidimensional”.
-- Permite definir reglas de cálculo tipo hoja de cálculo Excel.
-- Las reglas pueden referirse a otras celdas (por ejemplo, ‘Feb’ depende de ‘Ene’).
-- Útil para simulaciones financieras, predicciones o proyecciones.


--------------------------------------------------------------------------------
-- 9. MATCH_RECOGNIZE: detección de patrones secuenciales
--------------------------------------------------------------------------------
-- (SQL para análisis temporal o de series de eventos)
--------------------------------------------------------------------------------

SELECT *
FROM ventas
MATCH_RECOGNIZE (
  PARTITION BY empleado_id
  ORDER BY mes
  MEASURES
    MATCH_NUMBER() AS num_patron,
    CLASSIFIER() AS patron,
    FIRST(monto) AS monto_inicial,
    LAST(monto) AS monto_final
  ALL ROWS PER MATCH
  PATTERN (a b+)
  DEFINE
    a AS a.monto < 2500,
    b AS b.monto > PREV(b.monto)
);

-- Comentario:
-- MATCH_RECOGNIZE identifica secuencias (como "picos" o "crecimientos").
-- `DEFINE` especifica condiciones entre filas.
-- Oracle lo ejecuta como un motor interno de detección de patrones temporales.
--------------------------------------------------------------------------------
