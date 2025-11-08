-- =============================================================================
-- SCRIPT COMPLETO: ROW_NUMBER() OVER(PARTITION BY) - EJEMPLOS PRÁCTICOS
-- =============================================================================

-- Limpiar entorno (opcional, comenta si no quieres eliminar tablas existentes)
DROP TABLE ventas PURGE;

-- =============================================================================
-- 1. CREACIÓN DE LA TABLA VENTAS
-- =============================================================================
CREATE TABLE ventas (
    venta_id NUMBER PRIMARY KEY,
    vendedor_id NUMBER,
    region VARCHAR2(50),
    producto VARCHAR2(100),
    monto_venta NUMBER(10,2),
    fecha_venta DATE
);

-- =============================================================================
-- 2. INSERCIÓN DE DATOS DE EJEMPLO
-- =============================================================================
INSERT INTO ventas VALUES (1, 101, 'Norte', 'Laptop', 1500.00, DATE '2024-01-15');
INSERT INTO ventas VALUES (2, 101, 'Norte', 'Tablet', 800.00, DATE '2024-01-20');
INSERT INTO ventas VALUES (3, 102, 'Norte', 'Laptop', 1500.00, DATE '2024-01-25');
INSERT INTO ventas VALUES (4, 103, 'Sur', 'Smartphone', 600.00, DATE '2024-02-01');
INSERT INTO ventas VALUES (5, 103, 'Sur', 'Laptop', 1500.00, DATE '2024-02-05');
INSERT INTO ventas VALUES (6, 103, 'Sur', 'Tablet', 800.00, DATE '2024-02-10');
INSERT INTO ventas VALUES (7, 104, 'Este', 'Smartphone', 600.00, DATE '2024-02-15');
INSERT INTO ventas VALUES (8, 104, 'Este', 'Smartphone', 600.00, DATE '2024-02-20');
INSERT INTO ventas VALUES (9, 105, 'Oeste', 'Laptop', 1500.00, DATE '2024-03-01');
INSERT INTO ventas VALUES (10, 105, 'Oeste', 'Tablet', 800.00, DATE '2024-03-05');
INSERT INTO ventas VALUES (11, 101, 'Norte', 'Smartphone', 600.00, DATE '2024-03-10');
INSERT INTO ventas VALUES (12, 102, 'Norte', 'Tablet', 800.00, DATE '2024-03-15');

COMMIT;

-- =============================================================================
-- 3. MOSTRAR DATOS ORIGINALES
-- =============================================================================
-- === DATOS ORIGINALES DE LA TABLA VENTAS ===
SELECT * FROM ventas ORDER BY region, fecha_venta;

-- =============================================================================
-- 4. EJEMPLO 1: TOP 2 VENTAS POR REGIÓN (Por monto)
-- =============================================================================
--- === EJEMPLO 1: TOP 2 VENTAS POR REGIÓN (Por monto más alto) ===

SELECT *
FROM (
    SELECT 
        venta_id,
        vendedor_id,
        region,
        producto,
        monto_venta,
        fecha_venta,
        ROW_NUMBER() OVER (
            PARTITION BY region 
            ORDER BY monto_venta DESC
        ) as ranking
    FROM ventas
)
WHERE ranking <= 2
ORDER BY region, ranking;

/*
EXPLICACIÓN:
- PARTITION BY region: Crea grupos separados para cada región
- ORDER BY monto_venta DESC: Ordena de mayor a menor venta dentro de cada región
- ROW_NUMBER(): Asigna 1, 2, 3... a cada fila dentro de su región
- WHERE ranking <= 2: Filtra para obtener solo los 2 primeros de cada región
*/

-- =============================================================================
-- 5. EJEMPLO 2: ÚLTIMA VENTA DE CADA VENDEDOR
-- =============================================================================
-- === EJEMPLO 2: ÚLTIMA VENTA DE CADA VENDEDOR ===

SELECT *
FROM (
    SELECT 
        venta_id,
        vendedor_id,
        region,
        producto,
        monto_venta,
        fecha_venta,
        ROW_NUMBER() OVER (
            PARTITION BY vendedor_id 
            ORDER BY fecha_venta DESC
        ) as ultima_venta_flag
    FROM ventas
)
WHERE ultima_venta_flag = 1
ORDER BY vendedor_id;

/*
EXPLICACIÓN:
- PARTITION BY vendedor_id: Agrupa por cada vendedor
- ORDER BY fecha_venta DESC: Ordena por fecha descendente (la más reciente primero)
- WHERE ultima_venta_flag = 1: Toma solo el registro más reciente de cada vendedor
*/

-- =============================================================================
-- 6. EJEMPLO 3: RANKING DE VENTAS POR VENDEDOR Y REGIÓN
-- =============================================================================
--=== EJEMPLO 3: RANKING DE VENTAS POR VENDEDOR Y REGIÓN ===

SELECT 
    venta_id,
    vendedor_id,
    region,
    producto,
    monto_venta,
    fecha_venta,
    ROW_NUMBER() OVER (
        PARTITION BY vendedor_id, region 
        ORDER BY monto_venta DESC, fecha_venta DESC
    ) as ranking_vendedor_region
FROM ventas
ORDER BY vendedor_id, region, ranking_vendedor_region;

