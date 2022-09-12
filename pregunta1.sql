--CREACION DE LA BASE DE DATOS
create database BusinnessCaseAuna
use BusinnessCaseAuna;
--CREACION DE LAS TABLAS 
create table warehouses(
	warehouse nvarchar(10),
	latitude float,
	longitude float,
	primary key(warehouse)
);
create table transacciones(
	order_id int,
	latitude float,
	longitude float,
	month int,
	created datetime,
	delivery_fee int,
	warehouse nvarchar(10),
	primary key (order_id),
	foreign key(warehouse) references warehouses(warehouse)
);

-- FUNCION PARA EL CALCULO DE DISTANCIAS ENTRE EL WAREHOUSE Y UN PEDIDO DE ORDEN
create function formulaHaversine (@latitud1 float, @longitud1 float,
 @latitud2 float, @longitud2 float) returns float as 
 BEGIN
 declare @a float; 
 declare @radTierra float;
 declare @distancia float; 
 declare @latitud float;
 declare @longitud float;
 set @radTierra=6370
 set @latitud=@latitud1-@latitud2 
 set @longitud=@longitud1-@longitud2
 set @a=POWER(SIN(RADIANS (@latitud)/2),2)
		+COS(RADIANS(@latitud1))*COS(RADIANS(@latitud2))
		*POWER(SIN(RADIANS(@longitud)/2),2)
 set @distancia=@radTierra*2*ASIN(SQRT(@a))
 RETURN  @distancia
 END

 --QUERY PARA VER LAS DISTANCIAS ENTRE UN PROVEDOR Y UN WAREHOUSE
 select T.order_id, W.warehouse, T.delivery_fee, created,
 dbo.formulaHaversine(T.latitude, T.longitude, W.latitude, W.latitude)
 as distancia  from transacciones T 
 left join warehouse W on T.warehouse=W.warehouse;
 

 -------------------------------------------------------
--Query para el analisis de gastos de delivery por mes
 select  case MONTH(T.created) 
 when 9 then 'SEPTIEMBRE'
 when 10 then 'OCTUBRE'
 when 11 then 'NOVIEMBRE' end  as MES,
 sum(T.delivery_fee) as GASTOS_EN_DELIVERY, 
 count(distinct T.order_id) AS NUMERO_PEDIDOS 
 from transacciones T inner join warehouse W on T.warehouse=W.warehouse
 group by MONTH(T.created) order by GASTOS_EN_DELIVERY desc;

 -------------------------------------------------------
--QUERY PARA EL ANALISIS DE GASTOS DE DELIVERY POR WAREHOUSE , MES Y DISTANCIA
--ORDENADO POR WAREHOUSE
 select W.warehouse, sum(T.delivery_fee) as GASTOS_EN_DELIVERY, 
 count(distinct T.order_id) AS NUMERO_PEDIDOS,
 case MONTH(T.created) 
 when 9 then 'SEPTIEMBRE'
 when 10 then 'OCTUBRE'
 when 11 then 'NOVIEMBRE'
 end  as MES
 from transacciones T inner join warehouse W on T.warehouse=W.warehouse
 group by MONTH(T.created) , W.warehouse
 order by W.warehouse;


--QUERY PARA EL ANALISIS DE GASTOS DE DELIVERY POR WAREHOUSE , MES Y DISTANCIA

 select W.warehouse, sum(T.delivery_fee) as GASTOS_EN_DELIVERY, 
 count(distinct T.order_id) AS NUMERO_PEDIDOS,
 case MONTH(T.created) 
 when 9 then 'SEPTIEMBRE'
 when 10 then 'OCTUBRE'
 when 11 then 'NOVIEMBRE'
 end  as MES,
 AVG(dbo.formulaHaversine(W.latitude,W.longitude,T.latitude,T.longitude))
 as PROM_DISTANCIA
 from transacciones T inner join warehouse W on T.warehouse=W.warehouse
 group by MONTH(T.created) , W.warehouse
 order by GASTOS_EN_DELIVERY desc;


 --ANALISIS DEL PROMEDIO EN KILOMETROS, GASTOS DE DELIVERY POR CADA WAREHOUSE

select W.warehouse as WAREHOUSE, 
AVG(dbo.formulaHaversine(W.latitude,W.longitude,T.latitude,T.longitude))
AS PROM_DISTANCIA,
COUNT(distinct order_id) AS NUMERO_PEDIDOS,
SUM(T.delivery_fee) AS GASTOS_POR_DELIVERY
from warehouse AS W INNER JOIN transacciones AS T
on W.warehouse=T.warehouse
group by W.warehouse order by PROM_DISTANCIA desc;

-- consulta para detectar que almacen es mas cercano a la orden 

declare @latitud float
declare @lontitud float
set @latitud=9.5;
set @lontitud=2.10;

select
round(dbo.formulaHaversine(@latitud,@lontitud,-5.2,25.5),2,1)
as ALMACEN_J ,
round(dbo.formulaHaversine(@latitud,@lontitud,-54.2,5.5),2,1)
as ALMACEN_I
