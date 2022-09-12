--Creacion de la vista Productos_Categorias
create view Productos_Categorias
AS
	SELECT 
	macro.name as Macro_category,
	sub.name as Sub_category,
	micro.name as Micro_category,
	P.product_id,V.sku as SKU,P.name,P.price as PRICE
	FROM Product_product as P INNER JOIN Product_variant AS V
	ON P.product_id=V.product_id
	INNER JOIN Product_category as micro
	ON P.Category_id=micro.Id
	INNER JOIN Product_category as sub 
	ON micro.parent_id=sub.id
	INNER JOIN Product_category aS macro ON
	sub.parent_id=macro.id;
    
--Consulta para ver el SKU mas caro de cada categoria
select 
Macro_Category,
Sub_category,
SKU, MAX(price) as PRECIO from Productos_Categorias
group by Macro_Category,Sub_category, SKU
order by PRECIO desc, SKU asc;


