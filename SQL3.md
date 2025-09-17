# Conceptos Avanzados de SQL

## Indice
[Indices](#indices)

[Trigger](#trigger)

[Vistas](#vistas)

[Procedimiento Almacenado](#procedimiento-almacenado)

[Funciones](#funciones)

[Admin de BD](#admin-de-bd)

---

## Indices
Los índices son estructuras de datos que optimizan la recuperación de información en una tabla, permitiendo consultas más rápidas sin necesidad de recorrer todos los registros.

Existen varios tipos de índices en bases de datos, entre ellos:
* Índice Primario (Primary Key): Se crea automáticamente cuando una columna es definida como clave primaria. Garantiza la unicidad de los registros y optimiza la búsqueda por esa clave.
* Índice Único (Unique Index): Evita la duplicidad de valores en una o más columnas, asegurando que cada valor sea único dentro de la tabla.
* Índice Compuesto: Se crea sobre dos o más columnas y es útil cuando las búsquedas involucran múltiples campos de manera frecuente.
* Índice Agrupado (Clustered Index): Organiza físicamente los datos en la tabla siguiendo el orden del índice. Solo puede haber un índice agrupado por tabla, ya que define la forma en que los datos se almacenan.
* Índice No Agrupado (Non-Clustered Index): Funciona como el índice de un libro, almacenando punteros a las ubicaciones reales de los datos en la tabla. Es útil para búsquedas en columnas que no están en el índice agrupado.

Si bien los índices mejoran el rendimiento de las consultas SELECT, también tienen desventajas:
* Mayor uso de espacio en disco: Cada índice requiere almacenamiento adicional.
* Impacto en operaciones de escritura: Las operaciones de inserción, actualización y eliminación pueden ser más lentas debido a la necesidad de mantener los índices actualizados.

Por lo tanto, se recomienda crear índices solo en columnas que se consulten con frecuencia y que tengan un alto grado de selectividad (valores únicos o poco repetitivos).

Crear un indice:
```sql
CREATE INDEX index_name ON table_name (column1, column2, ...);

-- Ejemplo
CREATE INDEX idx_notes_title ON notes (title);
CREATE UNIQUE INDEX idx_notes_title ON notes (title, author);

--Eliminar un indice
DROP INDEX index_name ON table_name;
```
**Índice Agrupado (Clustered Index)**
* Similar a una guía telefónica donde los registros se almacenan en orden físico basado en el índice.
* Determina la secuencia de almacenamiento de los registros en la tabla.
* Se usa en campos por los que se realizan búsquedas con frecuencia o se accede en un orden específico.
* Una tabla solo puede tener un índice agrupado.

**Índice No Agrupado (Non-Clustered Index)**
* Similar al índice de un libro, donde el índice contiene referencias a la ubicación real de los datos.
* Los datos se almacenan en una ubicación diferente al índice, con punteros que indican su posición.
* Se emplea cuando se realizan distintos tipos de búsquedas frecuentemente en campos con valores únicos o semiúnicos.
* Una tabla puede tener múltiples índices no agrupados.

Si no se especifica el tipo de índice, por defecto será un índice no agrupado.

En conclusión, El uso adecuado de los índices puede mejorar significativamente el rendimiento de una base de datos, pero debe realizarse con cuidado para evitar penalizaciones en operaciones de escritura. Es recomendable analizar las consultas más frecuentes y aplicar índices estratégicamente en las columnas adecuadas.


## Trigger
Instrucciones automatizadas cuando ocurre algo en una tabla concreta.
Ej: Si un usuario actualiza su username, que en otra tabla(UserLog) se guarde el nombre anterior y el nuevo.

```sql
CREATE TRIGGER nombre_trigger
ON nombre_tabla
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Instrucciones
END;

-- Ejemplo 1
CREATE TRIGGER tr_actualizar_fecha
ON usuarios
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE usuarios
    SET fecha_modificacion = GETDATE()
    WHERE id = (SELECT id FROM inserted);
END;


-- Ejemplo 2
CREATE TRIGGER tg_email
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    IF NEW.email <> OLD.email THEN
        INSERT INTO email-history (id_user, email, new_email)
        VALUES (id_user, OLD.id, NEW.email);
    END IF;
END;
```


## Vistas
Una vista es una tabla virtual que se genera a partir de una consulta SQL. No almacena datos por sí misma, sino que actúa como una representación dinámica de los datos en una o más tablas subyacentes.

Las vistas son utilizadas por varias razones, entre ellas:
* Simplificación de consultas: Permiten encapsular consultas SQL complejas en estructuras más manejables y reutilizables.
* Seguridad y control de acceso: Se pueden utilizar para restringir el acceso a ciertas columnas o filas de una tabla, proporcionando un nivel adicional de seguridad.
* Abstracción de datos: Permiten ocultar la complejidad del esquema subyacente a los usuarios finales.
* Mantenimiento y consistencia: Facilitan el mantenimiento del código SQL y la coherencia en las consultas recurrentes.

Se caracterizan por: 
* No almacenan datos físicos, sino que contienen solo la consulta SQL que las define.
* Se actualizan automáticamente cuando cambian los datos en las tablas subyacentes.
* Dependiendo del sistema de gestión de bases de datos, algunas vistas pueden ser actualizables si cumplen ciertos requisitos.

Para definir una vista en SQL, se utiliza la siguiente sintaxis:
```sql
CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

Ejemplo:
```sql
-- Ejemplo 1
CREATE VIEW v_adult_users AS
SELECT name, age FROM users where age >= 18;

SELECT * FROM v_adult_users;

-- Ejemplo 2
CREATE VIEW active_customers AS
SELECT id, name, email
FROM customers
WHERE status = 'active';
```

Las vistas son una herramienta poderosa para optimizar y estructurar el acceso a los datos en bases de datos relacionales. Permiten mejorar la seguridad, la mantenibilidad y la eficiencia de las consultas sin afectar directamente la estructura o el almacenamiento de los datos.


## Procedimiento Almacenado

Un procedimiento almacenado es un conjunto de instrucciones SQL predefinidas que se almacenan en el servidor de la base de datos y pueden ejecutarse cuando sea necesario. Son utilizados para encapsular lógica de negocios, mejorar el rendimiento y facilitar la reutilización del código SQL.

Beneficios de los Procedimientos Almacenados
* Mejor rendimiento: Al estar precompilados, su ejecución es más rápida que enviar múltiples consultas SQL desde la aplicación.
* Reutilización de código: Se pueden llamar múltiples veces desde distintas partes de la aplicación sin necesidad de repetir el código.
* Seguridad y control de acceso: Se pueden otorgar permisos específicos para la ejecución del procedimiento sin exponer directamente las tablas subyacentes.
* Reducción del tráfico de red: Al ejecutarse en el servidor, se minimiza la cantidad de datos enviados entre la aplicación y la base de datos.
* Facilita el mantenimiento: Centraliza la lógica de negocios, reduciendo la redundancia y mejorando la gestión del código.

Sintaxis basica:
```sql
CREATE PROCEDURE sp_example()
BEGIN
    SELECT * FROM example_table;
END;
```

Ejemplo:
```sql
CREATE PROCEDURE sp_age_users(IN age_param INT)
BEGIN
    SELECT * FROM example_table WHERE age = age_param;
END;


CALL sp_example
CALL sp_age_users(25)
```
Para ejecutar un procedimiento almacenado, se utiliza la instrucción `EXEC` o `CALL` dependiendo del sistema de gestión de bases de datos

Si es necesario modificar un procedimiento, se utiliza ALTER PROCEDURE:
```sql
ALTER PROCEDURE procedure_name
AS
BEGIN
    -- Nueva lógica
END;
```

Los procedimientos almacenados son una herramienta poderosa para optimizar el rendimiento, mejorar la seguridad y facilitar la gestión de bases de datos. Su correcto uso permite una mayor eficiencia en la ejecución de consultas y una mejor organización del código SQL.


## Funciones
Las funciones en SQL son bloques de código que realizan una tarea específica y devuelven un valor. Se utilizan para encapsular lógica reutilizable, simplificar consultas y mejorar la eficiencia en el procesamiento de datos.

Existen dos tipos principales de funciones en SQL:

* Funciones Escalares: Devuelven un único valor basado en los parámetros de entrada.
* Funciones con Tabla (Table-Valued Functions): Devuelven una tabla como resultado y pueden ser utilizadas en consultas como si fueran una tabla normal.

Las funciones ofrecen varias ventajas, entre ellas:
* Reutilización de código: Se pueden invocar en múltiples consultas sin necesidad de repetir la lógica.
* Modularidad: Permiten dividir la lógica en partes manejables y organizadas.
* Mejor legibilidad y mantenimiento: Facilitan la comprensión y actualización del código SQL.
* Mejor rendimiento: Al optimizar el procesamiento dentro del motor de la base de datos.

Las funciones escalares devuelven un único valor. Su sintaxis es la siguiente:
```sql
CREATE FUNCTION function_name (@param1 datatype, @param2 datatype)
RETURNS return_datatype
AS
BEGIN
    DECLARE @result return_datatype;
    -- Lógica de la función
    SET @result = (SELECT COUNT(*) FROM table_name WHERE column1 = @param1);
    RETURN @result;
END;
```

Ejemplo:
```sql
CREATE FUNCTION GetActiveCustomers()
RETURNS TABLE
AS
RETURN (
    SELECT id, name, email FROM customers WHERE status = 'active'
);

SELECT GetActiveCustomers();
```
Las funciones en SQL permiten encapsular lógica, mejorar el mantenimiento del código y optimizar el rendimiento de las consultas. Su uso adecuado facilita la organización y eficiencia en la gestión de bases de datos.


## Admin de BD

### Tablespace
Un tablespace es una unidad lógica de almacenamiento en Oracle Database que agrupa objetos como tablas e índices. Sirve para gestionar de manera eficiente el almacenamiento de datos, segmentando la base de datos en espacios organizados según su uso. Cada tablespace está compuesto por uno o más archivos físicos llamados datafiles.

Tipos de tablespaces:
* SYSTEM y SYSAUX: Contienen objetos del diccionario de datos y estructuras internas.
* USERS: Espacio por defecto para usuarios sin un tablespace asignado.
* TEMP: Utilizado para operaciones temporales como sorting.
* UNDO: Maneja transacciones para soportar ROLLBACK y CONSISTENCIA.
* DATA y INDEX: Pueden ser creados por administradores para almacenar datos y optimizar consultas.

```sql
// Crear tablespace con 10M
CREATE TABLESPACE tablespace_name DATAFILE '/ruta' SIZE 10M;

// Agregarle 100M
ALTER TABLESPACE tablespace_name ADD DATAFILE '/ruta' size 100M;

// Aumentamos complejidad
CREATE TABLESPACE tablespace_name
DATAFILE '/u01/app/oracle/oradata/mi_tablespace01.dbf'  //Ubicación física del archivo de datos.
SIZE 500M  //Tamaño inicial de 500 MB.
AUTOEXTEND ON NEXT 100M MAXSIZE 2G //Crecimiento automático de 100 MB hasta 2 GB
EXTENT MANAGEMENT LOCAL //Gestión de extents dentro del tablespace (modo recomendado)
SEGMENT SPACE MANAGEMENT AUTO; //Usa algoritmos automáticos para manejar espacio en segmentos
```

### Perfiles de usuario (Profiles)
Un perfil en Oracle define restricciones y límites para la gestión de recursos de un usuario. Se usa para aplicar políticas de seguridad y control de recursos.

```sql
CREATE USER username IDENTIFIED BY password DEFAULT TABLESPACE tablespace_name
QUOTA 20M ON tablespace_name PROFILE profile_name;

DROP USER username CASCADE;
DROP PROFILE profile_name;

ALTER USER username PROFILE profile_name;
```

Parámetros comunes en un perfil:
* CONNECT_TIME: Tiempo permitido de conexión por sesión en minutos
* CPU_PER_CALL: Máximo tiempo de CPU por llamada en centésimas de segundo
* CPU_PER_CALL: Máximo tiempo de CPU por llamada en centésimas de segundo.
* CPU_PER_SESSION: Límite de uso de CPU por sesión.
* IDLE_TIME: Tiempo máximo permitido sin actividad por el usuario antes de ser desconectado. Se expresa en minutos.
* LOGICAL_READS_PER_CALL: Máximo número de bloques de base de datos leídos por llamada
* LOGICAL_READS_PER_SESSION: Máximo número de bloques de base de datos leídos por sesión.
* PRIVATE_SGA: Máxima cantidad de bytes de espacio privado reservado en la SGA. Se puede expresar en el formato entero K para kilobytes o entero M para megabytes.
* SESSIONS_PER_USER: Máximo número de sesiones concurrentes permitidas por usuario

* IDLE_TIME:
* SESSIONS_PER_USER: Número máximo de sesiones simultáneas.
* FAILED_LOGIN_ATTEMPTS: Intentos fallidos antes de bloquear la cuenta.
* PASSWORD_GRACE_TIME: Número de días de gracia para realizar un cambio de password de nuestra cuenta. Si en el periodo de tiempo delimitado no fue cambiado el password, el password expira
* PASSWORD_LIFE_TIME: Número de días de vida de un password.
* PASSWORD_LOCK_TIME: Número de días que permanecerá bloqueado un usuario después de sobrepasar el límite FAILED_LOGIN_ATTEMPTS.
* PASSWORD_REUSE_MAX: Número de veces que debe cambiar una contraseña antes de poder ser re-usada la original.
* PASSWORD_REUSE_TIME: Número de días que tienen que pasar para poder re-usar un password.
* PASSWORD_VERIFY_FUNCTION: En este parámetro, se puede especificar un script para validar el password. Por ejemplo, que tenga una determinada cantidad de caracteres, que tenga letras y números. 


### Privilegios o Permisos
Los privilegios determinan qué operaciones puede realizar un usuario en la base de datos. Se dividen en:

* Privilegios del sistema: Permiten ejecutar acciones administrativas. Ejemplos:
    * CREATE SESSION (permite conectarse a la BD).
    * CREATE TABLE (permite crear tablas).
    * ALTER USER (modificar usuarios).
 
    * ```sql
        GRANT privilegio TO user;
        REVOKE privilegio FROM user;
        
        // Examples
        GRANT
            CREATE SESSION, ALTER SESSION, CREATE TABLE, 
            CREATE VIEW, CREATE SYNONYM, CREATE SEQUENCE, 
            CREATE TRIGGER, CREATE PROCEDURE, CREATE TYPE 
        TO alumno;
        ```

* Privilegios de objeto: Permiten realizar acciones sobre objetos específicos. Ejemplos:
    * SELECT, INSERT, UPDATE, DELETE en tablas.
    * EXECUTE en procedimientos almacenados.
    * ```sql
      GRANT privilegio
      ```

### Roles
Un rol es un grupo de privilegios que puede asignarse a usuarios para facilitar la gestión de permisos.

Tipos de roles:
    * Predefinidos por Oracle:
        * CONNECT: Permite conexión básica a la BD.
        * RESOURCE: Permite crear objetos de base de datos.
        * DBA: Otorga privilegios administrativos completos.
    * Definidos por el usuario: Se pueden crear roles personalizados con CREATE ROLE.
    
Los roles se asignan con GRANT ROLE TO usuario; y se pueden eliminar con DROP ROLE nombre_rol;.
```sql
CREATE ROLE analista;

// Asignar privilegios a un rol
GRANT SELECT, INSERT, UPDATE ON empleados TO analista;
GRANT SELECT ON clientes TO analista;

// Asignar un rol a un usuario
GRANT analista TO usuario1;

//  Ver roles asignados a un usuario
SELECT granted_role FROM dba_role_privs WHERE grantee = 'USUARIO1';

// Revocar un rol a un usuario
REVOKE analista FROM usuario1;

// Ver todos los roles disponibles en la base de datos
SELECT role FROM dba_roles;

// Ver los privilegios asignados a un rol
SELECT privilege FROM dba_sys_privs WHERE grantee = 'ANALISTA';

// Ver qué usuarios tienen asignado un rol
SELECT grantee FROM dba_role_privs WHERE granted_role = 'ANALISTA';



```

