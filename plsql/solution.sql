select * from companies;

select * from departments;

select * from employees;

select * from products;

select * from sales;


-- ---------------------------------
-- INDICES
-- ---------------------------------
-- Índice básico: Crea un índice sobre employees(email).
CREATE unique INDEX idx_employees_email ON employees (email);


-- Índice compuesto: Crea un índice compuesto en sales(employee_id, sale_date).
CREATE INDEX idx_sales ON sales (employee_id, sale_date);


-- Índice parcial: Crea un índice solo para ventas con quantity > 3.
CREATE INDEX idx_sales_three ON sales (quantity) 
	WHERE quantity > 3;


-- Índice funcional: Crea un índice sobre LOWER(email)
CREATE index idx_lower_email on employees (LOWER(email));

SELECT * FROM employees
WHERE LOWER(email) = 'juan@techcorp.com';


-- ---------------------------------
-- FUNCIONES / PROCEDIMIENTOS
-- ---------------------------------
-- Función simple: Crea una función que retorne el salario anual de un empleado.
CREATE OR REPLACE FUNCTION get_annual_salary(p_employee_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_salary NUMERIC;
BEGIN
    SELECT salary
    INTO v_salary
    FROM employees
    WHERE employee_id = p_employee_id;

    RETURN v_salary;
END;
$$ LANGUAGE plpgsql;

SELECT get_annual_salary(1);


-- Retorna el total de ventas de un empleado.
CREATE OR replace FUNCTION get_sales_by_employee(p_employee_id INT) 
RETURNS NUMERIC AS $$
DECLARE
    v_sales NUMERIC;
BEGIN
	select count(*)
    INTO v_sales
    FROM sales
    WHERE employee_id = p_employee_id;

    RETURN v_sales;
end;
$$ LANGUAGE plpgsql;

SELECT get_sales_by_employee(1);


-- Procedimiento: Aumenta el salario de todos los empleados "de una empresa" en un % dado.
CREATE or replace PROCEDURE sp_incremate_salary(IN v_percent NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected_rows INT;
BEGIN
    update employees
    set salary = salary * (1 + (v_percent / 100))
	WHERE company_id = 1;

	GET DIAGNOSTICS v_affected_rows = ROW_COUNT;
    RAISE NOTICE 'Salarios actualizados para % empleados.', v_affected_rows;
END;
$$;

call sp_incremate_salary(10);


-- ---------------------------------
-- TRIGGERS
-- ---------------------------------
-- Calcula automáticamente el total (quantity * price) en la tabla sales
CREATE OR REPLACE FUNCTION fn_get_total_sale()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_price NUMERIC;
BEGIN
    -- Obtener precio del producto
    SELECT price INTO v_price
    FROM products
    WHERE product_id = NEW.product_id;

    IF v_price IS NULL THEN
        RAISE EXCEPTION 'Producto % no existe', NEW.product_id;
    END IF;

    -- Calcular total
    NEW.total := NEW.quantity * v_price;

    RETURN NEW;
END;
$$;


CREATE TRIGGER trg_get_total_sale
BEFORE INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION fn_get_total_sale();

INSERT INTO sales (employee_id, product_id, quantity) 
VALUES(1, 2, 4);

select * from sales;

-- ---------------------------------
-- VISTAS
-- ---------------------------------
-- Crear vista employee_sales_summary: nombre empleado, total ventas
CREATE VIEW v_employee_sales_summary AS
SELECT 
	e.first_name ||' '||e.last_name as "employee_name",
	count(*) AS total_sales
FROM employees e
join sales s on (e.employee_id = s.employee_id)
group by s.employee_id, e.first_name, e.last_name;

SELECT * FROM v_employee_sales_summary;



