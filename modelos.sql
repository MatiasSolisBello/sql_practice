-- Lista todas las oficinas que tienen más de 5 empleados. 
-- Muestra el officeCode, la ciudad y el total de empleados.
select o.officecode, o.city, COUNT(*) as "total"
from offices o
INNER JOIN employees e ON o.officecode=e.officecode
group by o.officecode;


--Obtén los clientes que nunca han hecho un pedido. Muestra el customerName y la country.
select customername, country, salesrepemployeenumber from customers
where salesrepemployeenumber is null;


-- Encuentra los 3 productos más vendidos (por cantidad pedida) y 
-- muestra su productName junto al total de unidades vendidas.
select * from orders o; 


select p.productname 
from products p
INNER JOIN orderdetails od ON od.productcode=p.productcode;



--Lista los pedidos que tenían una requiredDate anterior al shippedDate. 
-- Muestra orderNumber, customerName y los días de retraso.
select o.ordernumber, o.requireddate, o.shippeddate, c.customername
from orders o
INNER JOIN customers c ON o.customernumber=c.customernumber
where o.requireddate < o.shippeddate;


--Calcula el monto total de ventas (quantityOrdered * priceEach) 
-- agrupado por country del cliente. Ordena de mayor a menor.
select * from orderdetails;


-- Encuentra los clientes que han gastado más de 100.000 USD en total en pedidos. 
-- Devuelve customerName, total gastado y país.
select * payments;


-- Muestra el nombre completo de cada empleado junto con el nombre completo 
-- de su jefe (reportsTo). Si no tiene jefe, indícalo como “CEO”.
select 
	e.firstname|| ' ' ||e.lastname as empleado, 
	coalesce(m.firstname|| ' ' ||m.lastname, 'CEO') as jefe
from employees e
left join employees m on e.reportsto = m.employeenumber;;



-- Lista todos los productos cuyo quantityInStock es menor que el promedio de 
-- stock de su línea (productLine).
select productname, quantityinstock, productline
from products;


-- Devuelve para cada oficina cuántos clientes están asociados a los 
-- empleados de esa oficina.


-- Encuentra el pedido con el valor total más alto y 
-- devuelve orderNumber, customerName y el total calculado.
select * from orders;

select * from orderdetails;

select * from products where productcode='S12_1666';

select * from payments;

insert  into orderdetails(
orderNumber,productCode,quantityOrdered,priceEach,orderLineNumber) values 
(10102,'S18_1342',39,95.55,2);


