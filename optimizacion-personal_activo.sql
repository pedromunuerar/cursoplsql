EXPLAIN PLAN FOR
 SELECT x.dap_dni,
          afi_nombre dap_nombre,
          afi_apellidos dap_apellid,
          afi_sexo dap_sexo,
          x.dap_dir_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 4)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_DEP_CODIGO'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_dep_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 4)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_CED_CODIGO'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_ced_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 4)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_SED_CODIGO'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_sed_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 3)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_ACM_CODIGO'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_acm_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 4)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_ACP_CODIGO'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_acp_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 5)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_CAT_CODIGO'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_cat_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 7)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_PUF_CODIGO1'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_puf_codigo1,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 7)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_PUF_CODIGO2'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_puf_codigo2,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 7)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_PLL_CODIGO1'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_pll_codigo1,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 7)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_PLL_CODIGO2'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_pll_codigo2,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 2)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_CAA_CODIGO'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_caa_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 2)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_SAP_CODIGO'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_sap_codigo,
          (SELECT SUBSTR (hdl_valor_del_campo, 1, 4)
             FROM historico_datos_laborales
            WHERE     hdl_tca_codigo = 'DAL_DEP_CODIGO2'
                  AND hdl_dap_dni = ind_dni_laboral
                  AND hdl_fechaini <= TRUNC (SYSDATE)
                  AND hdl_fechafin >= TRUNC (SYSDATE)
                  AND ROWNUM = 1)
             dal_dep_codigo2
     FROM umdp.datos_personales x,
          umdp.historico_datos_laborales,
          indice_documentos,
          umdp.situacion_admin_personals z,
          afiliaciones
    WHERE     dap_dni = afi_identificador
          AND dap_dni = ind_dni_personal
          AND dap_dni=:DNI
          AND ind_dni_laboral = hdl_dap_dni
          AND hdl_valor_del_campo = z.sap_codigo
          AND hdl_tca_codigo = 'DAL_SAP_CODIGO'
          AND hdl_fechaini <= TRUNC (SYSDATE)
          AND hdl_fechafin >= TRUNC (SYSDATE)
          AND sap_activo = 'S';


SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);     


Plan hash value: 2754760923
 
