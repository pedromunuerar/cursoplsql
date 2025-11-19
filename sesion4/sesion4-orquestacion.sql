-- =============================================
-- 1. CREACIÓN DE TABLAS Y DATOS DE PRUEBA
-- =============================================

-- Tabla principal de estudiantes
CREATE TABLE estudiantes (
    id NUMBER,
    nombre VARCHAR2(50),
    nota1 NUMBER,
    nota2 NUMBER,
    nota_final NUMBER
);

-- Tabla para resultados de suma
CREATE TABLE resultados_suma (
    chunk_id NUMBER,
    suma_parcial NUMBER
);

-- Insertar 1000 estudiantes de prueba
INSERT INTO estudiantes 
SELECT LEVEL, 'Estudiante ' || LEVEL, 
       ROUND(DBMS_RANDOM.VALUE(1,10),2),
       ROUND(DBMS_RANDOM.VALUE(1,10),2),
       NULL
FROM DUAL CONNECT BY LEVEL <= 1000;

COMMIT;

-- =============================================
-- 2. FUNCIÓN PARA VERIFICAR COMPLETACIÓN (Oracle 18c)
-- =============================================
CREATE OR REPLACE FUNCTION esperar_tarea_completada(
    p_task_name IN VARCHAR2, 
    p_max_espera_segundos IN NUMBER DEFAULT 300
) RETURN BOOLEAN IS
    v_status VARCHAR2(100);
    v_contador NUMBER := 0;
BEGIN
    LOOP
        BEGIN
            -- Verificar estado de la tarea
            SELECT status INTO v_status 
            FROM user_parallel_execute_tasks 
            WHERE task_name = p_task_name;
            
            -- Si está completada, salir
            IF v_status = 'FINISHED' THEN
                RETURN TRUE;
            ELSIF v_status = 'PROCESSED_WITH_ERROR' THEN
                DBMS_OUTPUT.PUT_LINE('Tarea terminó con errores');
                RETURN FALSE;
            END IF;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Tarea no encontrada, asumiendo completada');
                RETURN TRUE;
        END;
        
        -- Esperar 1 segundo antes de revisar nuevamente
       -- DBMS_LOCK.SLEEP(1);
        v_contador := v_contador + 1;
        
        -- Salir si excede el tiempo máximo de espera
        IF v_contador >= p_max_espera_segundos THEN
            DBMS_OUTPUT.PUT_LINE('Timeout esperando tarea: ' || p_task_name);
            RETURN FALSE;
        END IF;
        
        -- Mostrar progreso cada 10 segundos
        IF MOD(v_contador, 1000) = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Esperando... ' || v_contador || 's');
        END IF;
    END LOOP;
END;
/

-- =============================================
-- 3. PROCEDIMIENTO PARA CÁLCULO PARALELO (Oracle 18c)
-- =============================================
CREATE OR REPLACE PROCEDURE calcular_notas_paralelo IS
    l_task VARCHAR2(30) := 'CALC_NOTAS_' || TO_CHAR(SYSDATE, 'HH24MISS');
    l_sql varchar2(300);
BEGIN
    DBMS_OUTPUT.PUT_LINE('🎯 Iniciando cálculo paralelo de notas...');
    
    -- Crear tarea y dividir trabajo
    DBMS_PARALLEL_EXECUTE.CREATE_TASK(l_task);
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_ROWID(l_task, USER, 'ESTUDIANTES', TRUE, 50);
    
    -- Ejecutar en paralelo
    l_sql:='BEGIN UPDATE estudiantes SET nota_final = (nota1 * 0.4 + nota2 * 0.6) WHERE rowid BETWEEN :start_id AND :end_id; END;';
    DBMS_PARALLEL_EXECUTE.RUN_TASK(l_task,
        l_sql ,
        DBMS_SQL.NATIVE, parallel_level =>4);
    
    -- Esperar completación (Oracle 18c)
    IF esperar_tarea_completada(l_task, 60) THEN
        DBMS_OUTPUT.PUT_LINE('✅ Cálculo de notas completado');
    ELSE
        DBMS_OUTPUT.PUT_LINE('❌ Error en cálculo de notas');
    END IF;
    
    DBMS_PARALLEL_EXECUTE.DROP_TASK(l_task);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('💥 Error: ' || SQLERRM);
        DBMS_PARALLEL_EXECUTE.DROP_TASK(l_task);
END;
/

-- =============================================
-- 4. PROCEDIMIENTO PARA SUMA PARALELA (Oracle 18c)
-- =============================================
CREATE OR REPLACE PROCEDURE sumar_notas_paralelo IS
    l_task VARCHAR2(30) := 'SUM_NOTAS_' || TO_CHAR(SYSDATE, 'HH24MISS');
    l_suma_total NUMBER;
    l_promedio NUMBER;
    l_sql varchar2(300);
