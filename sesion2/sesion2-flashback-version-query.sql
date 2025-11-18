DROP TABLE productos_demo PURGE;

CREATE TABLE productos_demo (
    id NUMBER PRIMARY KEY,
    producto VARCHAR2(40),
    stock NUMBER
);
2️⃣ Insertar registros
sql
Copiar código
INSERT INTO productos_demo VALUES (1, 'Tornillos', 100);
INSERT INTO productos_demo VALUES (2, 'Tuercas',   150);

COMMIT;
3️⃣ Realizar cambios con pausas para diferenciar en UNDO
sql
Copiar código
BEGIN DBMS_LOCK.SLEEP(1); END;
UPDATE productos_demo SET stock = stock + 50 WHERE id = 1;
COMMIT;

BEGIN DBMS_LOCK.SLEEP(1); END;
UPDATE productos_demo SET stock = stock - 20 WHERE id = 1;
COMMIT;

BEGIN DBMS_LOCK.SLEEP(1); END;
DELETE FROM productos_demo WHERE id = 2;
COMMIT;
4️⃣ Ver historial de todas las versiones
sql
Copiar código
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
🔍 Interpretación
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

5️⃣ Ver historial solo de un ID concreto
sql
Copiar código
SELECT versions_operation, versions_starttime,
       id, producto, stock
FROM productos_demo
VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE
WHERE id = 1
ORDER BY versions_starttime;
6️⃣ Ver quién modificó la fila (correlando XID)
sql
Copiar código
SELECT t.xidusn, t.xidslot, t.xidsqn, s.username
FROM v$transaction t
JOIN v$session s ON t.ses_addr = s.saddr
WHERE t.xid = HEXTORAW('<PON AQUÍ EL XID de versions_xid>');
