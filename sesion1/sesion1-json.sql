CREATE TABLE pedidos (
   id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   cliente VARCHAR2(100),
   datos CLOB CONSTRAINT chk_json CHECK (datos IS JSON)
);


INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Cámara","precio":250.0}],"envio":"24h"}');
INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Perfume","precio":50.0}],"envio":"24h"}');
INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Cámara","precio":250.0}],"envio":"24h"}');
INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Perfume","precio":50.0}],"envio":"24h"}');
INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Cámara","precio":250.0}],"envio":"24h"}');
INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Perfume","precio":50.0}],"envio":"24h"}');
INSERT INTO pedidos (cliente, datos) VALUES 
('María', '{"items":[{"producto":"Laptop","precio":800.0},{"producto":"Mouse","precio":25.0}],"envio":"48h"}');
INSERT INTO pedidos (cliente, datos) VALUES 
('Juan', '{"items":[{"producto":"Libro","precio":15.5}],"envio":"24h","descuento":10}');
INSERT INTO pedidos (cliente, datos) VALUES 
('Laura', '{"items":[{"producto":"Auriculares","precio":75.0},{"producto":"Cargador","precio":30.0}],"envio":"72h"}');


SELECT
   JSON_VALUE(datos, '$.items[0].producto') AS producto,
   JSON_VALUE(datos, '$.items[0].precio') AS precio
FROM pedidos
where JSON_VALUE(datos, '$.items[0].precio')=50;

--Si no tiene precio, se trata como null
INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Cámara"}],"envio":"24h"}');
INSERT INTO pedidos (cliente, datos)
VALUES ('Carlos', '{"items":[{"producto":"Perfume"}],"envio":"24h"}');

--JSON_VALUE Si no existe tambien
SELECT
   JSON_VALUE(datos, '$.items[9].producto') AS producto,
   JSON_VALUE(datos, '$.items[0].precio') AS precio
FROM pedidos
where JSON_VALUE(datos, '$.items[0].precio') is null;


-- JSON_QUERY Extraer todo el array de items
SELECT 
    cliente,
    JSON_QUERY(datos, '$.items') as items_completos,
    JSON_QUERY(datos, '$.items[0]') as primer_item
FROM pedidos;

-- JSON_QUERY Extraer items con formato específico
SELECT 
    cliente,
    JSON_QUERY(datos, '$.items' WITH ARRAY WRAPPER) as items_array
FROM pedidos;

-- JSON_EXISTS Pedidos que contienen el producto "Cámara"
SELECT cliente, datos
FROM pedidos
WHERE JSON_EXISTS(datos, '$.items?(@.producto == "Cámara")');

--JSON_TABLE Convertir los items JSON en filas de tabla
SELECT p.cliente, jt.*
FROM pedidos p,
JSON_TABLE(p.datos, '$.items[*]'
    COLUMNS (
        producto VARCHAR2(50) PATH '$.producto',
        precio NUMBER PATH '$.precio',
        indice FOR ORDINALITY
    )
) jt;

-- JSON_TABLE Ejemplo más complejo con múltiples campos
SELECT p.id, p.cliente, jt.*
FROM pedidos p,
JSON_TABLE(p.datos, '$'
    COLUMNS (
        tipo_envio VARCHAR2(20) PATH '$.envio',
        NESTED PATH '$.items[*]'
        COLUMNS (
            producto VARCHAR2(50) PATH '$.producto',
            precio NUMBER PATH '$.precio'
        )
    )
) jt;

/*Sintaxis Básica de JSON Path*/
1. Referenciar elementos
sql
-- $ = raíz del documento
JSON_VALUE(datos, '$')                    -- Todo el documento
JSON_VALUE(datos, '$.envio')              -- Campo "envio" en raíz
JSON_VALUE(datos, '$.items')              -- Array "items"
2. Acceder a objetos y arrays
sql
-- Notación de punto para objetos
JSON_VALUE(datos, '$.cliente.nombre')     -- Objetos anidados
JSON_VALUE(datos, '$.direccion.ciudad')   -- Campos anidados

-- Notación de corchetes para arrays
JSON_VALUE(datos, '$.items[0]')           -- Primer elemento del array
JSON_VALUE(datos, '$.items[1]')           -- Segundo elemento
JSON_VALUE(datos, '$.items[last]')        -- Último elemento
JSON_VALUE(datos, '$.items[0].producto')  -- Campo dentro del primer elemento
3. Wildcards y múltiples elementos
sql
-- * = cualquier elemento
JSON_QUERY(datos, '$.items[*]')           -- Todos los elementos del array
JSON_QUERY(datos, '$.items[*].producto')  -- Todos los productos
JSON_VALUE(datos, '$.items[0].*')         -- Todos los campos del primer item

-- Rangos
JSON_QUERY(datos, '$.items[0 to 2]')      -- Elementos 0, 1 y 2
