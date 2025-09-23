-- 1.- Lista todas las oficinas que tienen más de 5 empleados. 
-- Muestra el officeCode, la ciudad y el total de empleados.
select o.officecode, o.city, COUNT(*) as "total"
from offices o
INNER JOIN employees e ON o.officecode=e.officecode
group by o.officecode
having COUNT(*) >= 5;



-- 2.- Obtén los clientes que nunca han hecho un pedido. 
-- Muestra el customerName y la country.
select c.customername, c.country
from customers c
left join orders o on c.customernumber = o.customernumber
where o.ordernumber is null;



-- 3.- Encuentra los 3 productos más vendidos (por cantidad pedida) y 
-- muestra su productName junto al total de unidades vendidas.
select p.productname, sum(od.quantityordered) as total_vendido
from products p
join orderdetails od on p.productcode = od.productcode
group by p.productname
order by total_vendido desc
limit 3;



-- 4.- Lista los pedidos que tenían una requiredDate anterior al shippedDate. 
-- Muestra orderNumber, customerName y los días de retraso. DATEDIFF
select o.ordernumber, c.customername,
o.shippeddate - o.requireddate as "dias de retraso"
from orders o
INNER JOIN customers c ON o.customernumber=c.customernumber
where o.requireddate < o.shippeddate;



-- 5.- Calcula el monto total de ventas (quantityOrdered * priceEach) 
-- agrupado por country del cliente. Ordena de mayor a menor.
select
ROUND(SUM(od.quantityOrdered * od.priceEach)) as "total", 
c.country
from orderdetails od
join orders o on o.ordernumber = od.ordernumber
join customers c on c.customernumber = o.customernumber
group by c.country
order by total DESC;



-- 6.- Encuentra los clientes que han gastado más de 
-- 100.000 USD en total en pedidos. 
-- Devuelve customerName, total gastado y país.
select c.customername as "customer name", 
ROUND(SUM(quantityOrdered * priceEach), 2) as "total_gastado", 
c.country
from customers c
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
where ROUND(quantityOrdered * priceEach) >= 100000
group by c.customername, c.country
having sum(od.quantityOrdered * od.priceEach) > 100000
order by total_gastado desc;



-- 7.- Muestra el nombre completo de cada empleado junto con el nombre completo 
-- de su jefe (reportsTo). Si no tiene jefe, indícalo como “CEO”.
select 
	concat(e.firstname, ' ', e.lastname) as empleado,
	coalesce(concat(m.firstname, ' ', m.lastname), 'CEO') as jefe
from employees e
left join employees m on e.reportsto = m.employeenumber;



-- 8.- Lista todos los productos cuyo quantityInStock es menor que 
-- el promedio de stock de su línea (productLine).
select p.productName, p.productLine, p.quantityInStock, t.promedio
from products p
join (
    select productLine, avg(quantityInStock) as promedio
    from products
    group by productLine
) t on p.productLine = t.productLine
where p.quantityInStock < t.promedio;



-- 9.- Devuelve para cada oficina cuántos clientes están asociados a los 
-- empleados de esa oficina.
select o.city, COUNT(*) as "clientes asociados"
from offices o
INNER JOIN employees e ON o.officecode=e.officecode
INNER JOIN customers c ON c.salesrepemployeenumber=e.employeenumber
group by o.city



-- 10.- Encuentra el pedido con el valor total más alto y 
-- devuelve orderNumber, customerName y el total calculado.
select o.orderNumber, c.customerName,
       sum(od.quantityOrdered * od.priceEach) as total_gastado
from orderdetails od
join orders o on o.orderNumber = od.orderNumber
join customers c on c.customerNumber = o.customerNumber
group by o.orderNumber, c.customerName
order by total_gastado desc
limit 1;


-- ---------------------------
--        SUBCONSULTAS
-- ---------------------------
-- 1.- Clientes con más pedidos que el promedio
-- Lista los clientes cuyo número de pedidos es mayor que 
-- el promedio de pedidos realizados por todos los clientes.
select *
from (
    select customerNumber, count(*) as total_pedidos
	from orders
	group by customerNumber
) as t
having ROUND(avg(total_pedidos)) >= total_pedidos;



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
	round(od.quantityOrdered * od.priceEach) as valor_total, 
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











