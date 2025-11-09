--------------------------------------------------------------------------------
-- SESIÓN 6: AGREGACIONES AVANZADAS
-- Temas: GROUP BY, HAVING, ROLLUP, CUBE, GROUPING SETS, funciones analíticas
--------------------------------------------------------------------------------

-- ============================================================================
-- 1. TABLAS BASE
-- ============================================================================

CREATE TABLE ventas_detalle (
    id           NUMBER PRIMARY KEY,
    region       VARCHAR2(20),
    vendedor     VARCHAR2(20),
    producto     VARCHAR2(20),
    mes          VARCHAR2(10),
    monto        NUMBER(10,2)
);

INSERT INTO ventas_detalle VALUES (1, 'Europa', 'Ana', 'Laptop', 'Ene', 1200);
INSERT INTO ventas_detalle VALUES (2, 'Europa', 'Ana', 'Tablet', 'Ene', 900);
INSERT INTO ventas_detalle VALUES (3, 'Europa', 'Luis', 'Laptop', 'Feb', 1500);
INSERT INTO ventas_detalle VALUES (4, 'Europa', 'Luis', 'Tablet', 'Feb', 700);
INSERT INTO ventas_detalle VALUES (5, 'América', 'Marta', 'Laptop', 'Ene', 1000);
INSERT INTO ventas_detalle VALUES (6, 'América', 'Marta', 'Tablet', 'Ene', 800);
INSERT INTO ventas_detalle VALUES (7, 'América', 'Pablo', 'Laptop', 'Feb', 1300);
INSERT INTO ventas_detalle VALUES (8, 'América', 'Pablo', 'Tablet', 'Feb', 600);
COMMIT;


--------------------------------------------------------------------------------
-- 2. GROUP BY básico (repaso)
--------------------------------------------------------------------------------

SELECT region, vendedor, SUM(monto) AS total_ventas
FROM ventas_detalle
GROUP BY region, vendedor
ORDER BY region, vendedor;

-- Comentario:
-- Agrupa por región y vendedor.
-- SUM() es una función agregada → una fila por grupo.
-- Las funciones agregadas ignoran NULL por defecto.


--------------------------------------------------------------------------------
-- 3. HAVING: filtrar grupos (no filas individuales)
--------------------------------------------------------------------------------

SELECT region, vendedor, SUM(monto) AS total_ventas
FROM ventas_detalle
GROUP BY region, vendedor
HAVING SUM(monto) > 2000
ORDER BY region, vendedor;

-- Comentario:
-- HAVING se aplica DESPUÉS del GROUP BY.
-- No puede usarse en lugar de WHERE (WHERE filtra filas antes de agrupar).


--------------------------------------------------------------------------------
-- 4. ROLLUP: subtotales automáticos jerárquicos
--------------------------------------------------------------------------------

SELECT region, vendedor, SUM(monto) AS total_ventas
FROM ventas_detalle
GROUP BY ROLLUP(region, vendedor)
ORDER BY region, vendedor;

-- Comentario:
-- Genera automáticamente:
--   - Totales por vendedor
--   - Totales por región
--   - Total general (NULL,NULL)
--
-- Orden de columnas define la jerarquía de subtotal.
-- Ideal para reportes tipo “Excel” jerárquico.


--------------------------------------------------------------------------------
-- 5. CUBE: todas las combinaciones posibles de agrupación
--------------------------------------------------------------------------------

SELECT region, vendedor, SUM(monto) AS total_ventas
FROM ventas_detalle
GROUP BY CUBE(region, vendedor)
ORDER BY region, vendedor;

-- Comentario:
-- Genera todas las combinaciones:
--   (region,vendedor), (region,NULL), (NULL,vendedor), (NULL,NULL)
-- Permite comparativas cruzadas.
-- Mucho más pesado que ROLLUP → úsalo con cuidado.


--------------------------------------------------------------------------------
-- 6. GROUPING y GROUPING_ID: distinguir totales de NULL reales
--------------------------------------------------------------------------------

