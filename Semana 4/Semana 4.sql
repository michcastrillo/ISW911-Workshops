
CREATE TABLE [dbo].[dim_tiempo](
	[id_tiempo] [int] IDENTITY(1,1) CONSTRAINT [pk_tiempo] PRIMARY KEY CLUSTERED ,
	[fecha] [date] NULL,
	[anio] [varchar](4) NULL,
	[mes] [varchar](2) NULL,
	[dia] [varchar](2) NULL,
	[dia_semana] [varchar](1) NULL,
	[nombre_mes] [varchar](20) NULL,
	[trimestre] [varchar](1) NULL,
	[semestre] [varchar](1) NULL,
	[mes_anio] [varchar](7) NULL,
	[periodo] [varchar](20) NULL)


CREATE TABLE [dbo].[dim_cliente](
	[id_cliente] [int] IDENTITY(1,1) CONSTRAINT [pk_cliente] PRIMARY KEY CLUSTERED,
	[bk_identificacion] [varchar](30) NULL,
	[nombre_cliente] [varchar](100) NULL,
	[pais] [varchar](50) NULL,
	[ciudad] [varchar](50) NULL,
	[estado] [varchar](50) NULL,
	[categoria_cliente] [varchar](50) NULL,
	[fecha_ingreso] [date] NULL )


CREATE TABLE [dbo].[dim_empleado](
	[id_empleado] [int] IDENTITY(1,1) CONSTRAINT [pk_empleado] PRIMARY KEY CLUSTERED ,
	[bk_identificacion] [varchar](30) NULL,
	[nombre_empleado] [varchar](100) NULL,
	[ciudad] [varchar](50) NULL,
	[pais] [varchar](50) NULL,
	[puesto] [varchar](50) NULL,
	[supervisor] [varchar](80) NULL) 


CREATE TABLE [dbo].[dim_producto](
	[id_producto] [int] IDENTITY(1,1) CONSTRAINT [pk_producto] PRIMARY KEY CLUSTERED ,
	[bk_identificacion] [varchar](20) NULL,
	[nombre_producto] [varchar](255) NULL,
	[proveedor] [varchar](100) NULL,
	[categoria] [varchar](50) NULL,
	[precio_unidad] [decimal](18, 2) NULL,
	[stock_actual] [int] NULL,
	[estado] [varchar](20) NULL)
 
  
CREATE TABLE [dbo].[fact_ventas](
	[id_venta] [int] IDENTITY(1,1) CONSTRAINT [pk_hventas] PRIMARY KEY CLUSTERED ,
	[id_cliente] [int] NULL,
	[id_producto] [int] NULL,
	[id_empleado] [int] NULL,
	[fecha] [date] NULL,
	[cantidad] [int] NULL,
	[monto] [decimal](18, 2) NULL,
	[descuento] [decimal](18, 2) NULL)
 
ALTER TABLE [dbo].[fact_ventas]  WITH CHECK ADD FOREIGN KEY([id_cliente])
REFERENCES [dbo].[dim_cliente] ([id_cliente]);

ALTER TABLE [dbo].[fact_ventas]  WITH CHECK ADD FOREIGN KEY([id_empleado])
REFERENCES [dbo].[dim_empleado] ([id_empleado]);

ALTER TABLE [dbo].[fact_ventas]  WITH CHECK ADD FOREIGN KEY([id_producto])
REFERENCES [dbo].[dim_producto] ([id_producto]);


--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

select *  from utndw.dbo.dim_cliente
select *  from utndw.dbo.dim_producto
select *  from utndw.dbo.dim_empleado
select *  from utndw.dbo.dim_tiempo
select *  from utndw.dbo.fact_ventas

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

--view on staging--

