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

    -- Cuenta los clientes agrupados por n° de empleado
    select 
    	salesRepEmployeeNumber as empleado_numero, 
    	COUNT(*) as clientes 
    from customers
    where salesRepEmployeeNumber is not null
	group by salesRepEmployeeNumber
	
	select * from customers c where salesRepEmployeeNumber = 1501
	
	
	-- promedio de clientes asignados por empleado:
	select round(avg(clientes)) as promedio
	from (
		select 
    	salesRepEmployeeNumber as empleado_numero, 
	    	COUNT(*) as clientes 
	    from customers
	    where salesRepEmployeeNumber is not null
		group by salesRepEmployeeNumber
	) as promedio_table;
	
	
	-- SOLUCION N° 7
	select 
		e.employeenumber as numero_empleado,
		concat(e.firstName,' ',e.lastName) as nombre_empleado,
		COUNT(*) as clientes
	from employees e
	join customers c on e.employeeNumber = c.salesRepEmployeeNumber 
	group by salesRepEmployeeNumber
	having clientes >= (
		select round(avg(clientes)) as promedio
		from (
			select 
	    	salesRepEmployeeNumber as empleado_numero, 
		    	COUNT(*) as clientes 
		    from customers
		    where salesRepEmployeeNumber is not null
			group by salesRepEmployeeNumber
		) as promedio_table
	) order by clientes desc;
    
    
    
    
-- 8.- Clientes con pedidos en varios años
-- Lista los clientes que han hecho pedidos en más de un año distinto, 
-- usando una subconsulta que cuente los años.   
    
	-- Conteo de años agrupado por numero de cliente
	select 
		customernumber as numero_cliente,
		COUNT(DISTINCT YEAR(o.orderDate)) as num_años
	from orders o
	group by numero_cliente
	order by numero_cliente
	
	-- SOLUCION N° 8
	select
		t.numero_cliente,
		concat(c.contactFirstName,' ',c.contactLastName) as nombre,
		t.num_años
	from (
	    select 
	    	o.customernumber as numero_cliente, 
	    	COUNT(DISTINCT YEAR(o.orderDate)) as num_años
	    from orders o
	    group by numero_cliente
		order by numero_cliente
	) as t
	join customers c on t.numero_cliente = c.customerNumber
	where num_años > 1
	order by num_años desc

    
    
-- 9.- Pedidos con más productos que el promedio
-- Muestra los pedidos que tienen más líneas en orderdetails que el 
-- promedio de líneas de todos los pedidos.	
	
	-- Conteo de lineas agrupados por numero de pedido
	select 
		ordernumber as numero_pedido, 
		count(*) as conteo 
	from orderdetails o
	group by ordernumber
	
	-- testing
	select * from orderdetails where orderNumber = 10287
	
	-- promedio de líneas de todos los pedidos
	select round(avg(conteo)) as promedio
	from (
		select 
			ordernumber as numero_pedido, 
			count(*) as conteo 
		from orderdetails o
		group by ordernumber
	) as t;
	
	
	-- SOLUCION N°  9
	select 
		ordernumber as numero_pedido, 
		o.priceEach, o.quantityOrdered,
		o.priceEach * o.quantityOrdered as precio,
		count(*) as conteo 
	from orderdetails o
	group by ordernumber
	having conteo >= (
		select round(avg(conteo)) as promedio
		from (
			select 
				ordernumber as numero_pedido, 
				count(*) as conteo 
			from orderdetails o
			group by ordernumber
		) as t
	) order by conteo desc;
	
	
	
-- 10.- Clientes que compraron lo mismo que otro cliente
-- Encuentra los clientes que han comprado al menos un producto que 
-- también compró el cliente “Atelier graphique”, usando IN con subconsulta.
	
	-- 
	select * from customers c where c.customerName = 'Atelier graphique'
	
	select * from orders where customerNumber = 103
	
	select o.productCode from orderdetails o 
	where o.orderNumber in (10123, 10298, 10345)
	
	
	select * from orderdetails o
	where o.productCode in (
		select o.productCode from orderdetails o 
		where o.orderNumber in (10123, 10298, 10345)
	)
	
	select distinct c.customerName
	from customers c
	join orders o on c.customerNumber = o.customerNumber
	join orderdetails od on o.orderNumber = od.orderNumber
	where od.productCode in (
	    select distinct od2.productCode
	    from customers c2
	    join orders o2 on c2.customerNumber = o2.customerNumber
	    join orderdetails od2 on o2.orderNumber = od2.orderNumber
	    where c2.customerName = 'Atelier graphique'
	)
	and c.customerName <> 'Atelier graphique';
	
	
	
    