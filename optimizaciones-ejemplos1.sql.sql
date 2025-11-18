--GENTE DESA
EXPLAIN PLAN FOR
SELECT 
         afi_identificador,
        LOWER(TRIM(afi_email_no_umu)),
        'E',
        6,
        'N',
        'N'
    FROM gente.afiliaciones
    WHERE afi_email_no_umu IS NOT NULL
      AND LOWER(afi_email_no_umu) NOT LIKE '%@um.es'
      AND NOT EXISTS (
          SELECT  1
          FROM gente.credenciales_externas ce
          WHERE ce.crex_afi_identificador = afi_identificador
            AND LOWER(TRIM(ce.crex_email)) = LOWER(TRIM(afi_email_no_umu))
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


DROP INDEX afi_email_instr_idx;


CREATE INDEX afi_email_instr_idx
ON gente.afiliaciones (
    INSTR(LOWER(TRIM(NVL(afi_email_no_umu, ''))), '@um.es')
);
/
   
EXPLAIN PLAN FOR
      SELECT 
        afi_identificador,
        LOWER(TRIM(afi_email_no_umu)),
        'E',
        6,
        'N',
        'N'
    FROM gente.afiliaciones
    WHERE INSTR(LOWER(TRIM(NVL(afi_email_no_umu, ''))), '@um.es') = 0
      AND NOT EXISTS (
          SELECT 1
          FROM gente.credenciales_externas ce
          WHERE ce.crex_afi_identificador = afi_identificador
            AND LOWER(TRIM(ce.crex_email)) = LOWER(TRIM(afi_email_no_umu))
      );

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

Plan hash value: 2928108015
 
----------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |                             |   120K|  9095K|  5572   (1)| 00:00:01 |
|   1 |  NESTED LOOPS ANTI         |                             |   120K|  9095K|  5572   (1)| 00:00:01 |
|*  2 |   TABLE ACCESS STORAGE FULL| AFILIACIONES                |   128K|  5278K|  5569   (1)| 00:00:01 |
|*  3 |   INDEX RANGE SCAN         | CRED_EXTERNA_LOWER_TRIM_IDX |   467 | 16345 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - storage("AFI_EMAIL_NO_UMU" IS NOT NULL)
       filter("AFI_EMAIL_NO_UMU" IS NOT NULL AND LOWER("AFI_EMAIL_NO_UMU") IS NOT NULL AND 
              LOWER("AFI_EMAIL_NO_UMU") NOT LIKE '%@um.es')
   3 - access("CE"."CREX_AFI_IDENTIFICADOR"="AFI_IDENTIFICADOR" AND 
              LOWER(TRIM("CREX_EMAIL"))=LOWER(TRIM("AFI_EMAIL_NO_UMU")))


Plan hash value: 2945858510
 
--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |                             |   104 |  7072 |   113   (0)| 00:00:01 |
|   1 |  NESTED LOOPS ANTI                   |                             |   104 |  7072 |   113   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| AFILIACIONES                |  7853 |   253K|   112   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN                  | AFI_EMAIL_INSTR_IDX         |  3141 |       |    11   (0)| 00:00:01 |
|*  4 |   INDEX RANGE SCAN                   | CRED_EXTERNA_LOWER_TRIM_IDX |  7647 |   261K|     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access(INSTR(LOWER(TRIM(NVL("AFI_EMAIL_NO_UMU",''))),'@um.es')=0)
   4 - access("CE"."CREX_AFI_IDENTIFICADOR"="AFI_IDENTIFICADOR" AND 