create  view v_cliente as 
select bc.bk_identificacion,
       upper(bc.nombre_cliente) cliente,
       upper(bc.pais) pais,
       upper(bc.ciudad) ciudad,
       iif(cliente is null, 'INACTIVO', 'ACTIVO') estado,
      ISNULL(
	  case
         when categoria = 1 then
          'SOBRESALIENTE'
         when categoria = 2 then
          'BUENO'
         when categoria = 3 then
          'REGULAR'
         when categoria = 4 then
          'NORMAL'
       end,'INACTIVO') categoria_cliente,
	   fecha_ingreso
  from (select concat(1, CUSTOMER_id) bk_identificacion,
               COMPANY_NAME nombre_cliente,
               COUNTRY pais,
               CITY ciudad
          from NORTHWIND.CUSTOMERS
        union all
        select concat(2, CODIGO_CLIENTE), NOMBRE_CLIENTE, PAIS, CIUDAD
          from JARDINERIA.CLIENTE) bc
  left join (select cliente, NTILE(4) OVER(ORDER BY total DESC) categoria,fecha_ingreso
               from (select concat(1, customer_id) cliente,
                            sum(UNIT_PRICE * QUANTITY) total, MIN(ORDER_DATE)  fecha_ingreso
                       from northwind.orders o
                      inner join northwind.order_details od
                         on o.order_id = od.order_id
						 group by  concat(1, customer_id) 
                     union all
                     select concat(2, codigo_cliente) customerid,
                          SUM(  PRECIO_UNIDAD * CANTIDAD) total, MIN(fecha_pedido) fecha_ingreso
                       from jardineria.pedido o
                      inner join jardineria.detalle_pedido od
                         on o.codigo_pedido = od.codigo_pedido
						 group by concat(2, codigo_cliente)
						 ) c) cc
    on bc.bk_identificacion = cc.cliente


--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

insert into utndw.dbo.dim_cliente 
select *  from v_cliente

select *  from utndw.dbo.dim_cliente 

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- view on staging--
create view v_productos as 
select cast(PRODUCT_ID as varchar(5)) identificador,
       upper(PRODUCT_NAME) producto,
       upper(s.company_name) proveedor,
       upper(c.category_name) categoria,
       UNIT_PRICE precio_unidad,
       UNITS_IN_STOCK cantida_stock,
       case
         when DISCONTINUED = 'N' then
          'ACTIVO'
         else
          'DESCONTINUADO'
       end estado
  from NORTHWIND.PRODUCTS pr
 inner join NORTHWIND.SUPPLIERS s
    on pr.supplier_id = s.supplier_id
 inner join NORTHWIND.CATEGORIES c
    on c.category_id = pr.category_id
union all
select 
 codigo_producto identificador,
       upper(nombre) producto,
       upper(proveedor) proveedor,
       upper(gama) categoria,
       precio_venta precio_unidad,
       CANTIDAD_EN_STOCK cantida_stock,
         'ACTIVO' estado
  from jardineria.producto




---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
select *  from v_productos

insert into utndw.dbo.dim_producto
select *  from v_productos

select *  from utndw.dbo.dim_producto
---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


create view v_empleado  as
	select concat(1,a.employee_id) codigo_empleado,
       upper(concat(a.firstname, ' ', a.lastname)) nombre,
       UPPER( a.CITY) ciudad,
       upper(a.COUNTRY) pais,
       upper(a.TITLE) puesto,
       upper(concat(B.firstname, ' ', B.lastname)) jefe
  from northwind.employees a
 left  JOIN northwind.employees B
    ON A.REPORTS_TO = B.EMPLOYEE_ID
union all
	select concat(2,e.codigo_empleado),
       upper(concat(e.nombre, ' ', e.apellido1,' ',e.apellido2)) nombre,
 
 UPPER( o.ciudad) ciudad,
       upper(o.pais) pais,
       upper(e.puesto) puesto,
       upper(concat(j.nombre, ' ', j.apellido1,' ',j.apellido2))  jefe
  from jardineria.empleado e
  inner join jardineria.oficina o
  on e.codigo_oficina=o.codigo_oficina
 left  JOIN jardineria.empleado j
    ON e.codigo_jefe = j.codigo_empleado
 
 ---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 select *  from  utndw.dbo.dim_empleado

 insert into  utndw.dbo.dim_empleado
 select *  from v_empleado

---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
insert into utndw.dbo.fact_ventas
select * from v_ventas

---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
create  view v_ventas as 

select concat(1, customer_id) cliente,
       concat(1, o.employee_id) empleado,
       cast(product_id as varchar(5)) producto,
       ORDER_DATE fecha,
       sum(QUANTITY) cantidad,
	   sum(UNIT_PRICE) monto,
	   sum(DISCOUNT) descuento
       
  from northwind.orders o
 inner join northwind.order_details od
    on o.order_id = od.order_id
 group by concat(1, customer_id),
          concat(1, o.employee_id),
          ORDER_DATE,
          product_id
union all
select concat(2, cl.codigo_cliente) cliente,
       concat(2, CODIGO_EMPLEADO_REP_VENTAS) empleado,
       codigo_producto producto,
       fecha_pedido,
       sum(CANTIDAD) cantidad,
	   sum(PRECIO_UNIDAD) monto,
	   0 descuento
  from jardineria.pedido o
 inner join jardineria.detalle_pedido od
    on o.codigo_pedido = od.codigo_pedido
  left join jardineria.cliente cl
    on o.codigo_cliente = cl.codigo_cliente
 group by concat(2, cl.codigo_cliente),
          concat(2, CODIGO_EMPLEADO_REP_VENTAS),
          fecha_pedido,
          codigo_producto
		  