BEGIN
    DBMS_OUTPUT.PUT_LINE('🧮 Iniciando suma paralela...');
    
    -- Limpiar tabla de resultados
    DELETE FROM resultados_suma;
    COMMIT;
    
    -- Crear tarea y dividir en 10 grupos
    DBMS_PARALLEL_EXECUTE.CREATE_TASK(l_task);
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL(l_task, 
        'SELECT LEVEL, LEVEL FROM DUAL CONNECT BY LEVEL <= 10', FALSE);
    
    -- Cada chunk suma un grupo de estudiantes
    l_sql:='DECLARE v_suma NUMBER; BEGIN SELECT SUM(nota_final) INTO v_suma FROM estudiantes WHERE id BETWEEN ((:start_id-1)*100+1) AND (:start_id*100); INSERT INTO resultados_suma VALUES(:start_id, v_suma); COMMIT; END;';
    DBMS_PARALLEL_EXECUTE.RUN_TASK(l_task,
        l_sql,
        DBMS_SQL.NATIVE, parallel_level =>5);
    
    -- Esperar completación (Oracle 18c)
    IF esperar_tarea_completada(l_task, 60) THEN
        -- Consolidar resultados
        SELECT SUM(nota_final), AVG(nota_final) INTO l_suma_total, l_promedio FROM estudiantes;
        
        DBMS_OUTPUT.PUT_LINE('📊 SUMA TOTAL: ' || l_suma_total);
        DBMS_OUTPUT.PUT_LINE('🎯 PROMEDIO: ' || ROUND(l_promedio, 2));
    ELSE
        DBMS_OUTPUT.PUT_LINE('❌ Error en suma paralela');
    END IF;
    
    DBMS_PARALLEL_EXECUTE.DROP_TASK(l_task);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('💥 Error: ' || SQLERRM);
        DBMS_PARALLEL_EXECUTE.DROP_TASK(l_task);
END;
/

-- =============================================
-- 5. PROCEDIMIENTO PRINCIPAL DE ORQUESTACIÓN
-- =============================================
CREATE OR REPLACE PROCEDURE orquestar_procesos IS
    v_inicio TIMESTAMP;
    v_fin TIMESTAMP;
BEGIN
    v_inicio := SYSTIMESTAMP;
    DBMS_OUTPUT.PUT_LINE('🚀 INICIANDO ORQUESTACIÓN DE PROCESOS - Oracle 18c');
    DBMS_OUTPUT.PUT_LINE('================================================');
    
    -- Paso 1: Cálculo paralelo de notas
    calcular_notas_paralelo();
    
    -- Paso 2: Suma paralela
    sumar_notas_paralelo();
    
    -- Estadísticas finales
    v_fin := SYSTIMESTAMP;
    DBMS_OUTPUT.PUT_LINE('================================================');
    DBMS_OUTPUT.PUT_LINE('🏁 PROCESO COMPLETADO');
    
    -- Mostrar resumen
    DBMS_OUTPUT.PUT_LINE('📈 Estadísticas finales:');
    FOR rec IN (SELECT COUNT(*) total, AVG(nota_final) promedio, MIN(nota_final) minima, MAX(nota_final) maxima FROM estudiantes) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('   • Total estudiantes: ' || rec.total);
        DBMS_OUTPUT.PUT_LINE('   • Promedio: ' || ROUND(rec.promedio, 2));
        DBMS_OUTPUT.PUT_LINE('   • Nota mínima: ' || ROUND(rec.minima, 2));
        DBMS_OUTPUT.PUT_LINE('   • Nota máxima: ' || ROUND(rec.maxima, 2));
    END LOOP;
END;
/

-- =============================================
-- 6. EJECUCIÓN Y VERIFICACIÓN
-- =============================================

-- Ejecutar la orquestación completa
SET SERVEROUTPUT ON;
BEGIN
    orquestar_procesos();
END;
/

-- Verificar datos procesados
SELECT 'Estudiantes procesados: ' || COUNT(*) FROM estudiantes WHERE nota_final IS NOT NULL
UNION ALL
SELECT 'Suma parciales calculadas: ' || COUNT(*) FROM resultados_suma
UNION ALL
SELECT 'Promedio notas: ' || ROUND(AVG(nota_final), 2) FROM estudiantes;

-- Mostrar algunos resultados de ejemplo
SELECT * FROM (
    SELECT id, nombre, nota1, nota2, nota_final 
    FROM estudiantes 
    ORDER BY id
) WHERE ROWNUM <= 5;

SELECT * FROM resultados_suma ORDER BY chunk_id;
/
