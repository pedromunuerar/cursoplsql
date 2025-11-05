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