---- llenar la tabla de tiempos

 select *  from utndw.dbo.dim_tiempo
  delete  from utndw.dbo.dim_tiempo
  
SET LANGUAGE Spanish;
DECLARE @fecha_inicio DATE;-- = '2020-01-01';
DECLARE @fecha_fin DATE ;--= '2023-12-31';

select @fecha_inicio= MIN(fecha),@fecha_fin= MAX(fecha)  from v_ventas

WHILE @fecha_inicio <= @fecha_fin
BEGIN
INSERT INTO utndw.dbo.dim_tiempo ( fecha, anio, mes, dia, dia_semana, nombre_mes, trimestre, semestre, mes_anio,periodo)
    VALUES ( @fecha_inicio, YEAR(@fecha_inicio), 
			MONTH(@fecha_inicio), 
			DAY(@fecha_inicio),
            DATEPART(WEEKDAY, @fecha_inicio), DATENAME(MONTH, @fecha_inicio), 
            DATEPART(QUARTER, @fecha_inicio), (MONTH(@fecha_inicio) + 2) / 3, 
            CONVERT(VARCHAR(7), @fecha_inicio, 126),
			concat(substring(CONVERT(VARCHAR(7), @fecha_inicio, 126),6,2),' - ',DATENAME(MONTH, @fecha_inicio)))

        SET @fecha_inicio = DATEADD(DAY, 1, @fecha_inicio);
END


-- Se carga la tabla de Hechos 

insert into  utndw.dbo.fact_ventas(id_cliente,id_producto,id_empleado,fecha,cantidad,monto,descuento)
select c.id_cliente,p.id_producto,e.id_empleado,v.fecha ,v.cantidad ,v.monto,v.descuento
from v_ventas v
inner join utndw.dbo.dim_cliente c
on v.cliente=c.bk_identificacion
inner join utndw.dbo.dim_empleado e
on v.empleado=e.bk_identificacion
inner join utndw.dbo.dim_producto p
on v.producto=p.bk_identificacion
inner join utndw.dbo.dim_tiempo t
on cast(v.fecha as date)=cast(t.fecha as date)

select *  from  utndw.dbo.fact_ventas

-- Por ultimo se hace el cubo y se conecta a excel 


---Parte 3


select * from openquery(ORACLE,'select * from categories')

select * from openquery(ORABD,'select * from cliente')



insert into jardineria.CLIENTE select * from openquery(ORACLE,'select * from CLIENTE');
insert into jardineria.DETALLE_PEDIDO select * from openquery(ORACLE,'select * from jardineria.DETALLE_PEDIDO');
insert into jardineria.EMPLEADO select * from openquery(ORACLE,'select * from jardineria.EMPLEADO');
insert into jardineria.GAMA_PRODUCTO select * from openquery(ORACLE,'select * from jardineria.GAMA_PRODUCTO');
insert into jardineria.OFICINA select * from openquery(ORACLE,'select * from jardineria.OFICINA');
insert into jardineria.PAGO select * from openquery(ORACLE,'select * from jardineria.PAGO');
insert into jardineria.PEDIDO select * from openquery(ORACLE,'select * from jardineria.PEDIDO');
insert into jardineria.PRODUCTO select * from openquery(ORACLE,'select * from jardineria.PRODUCTO');

insert into northwind.CATEGORIES select * from openquery(ORACLE,'select * from northwind.CATEGORIES');
insert into northwind.CUSTOMERS select * from openquery(ORACLE,'select * from northwind.CUSTOMERS');
insert into northwind.EMPLOYEES select * from openquery(ORACLE,'select * from northwind.EMPLOYEES');
insert into northwind.ORDER_DETAILS select * from openquery(ORACLE,'select * from northwind.ORDER_DETAILS');
insert into northwind.ORDERS select * from openquery(ORACLE,'select * from northwind.ORDERS');
insert into northwind.PRODUCTS select * from openquery(ORACLE,'select * from northwind.PRODUCTS');
insert into northwind.SHIPPERS select * from openquery(ORACLE,'select * from northwind.SHIPPERS');
insert into northwind.SUPPLIERS select * from openquery(ORACLE,'select * from northwind.SUPPLIERS');