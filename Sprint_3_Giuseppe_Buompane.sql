                                        -- NIVEL 1
                                        
/*Exercici 1
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company").
Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". 
Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.*/                                        
                                        
-- Creamos la tabla "credit_card"
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(255),
    iban VARCHAR(40),
    pan VARCHAR(20),
    pin VARCHAR(6),
    cvv VARCHAR(4),
    expiring_date VARCHAR(15), 
    PRIMARY KEY (id)
);

--  agregamos la FK en Transaction para establecer relacion con credit_card

ALTER TABLE transaction ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY(credit_card_id) REFERENCES credit_card(id);

/*Exercici 2
El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. 
La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.*/



-- modificamos registro CcU-2938.
UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

select *
from credit_card
where ID = "CcU-2938";


/*Exercici 3
En la taula "transaction" ingressa un nou usuari amb la següent informació:
Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	0*/

-- Creamos registro en la tabla company y creit_card para evitar errores que nos lanza por las restricciones de dependencia de FK
insert into company(id) 
values ("b-9999"); 

insert into credit_card(id)  
values ("CcU-9999");

-- Ahora si podemos insertar el resigro en transaction
insert into transaction (id, credit_card_id,company_id,user_id,lat,longitude,amount,declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999','9999','829.999','-117.999','111.11','0');

select *
from transaction
where id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";


/*Exercici 4
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.*/

-- BORRAMOS COLUMNA
ALTER TABLE credit_card DROP COLUMN pan;


										    -- NIVEL 2

-- Exercici 1
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

 DELETE FROM TRANSACTION 
 WHERE ID = '02C6201E-D90A-1859-B4EE-88D2986D3B02';
 
 select *
from transaction
where ID = "02C6201E-D90A-1859-B4EE-88D2986D3B02"; 
 
-- Exercici 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
-- Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
-- ordenant les dades de major a menor mitjana de compra.


create view VistaMarketing as
select comp.id,comp.company_name, comp.phone, comp.country, round(avg(trans.amount),2) as Promedio_ventas 
from company as comp
join transaction as trans
on comp.id = trans.company_id
where declined = 0
group by 1 -- aqui agregando por el id de la compañia ( valor unico) si que nos deja agrupar por un solo campo
order by 4 desc;

Select * 
from vistamarketing;



/*Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"*/

SELECT * FROM VistaMarketing
where country = "Germany"
ORDER BY Promedio_ventas  DESC;



                                                        -- NIVEL 3
-- Exercici 1
/* La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
Un company del teu equip va realitzar modificacions en la base de dades, 
però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos 
executats per a obtenir el següent diagrama:*/


-- diagrama cargado en PDF

-- creamos la tabla user y cargamos los datos, al crearla , la relación por defecto, no está bien, entonces:

-- Borramos la FK 
ALTER TABLE user
DROP FOREIGN KEY user_ibfk_1;

-- Insertamos registros
insert into user(ID)
values ("9999");

-- Volvemos a habilitar la FK en la tabla transacion 
ALTER TABLE transaction ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id) REFERENCES user(id);

-- aqui siguen toda las demás acciones necesaria para dejar la BBDD talcomo nos pide el ejercicio
RENAME TABLE USER TO data_user;
ALTER TABLE COMPANY DROP COLUMN WEBSITE;
ALTER TABLE data_user RENAME COLUMN email TO personal_email;
ALTER TABLE credit_card ADD fecha_actual DATE;
ALTER TABLE credit_card MODIFY id VARCHAR(20);
ALTER TABLE credit_card MODIFY iban VARCHAR(50);
ALTER TABLE credit_card MODIFY pin VARCHAR(4);
ALTER TABLE credit_card MODIFY CVV INT;
ALTER TABLE credit_card MODIFY expiring_date VARCHAR(20);



-- Exercici 2

/*L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui 
la següent informació:
ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies 
per a canviar de nom columnes segons sigui necessari.
Mostra els resultats de la vista, ordena els resultats de manera descendent en funció 
de la variable ID de transaction.*/


CREATE View informetecnico AS 
SELECT trans.id as id_transacion, us.name as nombre_usiario, us.surname as apellido_usuario,
trans.user_id as id_usuario, credit.iban,comp.company_name as nombre_empresa,
comp.country as pais_empresa,trans.amount as importe,
trans.declined as pago_rechazado
from transaction as trans
Join data_user as us on  trans.user_id = us.id
Join credit_card as credit on trans.credit_card_id = credit.id
Join company as comp on trans.company_id = comp.id
order by id_transacion desc;

Select * from informetecnico
order by id_transacion desc;