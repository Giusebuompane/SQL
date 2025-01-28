
									 -- NIVEL 1


CREATE DATABASE SPRINT_4;
USE SPRINT_4;

    -- Creamos la tabla companies
    CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
    
    
    -- Cargamos datos companies 
    
LOAD DATA LOCAL INFILE 'C:/Users/giuia/OneDrive/ESPECIALIZACION/SQL/Sprint_4/ARCHIVOS/companies.csv' -- ruta/nombrefile.csv ( invertir todos los\) CARGA FILE EN LOCAL
INTO TABLE companies FIELDS TERMINATED BY ',' -- El carácter que separa los valores
LINES TERMINATED BY '\n' -- El carácter que termina las líneas
IGNORE 1 LINES; -- La información para ignorar la primera fila, que contiene el encabezado:

SHOW GLOBAL VARIABLES LIKE 'local_infile'; -- Este comando muestra si la opción para permitir la carga de archivos locales está habilitada o deshabilitada.
SET GLOBAL local_infile=1; --  habilita la opción de cargar archivos locales en el servidor MySQL


-- Creamos la tabla credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
   id VARCHAR(15) PRIMARY KEY,
   user_id INT,
   iban VARCHAR(50),
   pan VARCHAR(10),
   pin VARCHAR(4),
   cvv int,
   track1 VARCHAR(50),
   track2 VARCHAR(50),
   expiring_date VARCHAR(20)
);

 -- Cargamos datos credit_cards
LOAD DATA LOCAL INFILE 'C:/Users/giuia/OneDrive/ESPECIALIZACION/SQL/Sprint_4/ARCHIVOS/credit_cards.csv' 
INTO TABLE credit_cards FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES; 

-- Creamos la tabla products
CREATE TABLE IF NOT EXISTS products (
   id VARCHAR(15) PRIMARY KEY,
   product_name VARCHAR(30),
   price VARCHAR(30),
   colour VARCHAR(10),
   weight DECIMAL (10,2),
   warehouse_id VARCHAR(10)
);

-- Cargamos datos products
LOAD DATA LOCAL INFILE 'C:/Users/giuia/OneDrive/ESPECIALIZACION/SQL/Sprint_4/ARCHIVOS/products.csv' 
INTO TABLE products 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES; 


-- Creamos la tabla users ( juntamos las 3 ca/uk/usa)

CREATE TABLE IF NOT EXISTS users (
   id VARCHAR(15) PRIMARY KEY,
   name VARCHAR(30),
   surname VARCHAR(30),
   phone VARCHAR(20),
   email VARCHAR(50),
   birth_date VARCHAR(20),
   country VARCHAR(20),
   city VARCHAR(20),
   postal_code VARCHAR(20),
   address VARCHAR(30)
   
   );
   
-- cargamos users_ca   
LOAD DATA LOCAL INFILE 'C:/Users/giuia/OneDrive/ESPECIALIZACION/SQL/Sprint_4/ARCHIVOS/users_ca.csv'
INTO TABLE USERS 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' -- el file fue creado en entorno windows
IGNORE 1 LINES; 

-- cargamos users_uk   
LOAD DATA LOCAL INFILE 'C:/Users/giuia/OneDrive/ESPECIALIZACION/SQL/Sprint_4/ARCHIVOS/users_uk.csv'
INTO TABLE USERS 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES; 

-- cargamos users_usa   
LOAD DATA LOCAL INFILE 'C:/Users/giuia/OneDrive/ESPECIALIZACION/SQL/Sprint_4/ARCHIVOS/users_usa.csv'
INTO TABLE USERS 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES; 


-- Creamos la tabla transactions con las FKs estableciendo relaciones
CREATE TABLE IF NOT EXISTS transactions (
   id VARCHAR(50) PRIMARY KEY,
   card_id VARCHAR(15) REFERENCES credit_cards(id),
   business_id VARCHAR(15),
   timestamp TIMESTAMP,
   amount DECIMAL (10,2),
   declined BOOLEAN, -- alias del tipo TINYINT(1)
   product_ids VARCHAR(255),
   user_id VARCHAR(15) REFERENCES users(id),
   lat VARCHAR(25),
   longitude VARCHAR(25),
   FOREIGN KEY (card_id) REFERENCES credit_cards(id),
   FOREIGN KEY (user_id) REFERENCES users(id),
   FOREIGN KEY (business_id) REFERENCES companies(company_id)
);

