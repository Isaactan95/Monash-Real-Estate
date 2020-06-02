-- Task C 1c)
-- Level 0 multi-fact star schema
DROP TABLE Scale_DIM;
DROP TABLE Feature_Cat_DIM;
DROP TABLE Property_DIM;
DROP TABLE Property_Feature_Bridge;
DROP TABLE Feature_DIM;
DROP TABLE Suburb_DIM;
DROP TABLE Postcode_DIM;
DROP TABLE State_DIM;
DROP TABLE Advertisement_DIM;
DROP TABLE Agent_DIM;
DROP TABLE Agent_Office_DIM;
DROP TABLE Office_DIM;
DROP TABLE Budget_DIM;
DROP TABLE Rent_Price_DIM;
DROP TABLE Season_DIM;
DROP TABLE Time_DIM;
DROP TABLE Visit_Time_DIM;

--------------------------------
-- Implement dimension tables --
--------------------------------
-- Scale_DIM
CREATE TABLE Scale_DIM (
    Scale_id VARCHAR2(3) NOT NULL,
    Scale_description VARCHAR2(100)
);

INSERT INTO Scale_DIM VALUES ('XS', 'Extra small: <= 1 bedroom');
INSERT INTO Scale_DIM VALUES ('S', 'Small: 2-3 bedrooms');
INSERT INTO Scale_DIM VALUES ('M', 'Medium: 3-6 bedrooms');
INSERT INTO Scale_DIM VALUES ('L', 'Large: 6-10 bedrooms');
INSERT INTO Scale_DIM VALUES ('XL', 'Extra large: > 10 bedrooms');

-- Feature_Cat_DIM
CREATE TABLE Feature_Cat_DIM (
    Feature_cat_id NUMBER,
    Feature_cat_description VARCHAR2(100)
);

INSERT INTO Feature_Cat_DIM VALUES (1, 'Very basic: < 10 features');
INSERT INTO Feature_Cat_DIM VALUES (2, 'Standard: 10-20 features');
INSERT INTO Feature_Cat_DIM VALUES (3, 'Luxurious: > 20 features');
    
-- Property_DIM
CREATE TABLE Property_DIM AS (
    SELECT 
        p.Property_id,
        a.Suburb
    FROM MRE_Property p, MRE_Address a
    WHERE p.address_id = a.address_id
);    

-- Property_Feature_Bridge
CREATE TABLE Property_Feature_Bridge AS (
    SELECT DISTINCT * FROM MRE_Property_Feature
);

-- Feature_DIM
CREATE TABLE Feature_DIM AS (
    SELECT DISTINCT * FROM MRE_Feature
);    

-- Suburb_DIM
CREATE TABLE Suburb_DIM AS (
    SELECT DISTINCT
        suburb,
        postcode
    FROM MRE_Address    
);

-- Postcode_DIM
CREATE TABLE Postcode_DIM AS (
    SELECT DISTINCT * FROM MRE_Postcode
);    


-- State_DIM
CREATE TABLE State_DIM AS (
    SELECT DISTINCT * FROM MRE_State
);    

-- Advertisement_DIM
CREATE TABLE Advertisement_DIM AS (
    SELECT DISTINCT * FROM MRE_Advertisement
);    

-- Agent_DIM
CREATE TABLE Agent_DIM AS (
    SELECT DISTINCT Person_id FROM MRE_Agent
);

-- Agent_Office_DIM
CREATE TABLE Agent_Office_DIM AS (
    SELECT DISTINCT * FROM MRE_Agent_Office
);

-- Office_DIM
CREATE TABLE Office_DIM AS (
    SELECT DISTINCT * FROM MRE_Office
);

-- Budget_DIM
CREATE TABLE Budget_DIM (
    Budget_id VARCHAR2(2),
    Budget_description VARCHAR2(100),
    Min_budget NUMBER,
    Max_budget NUMBER    
);

INSERT INTO Budget_DIM VALUES ('L', 'Low [0 to 1,000]', 0, 1000);
INSERT INTO Budget_DIM VALUES ('LM', 'Low-Medium [0 to 100,000]', 0, 100000);
INSERT INTO Budget_DIM VALUES ('M', 'Medium [1,001 to 100,000]', 1001, 100000);
INSERT INTO Budget_DIM VALUES ('MH', 'High [1,001 to 10,000,000]', 1001, 10000000);
INSERT INTO Budget_DIM VALUES ('H', 'High [100,001 to 10,000,000]', 100001, 10000000);

-- Client_DIM
CREATE TABLE Client_DIM AS (
    SELECT * FROM MRE_Client
);    

-- Rent_Price_DIM
CREATE TABLE Rent_Price_DIM AS (
    SELECT DISTINCT
        Property_id,
        Rent_start_date AS Start_date,
        Rent_end_date AS End_date,
        Price
    FROM MRE_Rent    
);

-- Season_DIM
CREATE TABLE Season_DIM (
    Season_ID NUMBER,
    Season_Description VARCHAR2(10)
);

