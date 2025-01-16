                                                        -- NIVEL 1


                                -- Exercici 2 -- Utilitzant JOIN realitzaràs les següents consultes:

-- Llistat dels països que estan fent compres.

SELECT distinct(country) FROM company as comp
left join transaction as tran on comp.id = tran.company_id;


-- Des de quants països es realitzen les compres.

SELECT count(distinct country) as num_paises FROM company as comp
left join transaction as tran on comp.id = tran.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.*/

SELECT company_id,company_name, avg(tran.amount) as promedio_venta
FROM company as comp
join transaction as tran on comp.id = tran.company_id
where declined = 0
group by 1
order by promedio_venta desc
limit 1;

                               -- Exercici 3 Utilitzant només subconsultes (sense utilitzar JOIN):

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.

select* from transaction where company_id in ( select id FROM company
                                              where country = 'Germany');

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions. ( sin utilizar joins)

-- ( subconsulta promedio general )
SELECT avg(amount) from transaction;

select id, company_name from company 
where id in (SELECT company_id  from transaction 
             where  amount >(SELECT avg(amount) from transaction))
											  order by company_name;



-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT * FROM company
WHERE id NOT IN (SELECT company_id 
				 FROM transaction);

                                                         -- NIVEL 2
                                                         
                                                         -- Exercici 1
                                                         
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT date(timestamp) as fecha, sum(amount) AS total_ingresos
FROM transaction
WHERE declined = 0
GROUP BY fecha
ORDER BY total_ingresos DESC
LIMIT 5;


														-- Exercici 2
                                                        
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

select  comp.country, avg(amount) as promedio_ventas from transaction  as trans
left join company as comp on trans.company_id = comp.id
where trans.declined = 0
group by 1
order by promedio_ventas desc;


                                                        -- Exercici 3
                                                        
/*En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer 
-- competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions 
-- realitzades per empreses que estan situades en el mateix país que aquesta companyia.*/
/* (Mostra el llistat aplicant JOIN i subconsultes.)
 (Mostra el llistat aplicant solament subconsultes.)*/


                                                      -- Opción con Join 
-- subconsulta (pais de la empresa)

SELECT country FROM company
where company_name = 'Non Institute';

select * from transaction as trans 
join company as comp
on trans.company_id= comp.id
where comp.country =(SELECT country FROM company
                     where company_name = 'Non Institute');

														-- Opción sin Join 
select * from transaction
where company_id in 
      (select id from company where country =
              (SELECT country FROM company where company_name = 'Non Institute'));


                                                     -- Nivel 3


                                                    -- Exercici 1 
                                                    
  /*Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès 
  entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
  Ordena els resultats de major a menor quantitat.*/  
  
  select comp.company_name, comp.phone,comp.country,timestamp, trans.amount from transaction as trans
  join company as comp on trans.company_id = comp.id
  where amount between 100 and 200 and date(timestamp) in ('2021-04-29', '2021-07-20', '2022-03-13')
  order by amount desc;
  
                                                  -- Exercici 2
                                                  
/*Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen 
més de 4 transaccions o menys.*/


select trans.company_id, comp.company_name, count(trans.id) as nu_transacciones,
 case 
when count(trans.id) > 4 then 'SI'
when count(trans.id) <= 4 then 'NO' 
end as  Mas_de_4_transacciones
from transaction as trans
Join company as comp
on trans.company_id = comp.id
group by trans.company_id,comp.company_name;


													