-------------------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name                      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                           |     1 |   117 |    32   (0)| 00:00:01 |
|*  1 |  COUNT STOPKEY                        |                           |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN                   | IND_HDL_DNI_TCA_FECHAS    |     1 |       |     2   (0)| 00:00:01 |
|*  4 |  COUNT STOPKEY                        |                           |       |       |            |          |
|   5 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|*  6 |    INDEX RANGE SCAN                   | IND_HDL_DNI_TCA_FECHAS    |     1 |       |     2   (0)| 00:00:01 |
|*  7 |  COUNT STOPKEY                        |                           |       |       |            |          |
|   8 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|*  9 |    INDEX RANGE SCAN                   | IND_HDL_DNI_TCA_FECHAS    |     1 |       |     2   (0)| 00:00:01 |
|* 10 |  COUNT STOPKEY                        |                           |       |       |            |          |
|  11 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 12 |    INDEX RANGE SCAN                   | IND_HDL_DNI_TCA_FECHAS    |     1 |       |     2   (0)| 00:00:01 |
|* 13 |  COUNT STOPKEY                        |                           |       |       |            |          |
|* 14 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 15 |    INDEX RANGE SCAN                   | PK_HDL                    |     1 |       |     2   (0)| 00:00:01 |
|* 16 |  COUNT STOPKEY                        |                           |       |       |            |          |
|  17 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 18 |    INDEX RANGE SCAN                   | IND_HDL_DNI_TCA_FECHAS    |     1 |       |     2   (0)| 00:00:01 |
|* 19 |  COUNT STOPKEY                        |                           |       |       |            |          |
|* 20 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 21 |    INDEX RANGE SCAN                   | PK_HDL                    |     1 |       |     2   (0)| 00:00:01 |
|* 22 |  COUNT STOPKEY                        |                           |       |       |            |          |
|* 23 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 24 |    INDEX RANGE SCAN                   | PK_HDL                    |     1 |       |     2   (0)| 00:00:01 |
|* 25 |  COUNT STOPKEY                        |                           |       |       |            |          |
|  26 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 27 |    INDEX RANGE SCAN                   | IND_HDL_DNI_TCA_FECHAS    |     1 |       |     2   (0)| 00:00:01 |
|* 28 |  COUNT STOPKEY                        |                           |       |       |            |          |
|* 29 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 30 |    INDEX RANGE SCAN                   | PK_HDL                    |     1 |       |     2   (0)| 00:00:01 |
|* 31 |  COUNT STOPKEY                        |                           |       |       |            |          |
|* 32 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 33 |    INDEX RANGE SCAN                   | PK_HDL                    |     1 |       |     2   (0)| 00:00:01 |
|* 34 |  COUNT STOPKEY                        |                           |       |       |            |          |
|  35 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 36 |    INDEX RANGE SCAN                   | IND_HDL_DNI_TCA_FECHAS    |     1 |       |     2   (0)| 00:00:01 |
|* 37 |  COUNT STOPKEY                        |                           |       |       |            |          |
|* 38 |   TABLE ACCESS BY INDEX ROWID BATCHED | HISTORICO_DATOS_LABORALES |     1 |    45 |     2   (0)| 00:00:01 |
|* 39 |    INDEX RANGE SCAN                   | PK_HDL                    |     1 |       |     2   (0)| 00:00:01 |
|  40 |  NESTED LOOPS                         |                           |     1 |   117 |     6   (0)| 00:00:01 |
|  41 |   NESTED LOOPS                        |                           |     1 |   112 |     5   (0)| 00:00:01 |
|  42 |    NESTED LOOPS                       |                           |     1 |    67 |     4   (0)| 00:00:01 |
|  43 |     NESTED LOOPS                      |                           |     1 |    49 |     3   (0)| 00:00:01 |
|  44 |      TABLE ACCESS BY INDEX ROWID      | AFILIACIONES              |     1 |    36 |     2   (0)| 00:00:01 |
|* 45 |       INDEX UNIQUE SCAN               | PK_AFI                    |     1 |       |     1   (0)| 00:00:01 |
|  46 |      TABLE ACCESS BY INDEX ROWID      | DATOS_PERSONALES          |     1 |    13 |     1   (0)| 00:00:01 |
|* 47 |       INDEX UNIQUE SCAN               | PK_DAP                    |     1 |       |     1   (0)| 00:00:01 |
|* 48 |     INDEX RANGE SCAN                  | PK_IND                    |     1 |    18 |     1   (0)| 00:00:01 |
|  49 |    TABLE ACCESS BY INDEX ROWID BATCHED| HISTORICO_DATOS_LABORALES |     1 |    45 |     1   (0)| 00:00:01 |
|* 50 |     INDEX RANGE SCAN                  | IND_HDL_DNI_TCA_FECHAS    |     1 |       |     1   (0)| 00:00:01 |
|* 51 |   INDEX RANGE SCAN                    | IDX_SAP_ACTIVO_CODIGO     |     1 |     5 |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(ROWNUM=1)
   3 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_DEP_CODIGO' AND "HDL_FECHAFIN">=TRUNC(SYSDATE@!) 
              AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
       filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
   4 - filter(ROWNUM=1)
   6 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_CED_CODIGO' AND "HDL_FECHAFIN">=TRUNC(SYSDATE@!) 
              AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
       filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
   7 - filter(ROWNUM=1)
   9 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_SED_CODIGO' AND "HDL_FECHAFIN">=TRUNC(SYSDATE@!) 
              AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
       filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  10 - filter(ROWNUM=1)
  12 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_ACM_CODIGO' AND "HDL_FECHAFIN">=TRUNC(SYSDATE@!) 
              AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
       filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  13 - filter(ROWNUM=1)
  14 - filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  15 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_ACP_CODIGO' AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
  16 - filter(ROWNUM=1)
  18 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_CAT_CODIGO' AND "HDL_FECHAFIN">=TRUNC(SYSDATE@!) 
              AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
       filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  19 - filter(ROWNUM=1)
  20 - filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  21 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_PUF_CODIGO1' AND 
              "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
  22 - filter(ROWNUM=1)
  23 - filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  24 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_PUF_CODIGO2' AND 
              "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
  25 - filter(ROWNUM=1)
  27 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_PLL_CODIGO1' AND 
              "HDL_FECHAFIN">=TRUNC(SYSDATE@!) AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
       filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  28 - filter(ROWNUM=1)
  29 - filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  30 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_PLL_CODIGO2' AND 
              "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
  31 - filter(ROWNUM=1)
  32 - filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  33 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_CAA_CODIGO' AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
  34 - filter(ROWNUM=1)
  36 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_SAP_CODIGO' AND "HDL_FECHAFIN">=TRUNC(SYSDATE@!) 
              AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
       filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  37 - filter(ROWNUM=1)
  38 - filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  39 - access("HDL_DAP_DNI"=:B1 AND "HDL_TCA_CODIGO"='DAL_DEP_CODIGO2' AND 
              "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
  45 - access("AFI_IDENTIFICADOR"='23277850')
  47 - access("DAP_DNI"='23277850')
  48 - access("IND_DNI_PERSONAL"='23277850')
  50 - access("IND_DNI_LABORAL"="HDL_DAP_DNI" AND "HDL_TCA_CODIGO"='DAL_SAP_CODIGO' AND 
              "HDL_FECHAFIN">=TRUNC(SYSDATE@!) AND "HDL_FECHAINI"<=TRUNC(SYSDATE@!))
       filter("HDL_FECHAFIN">=TRUNC(SYSDATE@!))
  51 - access("SAP_ACTIVO"='S' AND "HDL_VALOR_DEL_CAMPO"="Z"."SAP_CODIGO")
 
Note
-----
   - this is an adaptive plan



 
         
--EXPLAIN PLAN FOR          --2351
CREATE FORCE EDITIONABLE VIEW "UMDP"."PERSONAL_ACTIVO_OPT" ("DAP_DNI", "DAP_NOMBRE", "DAP_APELLID", "DAP_SEXO", "DAP_DIR_CODIGO", "DAL_DEP_CODIGO", "DAL_CED_CODIGO", "DAL_SED_CODIGO", "DAL_ACM_CODIGO", "DAL_ACP_CODIGO", "DAL_CAT_CODIGO", "DAL_PUF_CODIGO1", "DAL_PUF_CODIGO2", "DAL_PLL_CODIGO1", "DAL_PLL_CODIGO2", "DAL_CAA_CODIGO", "DAL_SAP_CODIGO", "DAL_DEP_CODIGO2") AS 
WITH /*+ MATERIALIZE */
h AS (
    SELECT
        hdl_dap_dni,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_DEP_CODIGO'  THEN hdl_valor_del_campo END) AS dal_dep_codigo,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_CED_CODIGO'  THEN hdl_valor_del_campo END) AS dal_ced_codigo,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_SED_CODIGO'  THEN hdl_valor_del_campo END) AS dal_sed_codigo,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_ACM_CODIGO'  THEN hdl_valor_del_campo END) AS dal_acm_codigo,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_ACP_CODIGO'  THEN hdl_valor_del_campo END) AS dal_acp_codigo,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_CAT_CODIGO'  THEN hdl_valor_del_campo END) AS dal_cat_codigo,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_PUF_CODIGO1' THEN hdl_valor_del_campo END) AS dal_puf_codigo1,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_PUF_CODIGO2' THEN hdl_valor_del_campo END) AS dal_puf_codigo2,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_PLL_CODIGO1' THEN hdl_valor_del_campo END) AS dal_pll_codigo1,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_PLL_CODIGO2' THEN hdl_valor_del_campo END) AS dal_pll_codigo2,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_CAA_CODIGO'  THEN hdl_valor_del_campo END) AS dal_caa_codigo,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_SAP_CODIGO'  THEN hdl_valor_del_campo END) AS dal_sap_codigo,
        MAX(CASE WHEN hdl_tca_codigo = 'DAL_DEP_CODIGO2' THEN hdl_valor_del_campo END) AS dal_dep_codigo2
    FROM umdp.historico_datos_laborales
    WHERE hdl_fechaini <= TRUNC(SYSDATE)
      AND hdl_fechafin >= TRUNC(SYSDATE)
    GROUP BY hdl_dap_dni
)
SELECT
    x.dap_dni,
    afi.afi_nombre      AS dap_nombre,
    afi.afi_apellidos   AS dap_apellid,
    afi.afi_sexo        AS dap_sexo,
    x.dap_dir_codigo,
    h.dal_dep_codigo,
    h.dal_ced_codigo,
    h.dal_sed_codigo,
    h.dal_acm_codigo,
    h.dal_acp_codigo,
    h.dal_cat_codigo,
    h.dal_puf_codigo1,
    h.dal_puf_codigo2,
    h.dal_pll_codigo1,
    h.dal_pll_codigo2,
    h.dal_caa_codigo,
    h.dal_sap_codigo,
    h.dal_dep_codigo2
FROM umdp.datos_personales x
JOIN afiliaciones afi
       ON afi.afi_identificador = x.dap_dni
JOIN indice_documentos ind
       ON ind.ind_dni_personal = x.dap_dni
JOIN h
       ON h.hdl_dap_dni = ind.ind_dni_laboral
JOIN umdp.historico_datos_laborales h_sap
       ON h_sap.hdl_dap_dni = ind.ind_dni_laboral
      AND h_sap.hdl_tca_codigo = 'DAL_SAP_CODIGO'
      AND h_sap.hdl_fechaini <= TRUNC(SYSDATE)
      AND h_sap.hdl_fechafin >= TRUNC(SYSDATE)
JOIN umdp.situacion_admin_personals z
       ON z.sap_codigo = h_sap.hdl_valor_del_campo
      AND z.sap_activo = 'S';
 

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);    --2351
/

select  * from PERSONAL_ACTIVO_OPT where dal_dep_codigo='E098';

select  * from PERSONAL_ACTIVO where dal_dep_codigo='E098';


select  * from PERSONAL_ACTIVO_OPT where dal_cat_codigo='DAL12' order by DAP_APELLID;

select  * from PERSONAL_ACTIVO where dal_cat_codigo='DAL12' order by DAP_APELLID;
