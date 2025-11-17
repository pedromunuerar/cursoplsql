--1. Crear tabla con MILLONES de registros

-- Tabla con 1 millón de registros (simulando ventas)
CREATE TABLE ventas_masivas AS
SELECT 
    LEVEL as venta_id,
    MOD(LEVEL, 100) as cliente_id,
    DBMS_RANDOM.VALUE(10, 1000) as monto_bruto,
    DATE '2023-01-01' + DBMS_RANDOM.VALUE(0, 365) as fecha_venta,
    MOD(LEVEL, 5) + 1 as region_id,
    CASE MOD(LEVEL, 4) 
        WHEN 0 THEN 'A' 
        WHEN 1 THEN 'B' 
        WHEN 2 THEN 'C' 
        ELSE 'D' 
    END as categoria
FROM DUAL 
CONNECT BY LEVEL <= 100000;  -- 1 MILLÓN de registros

--2. Función de negocio simple (sin parallel)

CREATE OR REPLACE FUNCTION calcular_neto_serial(
    p_monto_bruto NUMBER,
    p_region_id NUMBER,
    p_categoria VARCHAR2
) RETURN NUMBER IS
    v_descuento NUMBER;
    v_impuesto NUMBER;
    v_monto_neto NUMBER;
BEGIN
    -- Lógica de negocio simple pero aplicada a MUCHOS registros
    -- Descuento por región
    v_descuento := p_monto_bruto * (p_region_id * 0.01);
    
    -- Impuesto por categoría
    CASE p_categoria
        WHEN 'A' THEN v_impuesto := p_monto_bruto * 0.10;
        WHEN 'B' THEN v_impuesto := p_monto_bruto * 0.15;
        WHEN 'C' THEN v_impuesto := p_monto_bruto * 0.20;
        ELSE v_impuesto := p_monto_bruto * 0.12;
    END CASE;
    
    -- Monto neto final
    v_monto_neto := p_monto_bruto - v_descuento + v_impuesto;
    
    RETURN ROUND(v_monto_neto, 2);
END;
/
--3. Misma función CON parallel enable

CREATE OR REPLACE FUNCTION calcular_neto_parallel(
    p_monto_bruto NUMBER,
    p_region_id NUMBER,
    p_categoria VARCHAR2
) RETURN NUMBER PARALLEL_ENABLE DETERMINISTIC IS
    v_descuento NUMBER;
    v_impuesto NUMBER;
    v_monto_neto NUMBER;
BEGIN
    -- EXACTAMENTE la misma lógica
    v_descuento := p_monto_bruto * (p_region_id * 0.01);
    
    CASE p_categoria
        WHEN 'A' THEN v_impuesto := p_monto_bruto * 0.10;
        WHEN 'B' THEN v_impuesto := p_monto_bruto * 0.15;
        WHEN 'C' THEN v_impuesto := p_monto_bruto * 0.20;
        ELSE v_impuesto := p_monto_bruto * 0.12;
    END CASE;
    
    v_monto_neto := p_monto_bruto - v_descuento + v_impuesto;
    
    RETURN ROUND(v_monto_neto, 2);
END;
/

--Prueba 1: Procesamiento SERIAL (lento con muchos registros)

SET TIMING ON
SET AUTOTRACE TRACE STAT

-- Procesar 500,000 registros en SERIAL
SELECT 
    region_id,
    COUNT(*) as total_ventas,
    SUM(calcular_neto_serial(monto_bruto, region_id, categoria)) as total_neto,
    AVG(calcular_neto_serial(monto_bruto, region_id, categoria)) as promedio_neto
FROM ventas_masivas 
WHERE venta_id <= 100000  -- Medio millón de registros
GROUP BY region_id
ORDER BY region_id;

SET AUTOTRACE OFF
SET TIMING OFF
--Prueba 2: Procesamiento PARALLEL (rápido)

SET TIMING ON
SET AUTOTRACE TRACE STAT

-- Procesar 500,000 registros en PARALLEL
SELECT /*+ PARALLEL(ventas_masivas, 4) */ 
    region_id,
    COUNT(*) as total_ventas,
    SUM(calcular_neto_parallel(monto_bruto, region_id, categoria)) as total_neto,
    AVG(calcular_neto_parallel(monto_bruto, region_id, categoria)) as promedio_neto
FROM ventas_masivas 
WHERE venta_id <= 100000  -- Mismo medio millón
GROUP BY region_id
ORDER BY region_id;

SET AUTOTRACE OFF
SET TIMING OFF


--5. Ver el paralelismo REAL en acción

-- Ver el plan de ejecución PARALLEL
EXPLAIN PLAN FOR
SELECT /*+ PARALLEL(ventas_masivas, 4) */ 
    region_id,
    SUM(calcular_neto_parallel(monto_bruto, region_id, categoria))
FROM ventas_masivas 
WHERE region_id BETWEEN 1 AND 3
GROUP BY region_id;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
--6. Comparar estadísticas

-- Ver uso de CPU y tiempo
SELECT sql_id, elapsed_time, cpu_time, executions
FROM v$sql 
WHERE sql_text LIKE '%calcular_neto_parallel%'
   OR sql_text LIKE '%calcular_neto_serial%';


