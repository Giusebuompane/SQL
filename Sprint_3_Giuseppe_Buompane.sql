                                        -- NIVEL 1
                                        
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

-- modificamos registro CcU-2938.
UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';


-- INSERTAMOS REGISTRO
insert into transaction (id, credit_card_id,company_id,user_id,lat,longitude,amount,declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999','9999','829.999','-117.999','111.11','0');

-- BORRAMOS COLUMNA
ALTER TABLE credit_card DROP COLUMN pan;


										    -- NIVEL 2

-- Exercici 1
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

 DELETE FROM TRANSACTION 
 WHERE ID = '02C6201E-D90A-1859-B4EE-88D2986D3B02';
 
-- Exercici 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
-- Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
-- ordenant les dades de major a menor mitjana de compra.

SELECT comp.company_name, comp.phone, comp.country, promedio.Promedio_ventas
FROM company as comp
Join (select company_id,round(avg(amount),2) as Promedio_ventas from transaction
where declined = 0
group by 1) as promedio on comp.id = promedio.company_id
order by promedio_ventas desc;

                                   -- NIVEL 3
-- Exercici 1
/* La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
Un company del teu equip va realitzar modificacions en la base de dades, 
però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos 
executats per a obtenir el següent diagrama:*/

-- diagrama con comentarios cargado en PDF

ALTER TABLE transaction ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id) REFERENCES user(id);

SET FOREIGN_KEY_CHECKS = 0;
SET FOREIGN_KEY_CHECKS = 1;

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

SELECT trans.id as id_transacion, us.name as nombre_usiario, us.surname as apellido_usuario,
trans.user_id as id_usuario, credit.iban,comp.company_name as nombre_empresa,
comp.country as pais_empresa,trans.amount as importe,
trans.declined as pago_rechazado
from transaction as trans
Join data_user as us on  trans.user_id = us.id
Join credit_card as credit on trans.credit_card_id = credit.id
Join company as comp on trans.company_id = comp.id
order by id_transacion desc;

