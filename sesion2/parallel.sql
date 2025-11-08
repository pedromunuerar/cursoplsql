DROP TABLE test_duplicados;
ALTER SESSION SET "_optimizer_squ_bottomup" = FALSE;
ALTER SESSION SET "_optimizer_cost_based_transformation" = OFF;
ALTER SESSION SET QUERY_REWRITE_ENABLED = FALSE;

CREATE TABLE test_duplicados AS
SELECT MOD(ROWNUM, 1000) as valor, 'dato' || MOD(ROWNUM, 100) as texto
FROM dual CONNECT BY LEVEL <= 10000000;

select * from test_duplicados;

SELECT DISTINCT valor FROM test_duplicados;

SELECT UNIQUE valor FROM test_duplicados;

SELECT /*+ PARALLEL(8) */ DISTINCT valor FROM test_duplicados;

--Sin parallel
EXPLAIN PLAN FOR
SELECT DISTINCT valor FROM test_duplicados;

| Id  | Operation                  | Name            | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |                 |  1000 |  4000 |  6340   (6)| 00:00:01 |
|   1 |  HASH UNIQUE               |                 |  1000 |  4000 |  6340   (6)| 00:00:01 |
|   2 |   TABLE ACCESS STORAGE FULL| TEST_DUPLICADOS |    10M|    38M|  6023   (1)| 00:00:01 |
----------------------------------------------------------------------------------------------


--Con parallel
EXPLAIN PLAN FOR
SELECT /*+ PARALLEL(8) */ DISTINCT valor FROM test_duplicados;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
---------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                        | Name            | Rows  | Bytes | Cost (%CPU)| Time     |    TQ  |IN-OUT| PQ Distrib |
---------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                 |                 |  1000 |  4000 |   875   (6)| 00:00:01 |        |      |            |
|   1 |  PX COORDINATOR                  |                 |       |       |            |          |        |      |            |
|   2 |   PX SEND QC (RANDOM)            | :TQ10001        |  1000 |  4000 |   875   (6)| 00:00:01 |  Q1,01 | P->S | QC (RAND)  |
|   3 |    HASH UNIQUE                   |                 |  1000 |  4000 |   875   (6)| 00:00:01 |  Q1,01 | PCWP |            |
|   4 |     PX RECEIVE                   |                 |  1000 |  4000 |   875   (6)| 00:00:01 |  Q1,01 | PCWP |            |
|   5 |      PX SEND HASH                | :TQ10000        |  1000 |  4000 |   875   (6)| 00:00:01 |  Q1,00 | P->P | HASH       |
|   6 |       HASH UNIQUE                |                 |  1000 |  4000 |   875   (6)| 00:00:01 |  Q1,00 | PCWP |            |
|   7 |        PX BLOCK ITERATOR         |                 |    10M|    38M|   836   (1)| 00:00:01 |  Q1,00 | PCWC |            |
|   8 |         TABLE ACCESS STORAGE FULL| TEST_DUPLICADOS |    10M|    38M|   836   (1)| 00:00:01 |  Q1,00 | PCWP |            |
---------------------------------------------------------------------------------------------------------------------------------



