CREATE TABLE facturas (
   id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   xml_data XMLTYPE
);

INSERT INTO facturas (xml_data)
VALUES (XMLTYPE('<factura><cliente>Ana</cliente><total>120.50</total></factura>'));

SELECT
   EXTRACTVALUE(xml_data, '/factura/cliente') AS cliente,
   EXTRACTVALUE(xml_data, '/factura/total') AS total
FROM facturas;

SELECT x.cliente, x.total
FROM facturas f,
     XMLTABLE('/factura'
       PASSING f.xml_data
       COLUMNS
          cliente VARCHAR2(50) PATH 'cliente',
          total VARCHAR2(50) PATH 'total'
     ) x;