SELECT
  region,
  vendedor,
  SUM(monto) AS total_ventas,
  GROUPING(region) AS g_region,
  GROUPING(vendedor) AS g_vendedor,
  GROUPING_ID(region, vendedor) AS grupo_id
FROM ventas_detalle
GROUP BY ROLLUP(region, vendedor)
ORDER BY grupo_id;

-- Comentario:
-- GROUPING(columna) devuelve 1 si la columna pertenece a una fila de subtotal.
-- GROUPING_ID combina los bits → útil para post-procesar o exportar.
-- Diferencia entre NULL real y NULL por subtotal.


--------------------------------------------------------------------------------
-- 7. GROUPING SETS: subtotales específicos
--------------------------------------------------------------------------------

SELECT region, vendedor, SUM(monto) AS total_ventas
FROM ventas_detalle
GROUP BY GROUPING SETS (
    (region, vendedor),   -- Detalle
    (region),             -- Total por región
    ()                    -- Total general
)
ORDER BY region, vendedor;

-- Comentario:
-- Similar a ROLLUP, pero tú defines los niveles que te interesan.
-- Evita cálculos innecesarios → más eficiente.
-- Oracle ejecuta internamente múltiples GROUP BY y los une.


--------------------------------------------------------------------------------
-- 8. FUNCIONES ANALÍTICAS (sin agrupar)
--------------------------------------------------------------------------------

-- Calcular total regional y porcentaje por vendedor sin perder detalle

SELECT
  region,
  vendedor,
  SUM(monto) AS total_vendedor,
  SUM(SUM(monto)) OVER (PARTITION BY region) AS total_region,
  ROUND(SUM(monto) / SUM(SUM(monto)) OVER (PARTITION BY region) * 100, 2) AS pct_region
FROM ventas_detalle
GROUP BY region, vendedor
ORDER BY region, vendedor;

-- Comentario:
-- SUM(SUM(monto)) OVER (...) → doble agregación:
--   la primera SUM() agrupa, la segunda OVER() calcula sobre esos grupos.
-- Combina lo mejor de GROUP BY + analíticas.


--------------------------------------------------------------------------------
-- 9. Funciones analíticas puras con OVER()
--------------------------------------------------------------------------------

-- Total acumulado por región y vendedor ordenado por monto

SELECT
  region,
  vendedor,
  mes,
  monto,
  SUM(monto) OVER (PARTITION BY region ORDER BY vendedor, mes
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS acumulado,
  AVG(monto) OVER (PARTITION BY region) AS promedio_region
FROM ventas_detalle
ORDER BY region, vendedor, mes;

-- Comentario:
-- SUM() OVER() calcula agregaciones por ventana sin agrupar.
-- Cada fila conserva su granularidad.
-- Rango de ventana configurable con ROWS o RANGE.


--------------------------------------------------------------------------------
-- 10. COMBINAR ROLLUP + analíticas
--------------------------------------------------------------------------------

SELECT
  region,
  vendedor,
  SUM(monto) AS total_ventas,
  RATIO_TO_REPORT(SUM(monto)) OVER () AS pct_total
FROM ventas_detalle
GROUP BY ROLLUP(region, vendedor)
ORDER BY region, vendedor;

-- Comentario:
-- RATIO_TO_REPORT() calcula el porcentaje sobre el total del conjunto.
-- Permite enriquecer los subtotales de ROLLUP con métricas comparativas.


--------------------------------------------------------------------------------
-- 11. UNION vs UNION ALL para combinaciones de agregaciones
--------------------------------------------------------------------------------

SELECT region, NULL AS vendedor, SUM(monto) AS total
FROM ventas_detalle
GROUP BY region
UNION ALL
SELECT NULL, vendedor, SUM(monto)
FROM ventas_detalle
GROUP BY vendedor;

-- Comentario:
-- UNION ALL no elimina duplicados (más rápido).
-- UNION elimina duplicados (más costoso).
-- En análisis OLAP, UNION ALL suele ser preferible.
--------------------------------------------------------------------------------
