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

/
--Tablas anidadas y colecciones
   
CREATE TYPE telefono_t AS OBJECT (
   tipo VARCHAR2(10),
   numero VARCHAR2(20)
);

CREATE TYPE lista_telefonos_t AS TABLE OF telefono_t;

CREATE TABLE personas (
   id NUMBER PRIMARY KEY,
   nombre VARCHAR2(100),
   telefonos lista_telefonos_t
) NESTED TABLE telefonos STORE AS telefonos_nt;

INSERT INTO personas VALUES (
   1,
   'Juan López',
   lista_telefonos_t(telefono_t('Móvil','600123123'), telefono_t('Fijo','911223344'))
);


sql
Copiar código
SELECT p.nombre, t.numero
FROM personas p, TABLE(p.telefonos) t;
