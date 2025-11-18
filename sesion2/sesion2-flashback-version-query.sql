DROP TABLE productos_demo PURGE;

CREATE TABLE productos_demo (
    id NUMBER PRIMARY KEY,
    producto VARCHAR2(40),
    stock NUMBER
);
--2 Insertar registros


INSERT INTO productos_demo VALUES (1, 'Tornillos', 100);
INSERT INTO productos_demo VALUES (2, 'Tuercas',   150);

COMMIT;
--3 Realizar cambios con pausas para diferenciar en UNDO
/

UPDATE productos_demo SET stock = stock + 50 WHERE id = 1;
COMMIT;

/
UPDATE productos_demo SET stock = stock - 20 WHERE id = 1;
COMMIT;
/

DELETE FROM productos_demo WHERE id = 2;
COMMIT;
--4 Ver historial de todas las versiones
SELECT
    versions_startscn,
    versions_endscn,
    versions_starttime,
    versions_endtime,
    versions_xid,
    versions_operation,
    id,
    producto,
    stock
FROM productos_demo
VERSIONS BETWEEN SCN MINVALUE AND MAXVALUE
ORDER BY id, versions_starttime;
/
--Interpretación
VERSIONS_OPERATION valores:

Valor	Significado
I	Insert
U	Update
D	Delete

Puedes ver:

El valor anterior y el nuevo en cada update
Las veces que una fila fue modificada
Quién lo hizo (v$transaction + xid)
Cuándo ocurrió
Valores antes de borrarse (DELETE)

--5 Ver historial solo de un ID concreto

SELECT versions_operation, versions_starttime,
       id, producto, stock
FROM productos_demo
VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE
WHERE id = 1
ORDER BY versions_starttime;
/

--6 Ver quién modificó la fila (correlando XID)

SELECT t.xidusn, t.xidslot, t.xidsqn, s.username
FROM v$transaction t
JOIN v$session s ON t.ses_addr = s.saddr
WHERE t.xid = '01001900D5A14A00' -- HEXTORAW('01001900D5A14A00');