-- cargamos datos transactions   
LOAD DATA LOCAL INFILE 'C:/Users/giuia/OneDrive/ESPECIALIZACION/SQL/Sprint_4/ARCHIVOS/transactions.csv'
INTO TABLE TRANSACTIONS
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES; 

/*-- Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions 
utilitzant almenys 2 taules.*/

SELECT name
FROM users
WHERE id IN (SELECT user_id
            FROM transactions
            GROUP BY user_id
            HAVING COUNT(*) > 30);
     
/* Exercici 2
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, 
utilitza almenys 2 taules.*/


SELECT credit.iban, comp.company_name,round(avg(trans.amount),3) as promedio_trans
FROM transactions as trans 
JOIN credit_cards as credit
ON trans.card_id = credit.id
JOIN companies as comp
ON trans.business_id = comp.company_id
WHERE comp.company_name = "Donec Ltd"
GROUP BY 1,2;


										-- NIVEL 2
                                                   
/*Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions 
van ser declinades i genera la següent consulta:*/

/*Exercici 1
Quantes targetes estan actives?*/


         
/*con el with: creamos 2 tablas temporales sobre las que podemos trabajar.
con la funcion window , row_number() crea una nueva columna y a cada fila
le asigna un numero a partrir de 1.
partition by: divide los datos(las transaciones) por grupo o sea por cada id,
con el order by timestamp desc:obtenemos las transaciones ordenades por la mas reciente
de este modo sabemos que por cada drupo id el numero 1,2,3 son las ultimas 3 transaciones.
en estado tarjeta, utilizamos un CASE para crear una nueva columna con condición 
para establecer el estado de cada tarjeta(id)
las tarjetas que tienen como suma 3 (1+1+1) del campo declined y 3 del count de filas
son las tarjetas activas, las demas recogidas por el else, están inactivas*/
  
         
WITH transacciones_ordenadas AS (
SELECT 
card.id AS card_id,trans.declined,trans.timestamp,
ROW_NUMBER() OVER (PARTITION BY card.id ORDER BY trans.timestamp DESC) AS fila
FROM credit_cards AS card
LEFT JOIN transactions AS trans
ON card.id = trans.card_id
),
estado_tarjetas AS(
SELECT card_id,
CASE WHEN COUNT(*) = 3 AND SUM(declined) = 3 THEN "inactiva"
ELSE "activa" END AS estado_tarjeta
FROM transacciones_ordenadas
GROUP BY card_id
)
SELECT COUNT(*) AS Num_tarjetas_activas
FROM estado_tarjetas
WHERE estado_tarjeta = "activa";

                                            -- NIVEL 3
/*Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte.*/




CREATE TABLE IF NOT EXISTS prod_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50),
    product_id VARCHAR(15)
   );
INSERT INTO prod_transactions (transaction_id, product_id)
SELECT
    trans.id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(trans.product_ids, ',', n.n), ',', -1)) AS product_id 
    
FROM
    transactions trans
JOIN
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6) n
ON
    CHAR_LENGTH(trans.product_ids) - CHAR_LENGTH(REPLACE(trans.product_ids, ',', '')) >= n.n - 1
ORDER BY
    trans.id, n.n;
    
     
    /* 
  Seleccionamos el ID de la transaccion y dividimos la cadena 'product_ids' en productos individuales:
  
  - SUBSTRING_INDEX(t.product_ids, ',', n.n): divide la cadena de product_ids usando la coma ',' como delimitador
    y devuelve el producto en la posición 'n.n' de la lista (por ejemplo, para n.n = 1, devuelve el primer producto).
  
  - , ',', -1): obtiene el ultimo producto en la lista o sea el valor después de la ultima coma.
  
  - TRIM: elimina eventuales espacios en blanco en la cadena.
  
  - (JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL..)): esta subconsulta genera una serie de numeros del 1 al 6, 
    que se usan como posiciones para dividir la cadena de 'product_ids'. Si vemos que hay mas productos, se puede aumentar y darle otro tope.
  
  - CHAR_LENGTH(t.product_ids) - CHAR_LENGTH(REPLACE(t.product_ids, ',', '')) >= n.n - 1: calcula el numero de comas en 'product_ids' 
    y asegura que cada numero 'n.n' esté dentro del rango de productos que hay en la lista. Si hay 3 comas, el rango de 'n.n' será 1-3.
  
  - ORDER BY trans.id, n.n: ordena los resultados por el ID de transaccion y la posición del producto en la lista.
*/

    
    
    
    