INSERT INTO Season_DIM VALUES (1, 'Summer');
INSERT INTO Season_DIM VALUES (2, 'Autumn');
INSERT INTO Season_DIM VALUES (3, 'Winter');
INSERT INTO Season_DIM VALUES (4, 'Spring');

-- Time_DIM
CREATE TABLE Time_DIM AS (
    SELECT DISTINCT
        TO_CHAR(d.dates, 'YYYY') || '_' || TO_CHAR(d.dates, 'MM') AS Time_ID,
        TO_CHAR(d.dates, 'YYYY') AS Year,
        TO_NUMBER(TO_CHAR(d.dates, 'MM'), '99') AS Month
    FROM (
        SELECT DISTINCT Sale_Date AS DATES FROM MRE_Sale
        UNION 
        SELECT DISTINCT Rent_Start_Date FROM MRE_Rent
        UNION 
        SELECT DISTINCT Rent_End_Date FROM MRE_Rent
        ) d
);    
      
ALTER TABLE Time_DIM
ADD Season_ID NUMBER;

UPDATE Time_DIM
SET Season_ID = 
    (CASE
        WHEN Month = 12 OR Month BETWEEN 1 AND 2 THEN 1
        WHEN Month BETWEEN 3 AND 5 THEN 2
        WHEN Month BETWEEN 6 AND 8 THEN 3
        WHEN Month BETWEEN 9 AND 11 THEN 4
    END);    
-- SELECT * FROM Time_DIM;    
    

-- Visit_Time_DIM
CREATE TABLE Visit_Time_DIM AS (
    SELECT * 
    FROM (
        SELECT DISTINCT
            TO_NUMBER(TO_CHAR(visit_date, 'MM'), '99') AS Month
        FROM (WITH d AS (SELECT TRUNC(TO_DATE('01', 'MM')) - 1 AS dt FROM dual)
            SELECT dt + LEVEL AS visit_date
            FROM d
            CONNECT BY LEVEL <= ADD_MONTHS(dt, 12) - dt)
        ORDER BY Month ASC), 
        (
        SELECT DISTINCT
            TO_NUMBER(TO_CHAR(visit_date, 'D'), '9') AS Day_of_week
        FROM (WITH d AS (SELECT TRUNC(TO_DATE('01', 'MM')) - 1 AS dt FROM dual )
            SELECT dt + LEVEL AS visit_date
            FROM d
            CONNECT BY LEVEL <= ADD_MONTHS(dt, 1) - dt)
        ORDER BY Day_of_week ASC)
);

ALTER TABLE Visit_Time_DIM
ADD (   
    Visit_Time_ID CHAR(4),
    Season_ID NUMBER
);

UPDATE Visit_Time_DIM
SET Visit_Time_ID = Month || '_' || Day_of_Week,
    Season_ID = 
        (CASE
            WHEN Month = 12 OR Month BETWEEN 1 AND 2 THEN 1
            WHEN Month BETWEEN 3 AND 5 THEN 2
            WHEN Month BETWEEN 6 AND 8 THEN 3
            WHEN Month BETWEEN 9 AND 11 THEN 4
        END);   
-- SELECT * FROM Visit_Time_DIM;

---------------------------
-- Implement fact tables --
---------------------------
-- MRE_SR_FACT


-- MRE_Client_FACT
CREATE TABLE MRE_Client_FACT AS (
    SELECT 
        Person_ID AS Client_Person_ID,
        Min_Budget,
        Max_Budget,
        COUNT(Person_ID) AS Number_of_Clients
    FROM Client_DIM
    GROUP BY Person_ID, Min_Budget, Max_Budget
);
-- SELECT * FROM MRE_Client_FACT WHERE Number_of_Clients > 1;

ALTER TABLE MRE_Client_FACT
ADD Budget_ID VARCHAR2(2);

UPDATE MRE_Client_FACT
SET Budget_ID = 
    (CASE
        WHEN Min_Budget >= 0 AND Max_Budget <= 1000 THEN 'L'
        WHEN Min_Budget >= 1001 AND Max_Budget <= 100000 THEN 'M'
        WHEN Min_Budget >= 100001 AND Max_Budget <= 10000000 THEN 'H'
    END);    

UPDATE MRE_Client_FACT
SET Budget_ID = 
    (CASE
        WHEN Min_Budget >= 0 AND Max_Budget <= 100000 THEN 'LM'
        WHEN Min_Budget >= 1001 AND Max_Budget <= 10000000 THEN 'MH'
    END)
WHERE Budget_ID IS NULL;    

ALTER TABLE MRE_Client_FACT
DROP (Min_Budget, Max_Budget);
-- SELECT * FROM MRE_Client_FACT;
-- SELECT * FROM MRE_Client_FACT WHERE Budget_ID IS NULL;


-- MRE_Agent_FACT
CREATE TABLE MRE_Agent_FACT AS (
    SELECT 
        a.person_id AS Agent_Person_ID,
        p.gender
    FROM Agent_DIM a, Person    
    
);

-- MRE_Visit_FACT


-- MRE_Advert_FACT


