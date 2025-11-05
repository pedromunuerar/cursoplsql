CREATE TABLE ventas (
   id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   precio_unitario NUMBER(10,2),
   cantidad NUMBER,
   total NUMBER GENERATED ALWAYS AS (precio_unitario * cantidad) VIRTUAL
);

begin
FOR i IN 1..100000 LOOP
insert into ventas (precio_unitario, cantidad) values (4,5);
insert into ventas (precio_unitario, cantidad) values (4,5);
insert into ventas (precio_unitario, cantidad) values (3,5);
insert into ventas (precio_unitario, cantidad) values (1,5);
insert into ventas (precio_unitario, cantidad) values (4,50);
insert into ventas (precio_unitario, cantidad) values (4,5);
insert into ventas (precio_unitario, cantidad) values (4,5);
insert into ventas (precio_unitario, cantidad) values (3,5);
insert into ventas (precio_unitario, cantidad) values (1,5);
insert into ventas (precio_unitario, cantidad) values (4,50);
end loop;
end;
/


select * from ventas where total=5 order by 1 desc;
select sum(precio_unitario*cantidad), count(*) from ventas where total=5 order by 1 desc;

CREATE INDEX idx_total ON ventas (total);

select sum(precio_unitario*cantidad), count(*) from ventas where total=5 order by 1 desc;

select sum(precio_unitario*cantidad), count(*) from ventas where 1+(precio_unitario*cantidad)-1=5 order by 1 desc;

/
CREATE TABLE ventas_complejo (
   id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   precio_unitario NUMBER(10,2),
   cantidad NUMBER,
   total NUMBER GENERATED ALWAYS AS (
       precio_unitario * cantidad * 
       (1 + SIN(precio_unitario) + COS(cantidad) + TAN(precio_unitario * 0.01)) *
       EXP(MOD(precio_unitario, 10) * 0.1) *
       LN(ABS(precio_unitario) + 1) *
       POWER(1.1, SQRT(cantidad))
   ) VIRTUAL
);

begin
FOR i IN 1..10000 LOOP
insert into ventas_complejo (precio_unitario, cantidad) values (4,5);
insert into ventas_complejo (precio_unitario, cantidad) values (4,5);
insert into ventas_complejo (precio_unitario, cantidad) values (3,5);
insert into ventas_complejo (precio_unitario, cantidad) values (1,5);
insert into ventas_complejo (precio_unitario, cantidad) values (4,50);
insert into ventas_complejo (precio_unitario, cantidad) values (4,5);
insert into ventas_complejo (precio_unitario, cantidad) values (4,5);
insert into ventas_complejo (precio_unitario, cantidad) values (3,5);
insert into ventas_complejo (precio_unitario, cantidad) values (1,5);
insert into ventas_complejo (precio_unitario, cantidad) values (4,50);
end loop;
end;
/

select * from ventas_complejo order by total; --26s

CREATE INDEX idx_total_complejo ON ventas_complejo (total);

select * from ventas_complejo order by total; --26s
/

-- Crear función determinista
CREATE OR REPLACE FUNCTION calcular_total_complejo(
    p_precio NUMBER, 
    p_cantidad NUMBER
) RETURN NUMBER DETERMINISTIC
IS
BEGIN
    RETURN CASE 
        WHEN p_precio > 0 AND p_cantidad > 0 THEN
            (p_precio * p_cantidad) *
            (1 + 
                SIN(p_precio * 0.01) + 
                COS(p_cantidad * 0.01) +
                TAN((p_precio + p_cantidad) * 0.001) +
                SIN(COS(p_precio * 0.1)) +
                COS(SIN(p_cantidad * 0.1))
            ) *
            EXP(MOD(p_precio * p_cantidad, 50) * 0.01) *
            LN(ABS(p_precio * p_cantidad) + 100) *
            POWER(1.01, SQRT(p_precio) + SQRT(p_cantidad)) *
            (1 + ABS(SIN(p_precio * p_cantidad * 0.0001)))
        ELSE 0
    END;
END;
/

-- Crear índice basado en función
CREATE INDEX idx_func_total ON ventas_complejo(
    calcular_total_complejo(precio_unitario, cantidad)
);

-- Consulta usando la función en el ORDER BY
SELECT * FROM ventas_complejo 
ORDER BY calcular_total_complejo(precio_unitario, cantidad);
