-------Ejercicio 1.1---------
select codigo_oficina,ciudad from oficina
-------Ejercicio 1.2---------
update cliente set limite_credito = limite_credito + (limite_credito*0.25)
where limite_credito >= 12000
and ciudad = 'Miami'

----------Trabajo en clase------
--Nombre cliente, monto de la compra y vendedor
select c.nombre_cliente,v.monto ,e.nombre representante from cliente c
inner join 
(select p.codigo_cliente, sum(dp.cantidad)*sum(dp.precio_unidad) monto   from pedido p
inner join detalle_pedido dp
on p.codigo_pedido=dp.codigo_pedido
group by p.codigo_cliente) v
on c.codigo_cliente=v.codigo_cliente
left join empleado e
on c.codigo_empleado_rep_ventas=e.codigo_empleado

--Pedidos por estado
select *  from (
select pr.nombre producto,p.estado,dp.cantidad,dp.precio_unidad  from pedido p
inner join detalle_pedido dp
on p.codigo_pedido=dp.codigo_pedido
inner join producto pr
on dp.codigo_producto=pr.codigo_producto
) pivot (sum(cantidad) cantidad, sum(precio_unidad)  precio 
for estado in ('Entregado' entregado,'Rechazado' rechazado,'Pendiente' pendiente ) )