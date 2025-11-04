CREATE TYPE direccion_t AS OBJECT (
   calle VARCHAR2(100),
   ciudad VARCHAR2(50),
   cp VARCHAR2(10)
);
/
CREATE TABLE clientes (
   id NUMBER PRIMARY KEY,
   nombre VARCHAR2(100),
   domicilio direccion_t
);
/
INSERT INTO clientes VALUES (
   1,
   'María Pérez',
   direccion_t('Av. Central 45', 'Madrid', '28010')
);
/
SELECT * FROM clientes c;
SELECT c.domicilio.ciudad FROM clientes c;
