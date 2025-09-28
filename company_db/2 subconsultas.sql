-- ---------------------------
--        SUBCONSULTAS
-- ---------------------------

-- 1.- Clientes con más pedidos que el promedio
-- Lista los clientes cuyo número de pedidos es mayor que 
-- el promedio de pedidos realizados por todos los clientes.

	-- Cuenta los pedidos agrupados por n° de cliente
	select COUNT(*) as numero_pedidos from orders
	group by customerNumber 
	
	
	-- Promedio de pedidos agrupados por n° de cliente
	-- (subconsulta en la cláusula FROM, 
	-- el resultado de esa subconsulta se comporta como una tabla temporal)
	select round(avg(numero_pedidos)) as promedio
	from (
		select COUNT(*) as numero_pedidos from orders 
		group by customerNumber
	) as promedio_table; 
	
	-- SOLUCION N° 1
	select 
		o.customerNumber as numero, 
		concat(c.contactFirstName,' ',c.contactLastName) as nombre,
		COUNT(*) as numero_pedidos
	from orders o 
	join customers c on c.customerNumber = o.customerNumber
	group by o.customerNumber
	having numero_pedidos >= (
		select round(avg(numero_pedidos)) as promedio
		from (
			select COUNT(*) as numero_pedidos from orders 
			group by customerNumber
		) as promedio_table
	) order by numero_pedidos desc;
	
	
	
-- 	2.- Productos bajo el promedio de stock de su línea
-- Muestra los productos cuyo quantityInStock es 
-- menor que el promedio de stock de su respectiva línea (productLine). 
-- Hazlo usando una subconsulta correlacionada.
	
	-- promedio de stock de su respectiva línea (productLine)
	select productLine, ROUND(avg(quantityInStock)) as promedio_stock
    from products
    group by productLine
	
    -- SOLUCION N° 2
    select p1.productname from products p1 
    where p1.quantityInStock < (
    	select ROUND(avg(p2.quantityInStock)) as promedio_stock
	    from products p2
	    where p1.productLine = p2.productLine
	    group by p2.productLine
    )
    
    
	
-- 3.- Pedidos más grandes que el promedio
-- Obtén los pedidos cuyo valor total (cantidad × precio) es 
-- mayor que el valor promedio de todos los pedidos.	

	-- valor promedio de todos los pedidos
    select round(avg(od.quantityOrdered * od.priceEach)) as promedio
    from orderdetails od
    
    
    -- SOLUCION N° 3
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
	
    -- calcular el gasto por cliente
    select 
    	o.customerNumber, 
    	round(sum(od.quantityOrdered * od.priceEach)) as valor_total
    from orderdetails od
    join orders o on o.orderNumber = od.orderNumber 
    group by o.customerNumber
    
    -- SOLUCION N° 4
    select 
	    c.customerName,
	    t.valor_total
	from (
	    select 
	        o.customerNumber, 
	        round(sum(od.quantityOrdered * od.priceEach)) as valor_total
	    from orderdetails od
	    join orders o on o.orderNumber = od.orderNumber 
	    group by o.customerNumber
	) as t
	join customers c on c.customerNumber = t.customerNumber
	order by t.valor_total desc
	limit 5;
    
	
	
-- 5.- 	Productos nunca pedidos
-- Muestra los productos que no aparecen en ningún orderdetails. 
-- Hazlo con NOT IN y subconsulta.
    
    -- Codigos de productos en orderdetails que no son NULL
    SELECT DISTINCT od.productCode
    FROM orderdetails od
	WHERE od.productCode IS NOT NULL
    
    -- SOLUCION N° 5 
    SELECT p.productCode, p.productName
	FROM products p
	WHERE p.productCode NOT IN (
	    SELECT DISTINCT od.productCode
	    FROM orderdetails od
    	WHERE od.productCode IS NOT NULL
	);
    
    select * from orderdetails o where o.productCode = 'S18_3233'


    
-- 6.- Primer pedido de cada cliente
--  Lista el customerName junto con la fecha de su primer pedido, 
-- usando una subconsulta que calcule la fecha mínima por cliente.   
    
    -- calcule la fecha mínima por cliente
    select o.customerNumber, MIN(o.orderdate) as fecha
    from orders o
    group by o.customerNumber
    order by o.customerNumber
    
    
    -- select * from orders where customerNumber = 177
    
    -- SOLUCION N° 6 
    select c.customerName, t.fecha
    from (
    	select 
    		o.customerNumber, 
    		MIN(o.orderdate) as fecha
	    from orders o
	    group by o.customerNumber
    ) as t
    join customers c on c.customerNumber = t.customerNumber;
    
    
   
-- 7.- Empleados con más clientes que el promedio
-- Encuentra los empleados que tienen asignados más clientes que el 
-- promedio de clientes asignados por empleado.   

    -- promedio de clientes asignados por empleado:
    
    
    
    
    
    
    
    
    