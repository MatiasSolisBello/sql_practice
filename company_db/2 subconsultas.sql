-- ---------------------------
--        SUBCONSULTAS
-- ---------------------------
-- PUEDES HACERLAS EN SELECT, FROM, WHERE, HAVING O JOIN


-- 1.- Clientes con más pedidos que el promedio
-- Lista los clientes cuyo número de pedidos es mayor que 
-- el promedio de pedidos realizados por todos los clientes.

-- Promedio de pedidos realizados por todos los clientes
select customerNumber, total_pedidos
from (
    select customerNumber, count(*) as total_pedidos
    from orders
    group by customerNumber
) as t
where total_pedidos > (
    select avg(total_pedidos)
    from (
        select customerNumber, count(*) as total_pedidos
        from orders
        group by customerNumber
    ) as x
);




-- 2.- Productos bajo el promedio de stock de su línea
-- Muestra los productos cuyo quantityInStock es menor que el 
-- promedio de stock de su respectiva línea (productLine). 
-- Hazlo usando una subconsulta correlacionada.
select p.productName, p.productLine, p.quantityInStock, t.promedio
from products p
join (
    select productLine, avg(quantityInStock) as promedio
    from products
    group by productLine
) t on p.productLine = t.productLine
where p.quantityInStock < t.promedio;



-- 3.- Pedidos más grandes que el promedio
-- Obtén los pedidos cuyo valor total (od.quantityOrdered * od.priceEach) es mayor que 
-- el valor promedio de todos los pedidos.
select 
	od.ordernumber, 
	round(sum(od.quantityOrdered * od.priceEach)) as valor_total, 
	t.promedio
from orderdetails od
join (
	select round(avg(od.quantityOrdered * od.priceEach)) as promedio
	from orderdetails od
) as t
having valor_total > promedio
order by valor_total desc;



-- 4.- Clientes top 5 en gasto total
-- Encuentra los 5 clientes que más dinero han gastado en total. 
-- Usa una subconsulta para calcular el gasto por cliente y luego filtra.
select 
	customerName as cliente,
	round(sum(od.quantityOrdered * od.priceEach)) as gasto
from customers c 
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by customerName
order by gasto desc
limit 5;



-- 5.- Productos nunca pedidos
-- Muestra los productos que no aparecen en ningún orderdetails. 
-- Hazlo con NOT IN y subconsulta.











