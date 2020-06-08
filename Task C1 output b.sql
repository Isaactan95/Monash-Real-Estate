--Address
SELECT COUNT(*) FROM mre_address;

SELECT COUNT(DISTINCT(address_id)) FROM mre_address;

SELECT COUNT(DISTINCT(street)) FROM mre_address;

SELECT COUNT(*) FROM (
SELECT DISTINCT(street), suburb, postcode FROM mre_address);

SELECT COUNT(*)
	FROM mre_address
		WHERE NOT address_id IN (SELECT address_id FROM mre_property)
		AND NOT address_id IN (SELECT address_id FROM mre_person);

--Advertisement
SELECT COUNT(*) FROM mre_advertisement;

SELECT COUNT(DISTINCT(advert_id)) FROM mre_advertisement;

SELECT COUNT(DISTINCT(advert_name)) FROM mre_advertisement; 

--Agent
SELECT COUNT(*) FROM mre_agent;

SELECT COUNT(*)
	FROM (SELECT * FROM mre_person p, mre_agent a
		WHERE p.person_id = a.person_id);

SELECT *
	FROM mre_agent
        WHERE NOT person_id IN (SELECT person_id FROM mre_person);
		
DELETE FROM mre_agent WHERE NOT person_id IN (SELECT person_id FROM MRE_person);

SELECT * FROM mre_agent WHERE salary < 0;

DELETE FROM mre_agent WHERE salary < 0;

SELECT COUNT(*) FROM mre_agent;

--Agent_Office
SELECT COUNT(*) FROM mre_agent_office;

SELECT COUNT(DISTINCT(person_id)) FROM mre_agent_office;

SELECT *
    FROM mre_agent_office
        WHERE NOT person_id IN (SELECT person_id FROM mre_agent);

DELETE FROM mre_agent_office WHERE NOT person_id IN (SELECT person_id FROM mre_agent);

SELECT COUNT(*) FROM mre_agent_office;

--Client
SELECT COUNT(*) FROM mre_client;

SELECT COUNT(*) FROM mre_person p, mre_client c
	WHERE p.person_id = c.person_id;
    
SELECT *
    FROM mre_client
        WHERE NOT person_id IN (SELECT person_id FROM mre_person);

DELETE FROM mre_client
	WHERE NOT person_id IN (SELECT person_id FROM mre_person);

SELECT * FROM mre_client
	WHERE max_budget < min_budget;

DELETE FROM mre_client
	WHERE max_budget < min_budget;

SELECT COUNT(*) FROM mre_client;

--Client_Wish
SELECT COUNT(*) FROM mre_client_wish;

--Feature
SELECT COUNT(*) FROM mre_feature;

--Office
SELECT COUNT(*) FROM mre_office;

--Person
SELECT COUNT(*) FROM mre_person;

SELECT COUNT(DISTINCT(person_id)) FROM mre_person;

SELECT person_id
	FROM mre_person
		GROUP BY person_id
			HAVING COUNT(*) > 1;

DELETE FROM mre_person p
	WHERE rowid > (SELECT MIN(rowid)FROM mre_person p2
		WHERE p.person_id = p2.person_id);

SELECT COUNT(*) FROM mre_person;

--Postcode
SELECT COUNT(*) FROM mre_postcode;

--Property
SELECT COUNT(*) FROM mre_property;

SELECT COUNT(DISTINCT(property_id)) FROM mre_property;

SELECT *
    FROM mre_property p
        WHERE rowid > (SELECT MIN(rowid)FROM mre_property p2
		WHERE p.property_id = p2.property_id); 

DELETE FROM mre_property p
	WHERE rowid > (SELECT MIN(rowid)FROM mre_property p2
		WHERE p.property_id = p2.property_id);

SELECT COUNT(*) FROM mre_property;

--Property_Advert
SELECT COUNT(*) FROM mre_property_advert;

---Property_Feature
SELECT COUNT(*) FROM mre_property_feature;

--Rent
SELECT COUNT(*) FROM mre_rent;

SELECT * FROM mre_rent WHERE rent_end_date < rent_start_date;

DELETE FROM mre_rent
	WHERE rent_id IN (SELECT rent_id
						FROM mre_rent
							WHERE rent_end_date < rent_start_date);

SELECT COUNT(*) FROM mre_rent;

--Sale
SELECT COUNT(*) FROM mre_sale;

--State
SELECT * FROM mre_state;

DELETE FROM mre_state WHERE state_code IS NULL;

SELECT COUNT(*) FROM mre_state;

--Visit
SELECT COUNT(*) FROM mre_visit;

SELECT *
	FROM mre_visit
		WHERE NOT agent_person_id IN (SELECT person_ID FROM mre_agent)
		OR NOT client_person_id IN (SELECT person_id FROM mre_client);

DELETE FROM mre_visit
	WHERE NOT agent_person_id IN (SELECT person_ID FROM mre_agent)
	OR NOT client_person_id IN (SELECT person_id FROM mre_client);

SELECT COUNT(*) FROM mre_visit;


--Special Case
SELECT *
	FROM mre_person
		WHERE NOT address_id IN (SELECT address_id FROM mre_address);

SELECT *
	FROM mre_client
		WHERE person_id = 7001;

SELECT *
	FROM mre_client_wish
		WHERE person_id = 7001;

SELECT *
	FROM mre_feature
		WHERE feature_code = 726;

DELETE FROM mre_person
	WHERE person_id = 7001;

DELETE FROM mre_client
	WHERE person_id = 7001;

DELETE FROM mre_client_wish
	WHERE person_id = 7001;

DELETE FROM mre_feature
	WHERE feature_code = 726;

COMMIT;