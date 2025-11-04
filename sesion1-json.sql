CREATE TABLE pedidos (
   id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   cliente VARCHAR2(100),
   datos CLOB CONSTRAINT chk_json CHECK (datos IS JSON)
);


INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Cámara","precio":250.0}],"envio":"24h"}');
INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Perfume","precio":50.0}],"envio":"24h"}');


SELECT
   JSON_VALUE(datos, '$.items[0].producto') AS producto,
   JSON_VALUE(datos, '$.items[0].precio') AS precio
FROM pedidos
where JSON_VALUE(datos, '$.items[0].precio')=50;