/*
EXPLICACIÓN:
- PARTITION BY vendedor_id, region: Crea grupos por combinación de vendedor y región
- ORDER BY monto_venta DESC, fecha_venta DESC: Ordena por monto y luego por fecha
- Útil para ver el desempeño de cada vendedor en cada región
*/

-- =============================================================================
-- 7. EJEMPLO 4: COMPARACIÓN CON OTRAS FUNCIONES DE RANKING
-- =============================================================================
-- === EJEMPLO 4: COMPARACIÓN ROW_NUMBER vs RANK vs DENSE_RANK ===

SELECT 
    venta_id,
    vendedor_id,
    region,
    producto,
    monto_venta,
    -- ROW_NUMBER: Siempre números consecutivos únicos (1,2,3,4...)
    ROW_NUMBER() OVER (PARTITION BY region ORDER BY monto_venta DESC) as row_num,
    -- RANK: Mismo número para empates, salta números (1,2,2,4...)
    RANK() OVER (PARTITION BY region ORDER BY monto_venta DESC) as rank_num,
    -- DENSE_RANK: Mismo número para empates, no salta (1,2,2,3...)
    DENSE_RANK() OVER (PARTITION BY region ORDER BY monto_venta DESC) as dense_rank_num
FROM ventas
ORDER BY region, monto_venta DESC;

/*
DIFERENCIAS CLAVE:
- ROW_NUMBER(): Nunca hay empates, siempre números consecutivos únicos
- RANK(): Empates reciben mismo número, siguiente número se salta
- DENSE_RANK(): Empates reciben mismo número, siguiente número es consecutivo
*/

-- =============================================================================
-- 8. EJEMPLO 5: ELIMINAR DUPLICADOS (Ejemplo demostrativo - no ejecuta DELETE)
-- =============================================================================
-- === EJEMPLO 5: IDENTIFICAR DUPLICADOS (Para eliminación) ===

SELECT *
FROM (
    SELECT 
        venta_id,
        vendedor_id,
        region,
        producto,
        monto_venta,
        fecha_venta,
        ROW_NUMBER() OVER (
            PARTITION BY vendedor_id, producto, monto_venta 
            ORDER BY fecha_venta
        ) as dup_flag
    FROM ventas
)
WHERE dup_flag > 1
ORDER BY vendedor_id, producto;

/*
PARA ELIMINAR DUPLICADOS (ejecutar por separado si es necesario):
DELETE FROM ventas
WHERE venta_id IN (
    SELECT venta_id
    FROM (
        SELECT venta_id,
               ROW_NUMBER() OVER (PARTITION BY vendedor_id, producto, monto_venta ORDER BY fecha_venta) as rn
        FROM ventas
    )
    WHERE rn > 1
);
*/

-- =============================================================================
-- 9. EJEMPLO 6: PAGINACIÓN DE RESULTADOS
-- =============================================================================
--=== EJEMPLO 6: PAGINACIÓN - PÁGINA 2 (Registros 6-10) ===

SELECT *
FROM (
    SELECT 
        venta_id,
        vendedor_id,
        region,
        producto,
        monto_venta,
        fecha_venta,
        ROW_NUMBER() OVER (ORDER BY fecha_venta DESC) as row_num
    FROM ventas
)
WHERE row_num BETWEEN 6 AND 10
ORDER BY row_num;

/*
EXPLICACIÓN PAGINACIÓN:
- ROW_NUMBER() OVER (ORDER BY...): Numera todas las filas
- WHERE row_num BETWEEN X AND Y: Selecciona rango específico
- Útil para aplicaciones web/móviles con paginación
*/

-- =============================================================================
-- 10. EJEMPLO 7: VENTAS ACUMULADAS POR VENDEDOR
-- =============================================================================
-- === EJEMPLO 7: VENTAS ACUMULADAS POR VENDEDOR ===

SELECT 
    venta_id,
    vendedor_id,
    producto,
    monto_venta,
    fecha_venta,
    ROW_NUMBER() OVER (PARTITION BY vendedor_id ORDER BY fecha_venta) as venta_numero,
    SUM(monto_venta) OVER (PARTITION BY vendedor_id ORDER BY fecha_venta) as acumulado_vendedor
FROM ventas
ORDER BY vendedor_id, fecha_venta;

/*
EXPLICACIÓN:
- ROW_NUMBER(): Número de venta para cada vendedor
- SUM() OVER(): Acumulado progresivo del monto de ventas
- Muestra la evolución de ventas de cada vendedor
*/

-- =============================================================================
-- 11. RESUMEN Y ESTADÍSTICAS
-- =============================================================================
--- === RESUMEN ESTADÍSTICO ===

-- Conteo por región
SELECT 
    region,
    COUNT(*) as total_ventas,
    SUM(monto_venta) as total_monto,
    ROUND(AVG(monto_venta), 2) as promedio_venta
FROM ventas
GROUP BY region
ORDER BY total_monto DESC;

-- Top vendedores por región usando ROW_NUMBER
SELECT 
    region,
    vendedor_id,
    total_ventas,
    total_monto,
    ranking
FROM (
    SELECT 
        region,
        vendedor_id,
        COUNT(*) as total_ventas,
        SUM(monto_venta) as total_monto,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(monto_venta) DESC) as ranking
    FROM ventas
    GROUP BY region, vendedor_id
)
WHERE ranking = 1
ORDER BY region;
