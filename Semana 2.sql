------------------------------------ LAG AND LEAD

select producto, anio, ventas,
 lag(ventas) over(partition by producto order by anio asc) ventas_anteriores,
 ventas-lag(ventas) over(partition by producto order by anio asc) crecimiento,
 lead(ventas) over(partition by producto order by anio asc) ventas_posterior
 from 
 (
 Select pr.nombre producto, dp.cantidad * dp.precio_unidad ventas, extract(year from p.fecha_entrega) anio
 from pedido p 
 inner join detalle_pedido dp 
 on p.codigo_pedido = dp.codigo_pedido
 inner join producto pr
 on dp.codigo_producto = pr.codigo_producto
 where upper(p.estado) = 'ENTREGADO'
 )
 
 
-------------------------------------------- IF IN A SELECT

select cliente, ventas,nivel,
case when nivel = 1 then 'categoria a'
 when nivel = 2 then 'categoria b'
 when nivel = 3 then 'categoria c'
 when nivel = 4 then 'categoria d'
end categoria
from (
select cliente, ventas,
ntile(4) over(order by ventas desc) as nivel from(
select CL.nombre_cliente cliente, sum(dp.cantidad * dp.precio_unidad) ventas
from pedido p
inner join detalle_pedido dp 
on p.codigo_pedido = dp.codigo_pedido
inner join producto pr 
on dp.codigo_producto = pr.codigo_producto 
inner join cliente CL
on p.codigo_cliente = CL.codigo_cliente
where upper(p.estado) = 'ENTREGADO'
group by CL.nombre_cliente
))


----------------------------------------- CUBE METHOD 

select producto, anio, sum(ventas) ventas from(
select pr.nombre producto, dp.cantidad * dp.precio_unidad ventas, extract(year from p.fecha_entrega) anio, p.estado
from pedido p 
inner join detalle_pedido dp
on p.codigo_pedido = dp.codigo_pedido
inner join producto pr
on dp.codigo_producto = pr.codigo_producto)
group by cube(producto,anio,estado)
order by 2,1
------------------------------------LIST IN A SELECT 

SELECT DISTINCT CL.NOMBRE_CLIENTE CLIENTE,
LISTAGG(PR.NOMBRE,';') WITHIN GROUP(ORDER BY CL.NOMBRE_CLIENTE)
    OVER(PARTITION BY CL.NOMBRE_CLIENTE) PRODUCTOS
FROM PEDIDO P
INNER JOIN DETALLE_PEDIDO DP
ON P.CODIGO_PEDIDO=DP.CODIGO_PEDIDO
INNER JOIN PRODUCTO PR
ON DP.CODIGO_PRODUCTO=PR.CODIGO_PRODUCTO
INNER JOIN CLIENTE CL
ON P.CODIGO_CLIENTE=CL.CODIGO_CLIENTE
WHERE UPPER(P.ESTADO)='ENTREGADO'