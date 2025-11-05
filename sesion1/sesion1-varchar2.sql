CREATE TABLE prueba_codificacion (
    col_varchar2 VARCHAR2(3),   -- Usa la codificación de la BD
    col_nvarchar2 NVARCHAR2(3), -- Usa AL16UTF16 (siempre Unicode)
    col_char CHAR(3),           -- Como VARCHAR2 pero con padding
    col_nchar NCHAR(3)          -- Como NVARCHAR2 pero con padding
);

insert into prueba_codificacion(col_varchar2) values ('aaa');
insert into prueba_codificacion(col_varchar2) values ('ááá');

insert into prueba_codificacion(col_nvarchar2) values ('aaa');
insert into prueba_codificacion(col_nvarchar2) values ('ááá');

insert into prueba_codificacion(col_char) values ('aaa');
insert into prueba_codificacion(col_char) values ('ááá');

insert into prueba_codificacion(col_nchar) values ('aaa');
insert into prueba_codificacion(col_nchar) values ('ááá');
