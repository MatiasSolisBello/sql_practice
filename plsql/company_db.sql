-- =========================
-- TABLA: companies
-- =========================
CREATE TABLE companies (
    company_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================
-- TABLA: departments
-- =========================
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- =========================
-- TABLA: employees
-- =========================
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    salary NUMERIC(10,2),
    hire_date DATE,
    company_id INT REFERENCES companies(company_id),
    department_id INT REFERENCES departments(department_id)
);

-- =========================
-- TABLA: products
-- =========================
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC(10,2) NOT NULL
);

-- =========================
-- TABLA: sales
-- =========================
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT REFERENCES products(product_id),
    quantity INT CHECK (quantity > 0),
    sale_date DATE DEFAULT CURRENT_DATE,
    total NUMERIC(10,2)
);

-- =========================
-- DATOS DE PRUEBA
-- =========================

-- Companies
INSERT INTO companies (name, country) VALUES
('TechCorp', 'Chile'),
('DataSolutions', 'Argentina');

-- Departments
INSERT INTO departments (name) VALUES
('IT'),
('Sales'),
('HR');

-- Employees
INSERT INTO employees (first_name, last_name, email, salary, hire_date, company_id, department_id) VALUES
('Juan', 'Perez', 'juan@techcorp.com', 1200, '2022-01-10', 1, 1),
('Maria', 'Gomez', 'maria@techcorp.com', 1500, '2021-03-15', 1, 2),
('Luis', 'Lopez', 'luis@datasol.com', 1100, '2023-06-01', 2, 2);

-- Products
INSERT INTO products (name, price) VALUES
('Laptop', 800),
('Mouse', 20),
('Keyboard', 50);

-- Sales
INSERT INTO sales (employee_id, product_id, quantity, total) VALUES
(1, 1, 1, 800),
(2, 2, 5, 100),
(3, 3, 2, 100);
