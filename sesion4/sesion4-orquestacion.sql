--Tablas auxiliares necesarias:
CREATE TABLE resultados_suma (chunk_id NUMBER, valor NUMBER);
CREATE TABLE temp_suma (grupo NUMBER, suma NUMBER);

-- Versión ultra compacta: cálculo y suma en un solo flujo
DECLARE
    l_promedio NUMBER;
BEGIN
    -- Calcular notas en paralelo
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('NOTAS1');
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_ROWID('NOTAS1', USER, 'ESTUDIANTES', TRUE, 100);
    
    DBMS_PARALLEL_EXECUTE.RUN_TASK('NOTAS1',
        'BEGIN UPDATE estudiantes SET nota_final = (nota1 * 0.4 + nota2 * 0.6) WHERE rowid BETWEEN :start_id AND :end_id; END;',
        DBMS_SQL.NATIVE, 4
    );
    DBMS_PARALLEL_EXECUTE.WAIT_FOR_TASK('NOTAS1');
    
    -- Sumar en paralelo  
    DBMS_PARALLEL_EXECUTE.CREATE_TASK('NOTAS2');
    DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL('NOTAS2', 'SELECT LEVEL, LEVEL FROM DUAL CONNECT BY LEVEL <= 5', FALSE);
    
    DBMS_PARALLEL_EXECUTE.RUN_TASK('NOTAS2',
        'BEGIN INSERT INTO temp_suma SELECT :start_id, SUM(nota_final) FROM estudiantes WHERE MOD(id,5) = :start_id; END;',
        DBMS_SQL.NATIVE, 5
    );
    DBMS_PARALLEL_EXECUTE.WAIT_FOR_TASK('NOTAS2');
    
    -- Resultado final
    SELECT SUM(nota_final), AVG(nota_final) INTO l_suma_total, l_promedio FROM estudiantes;
    DBMS_OUTPUT.PUT_LINE('🎓 SUMA: ' || l_suma_total || ' | PROMEDIO: ' || l_promedio);
    
    DBMS_PARALLEL_EXECUTE.DROP_TASK('NOTAS1');
    DBMS_PARALLEL_EXECUTE.DROP_TASK('NOTAS2');
END;
/