-- añadimos FK con delete cascade, le estamos diciendo que si se elimina una transación de transactions ( tabla padre), tambien se eliminarás las transaciones asociadas en la tabla prod_transaction 
ALTER TABLE prod_transactions
ADD CONSTRAINT FK_transactions
FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE;

-- añadimos FK con delete cascade, le estamos diciendo que si se elimina un producto de la tabla products (tabla padre), tambien se eliminan todas las transaciones asociadas en la tabla prod_transaction (tabla padre)
ALTER TABLE prod_transactions
ADD CONSTRAINT FK_product
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

/* OPCION ON DELETE NULL
si eliminamos un registro en la tabla padre ( products), 
los registros relacionados en la tabla hija (prod_transactions) no se eliminan. E
n su lugar, la columna relacionada (product_id en prod_transactions) 
se actualizan y quedan con un valor NULL.


/*Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte*/

SELECT prod.id, prod.product_name, count(prodtra.product_id) prod_vendidos
FROM prod_transactions as prodtra
Join products as prod
on prodtra.product_id = prod.id
group by 1,2
order by 3 desc;

-- TAREA ADICIONAL CREANDO COLUMNA cantidad + consulta dato num de prod vendidos.

ALTER TABLE prod_transactions ADD COLUMN cantidad INT DEFAULT 1;

SELECT product_id, sum(cantidad) AS prod_vendidos
FROM prod_transactions
GROUP  BY 1
ORDER  BY 2 DESC;

/* Al crear la tabla prod_transactions he estado barajando la idea de crear una columna cantidad.
al final la creamos despues como tarea adicional, la decision de crear o no el campo en cuestion
se basaría en cómo y cuántas veces se utilizaría para más análisis
y si afectaría nuestra tabla/bbdd con campos innecesarios.
en este caso sacaríamos el dato de la cantidad de productos vendidos directamente consultando la tabla
sin utilizar join stal como muestra la consulta arriba, en caso de que quisiésemos sacar también
el nombre del producto, sí que necesitaríamos hacer un join con products.
*/

-- TAREA ADICIONAL - TRIGGER AFTER INSERT en transacions
/*el trigger se desparará cada vez que insertemos un registro en transacions,
 automaticamente nos actualizará la tabla prod_transactions agregando el nuevo registro*/


CREATE TRIGGER actualiza_prod_transacion_AI
AFTER INSERT ON transactions 
FOR EACH ROW 
INSERT INTO prod_transactions (transaction_id,product_id) -- seleccionamos  los campos de prod_transacion donde vamos a insertar la info ( excepto el id que es auto_increment)
VALUES (new.id,new.product_ids); -- seleccionamos los campos de la tabla padre (Transacions )de donde proceden los campos ( sin cantidad porque se calcula con el codigo del ejercicio 1)


-- insertamos registro en transactions con los valores:

/*id 'B4793303-EDF5-4F53-39CB-AA6A2877CDF8' -- (nuevo)
card_id 'CcU-2938'
business_id 'b-2362'
product_ids '37'
timestamp now()
user_id '92'*/

/* al tener Transacions a su vez vinculos de dependencia con 
las demas tablas de dimensione( companies, credit_card y users) 
hemos tenido que usar ids ya existentes en estas tablas para evitar errores.*/

INSERT INTO transactions (id, card_id, business_id, product_ids, timestamp, user_id)
VALUES 
('B4793303-EDF5-4F53-39CB-AA6A2877CDF8', 'CcU-2938', 'b-2362', 37, NOW(), '92');

SELECT *
FROM transactions 
WHERE id= 'B4793303-EDF5-4F53-39CB-AA6A2877CDF8';

SELECT *
FROM prod_transactions
WHERE transaction_id = 'B4793303-EDF5-4F53-39CB-AA6A2877CDF8';

/*aqui volvemos a borrar el registro para averiguar el correcto funcionamiento del delete cascade de la FK de prod_transacion
para esegurar consistencia de datos*/

DELETE FROM transactions
WHERE id= 'B4793303-EDF5-4F53-39CB-AA6A2877CDF8'
