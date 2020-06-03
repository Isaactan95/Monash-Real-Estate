-- Task C 2b)
-- Level 0 multi-fact star schema
DROP TABLE Scale_DIM;
DROP TABLE Feature_Cat_DIM;
DROP TABLE Property_DIM;
DROP TABLE Property_Feature_Bridge;
DROP TABLE Feature_DIM;
DROP TABLE Property_Type_DIM;
DROP TABLE Address_DIM;
DROP TABLE Suburb_DIM;
DROP TABLE Postcode_DIM;
DROP TABLE State_DIM;
DROP TABLE Advertisement_DIM;
DROP TABLE Person_DIM;
DROP TABLE Agent_Office_DIM;
DROP TABLE Office_DIM;
DROP TABLE Budget_DIM;
DROP TABLE Rent_Price_DIM;
DROP TABLE Season_DIM;
DROP TABLE Time_DIM;
--DROP TABLE Visit_Time_DIM;

--------------------------------
-- Implement dimension tables --
--------------------------------
-- Scale_DIM
CREATE TABLE Scale_DIM (
    Scale_id NUMBER,
    Scale_description VARCHAR2(100)
);

INSERT INTO Scale_DIM VALUES (1, 'Extra small: <= 1 bedroom');
INSERT INTO Scale_DIM VALUES (2, 'Small: 2-3 bedrooms');
INSERT INTO Scale_DIM VALUES (3, 'Medium: 3-6 bedrooms');
INSERT INTO Scale_DIM VALUES (4, 'Large: 6-10 bedrooms');
INSERT INTO Scale_DIM VALUES (5, 'Extra large: > 10 bedrooms');

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

-- Property_Type_DIM
CREATE TABLE Property_Type_DIM AS (
    SELECT 
        ROW_NUMBER() OVER(ORDER BY 1) AS Type_ID,
        Type_Description
    FROM (SELECT DISTINCT    
            Property_Type AS Type_Description
          FROM MRE_Property)
);

-- Address_DIM
CREATE TABLE Address_DIM AS (
    SELECT DISTINCT
        Address_ID,
        Street,
        Suburb
    FROM MRE_Address    
);

-- Suburb_DIM
CREATE TABLE Suburb_DIM AS (
    SELECT DISTINCT
        Suburb,
        Postcode
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

-- Person_DIM
CREATE TABLE Person_DIM AS (
    SELECT DISTINCT
        Person_ID,
        First_Name,
        Last_Name,
        Gender,
        Address_ID
    FROM MRE_Person    
);

-- Agent_Office_DIM
CREATE TABLE Agent_Office_DIM AS (
    SELECT DISTINCT 
        Person_ID AS Agent_Person_ID,
        Office_ID
    FROM MRE_Agent_Office
);

-- Office_DIM
CREATE TABLE Office_DIM AS (
    SELECT DISTINCT * FROM MRE_Office
);

-- Budget_DIM
CREATE TABLE Budget_DIM (
    Budget_ID NUMBER,
    Budget_description VARCHAR2(100),
    Min_budget NUMBER,
    Max_budget NUMBER    
);

INSERT INTO Budget_DIM VALUES (1, 'Low [0 to 1,000]', 0, 1000);
INSERT INTO Budget_DIM VALUES (2, 'Low-Medium [0 to 100,000]', 0, 100000);
INSERT INTO Budget_DIM VALUES (3, 'Medium [1,001 to 100,000]', 1001, 100000);
INSERT INTO Budget_DIM VALUES (4, 'High [1,001 to 10,000,000]', 1001, 10000000);
INSERT INTO Budget_DIM VALUES (5, 'High [100,001 to 10,000,000]', 100001, 10000000);

-- Client_DIM
CREATE TABLE Client_DIM AS (
    SELECT * FROM MRE_Client
);    

-- Rental_Period_DIM
CREATE TABLE Rental_Period_DIM (
    Rental_Period_ID NUMBER,
    Rental_period_Description VARCHAR2(60)
);

INSERT INTO Rental_Period_DIM VALUES (1, 'Short: < 6 months');
INSERT INTO Rental_Period_DIM VALUES (2, 'Medium: 6 - 12 months');
INSERT INTO Rental_Period_DIM VALUES (3, 'Long: > 12 months');

-- Rent_Price_DIM
CREATE TABLE Rent_Price_DIM AS (
    SELECT DISTINCT
        Property_ID,
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
        TO_CHAR(d.dates, 'YYYYMMDY') AS Time_ID,
        TO_CHAR(d.dates, 'YYYY') AS Year,
        TO_NUMBER(TO_CHAR(d.dates, 'MM'), '99') AS Month,
        TO_CHAR(d.dates, 'DY') AS Day_of_Week
    FROM (
        SELECT DISTINCT Sale_Date AS DATES FROM MRE_Sale
            WHERE Sale_Date IS NOT NULL
        UNION 
        SELECT DISTINCT Rent_Start_Date FROM MRE_Rent
            WHERE Rent_Start_Date IS NOT NULL
        UNION 
        SELECT DISTINCT Rent_End_Date FROM MRE_Rent
            WHERE Rent_End_Date IS NOT NULL
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

/*
-- Visit_Time_DIM
CREATE TABLE Visit_Time_DIM AS (
    SELECT * 
    FROM (
        SELECT DISTINCT
            TO_CHAR(visit_date, 'MM') AS Month
        FROM (WITH d AS (SELECT TRUNC(TO_DATE('01', 'MM')) - 1 AS dt FROM dual)
            SELECT dt + LEVEL AS visit_date
            FROM d
            CONNECT BY LEVEL <= ADD_MONTHS(dt, 12) - dt)
        ORDER BY Month ASC), 
        (
        SELECT DISTINCT
            TO_CHAR(visit_date, 'DY') AS Day_of_week
        FROM (WITH d AS (SELECT TRUNC(TO_DATE('01', 'MM')) - 1 AS dt FROM dual )
            SELECT dt + LEVEL AS visit_date
            FROM d
            CONNECT BY LEVEL <= ADD_MONTHS(dt, 1) - dt)
        ORDER BY Day_of_week ASC)
);

ALTER TABLE Visit_Time_DIM
ADD (   
    Visit_Time_ID VARCHAR2(5),
    Season_ID NUMBER
);

UPDATE Visit_Time_DIM
SET Visit_Time_ID = Month || Day_of_Week,
    Season_ID = 
        (CASE
            WHEN Month = 12 OR Month BETWEEN 1 AND 2 THEN 1
            WHEN Month BETWEEN 3 AND 5 THEN 2
            WHEN Month BETWEEN 6 AND 8 THEN 3
            WHEN Month BETWEEN 9 AND 11 THEN 4
        END);   
*/
---------------------------
-- Implement fact tables --
---------------------------
-- MRE_Sale_FACT
CREATE TABLE MRE_Sale_TempFACT AS (
    SELECT 
        s.Agent_Person_ID,
        s.Client_Person_ID,
        s.Sale_Date,
        s.Property_ID,
        pt.Type_ID,
        s.Price AS Total_Sales_Price,
        COUNT(s.Sale_ID) AS Number_of_Sales
    FROM MRE_Sale s, MRE_Property p, Property_Type_DIM pt
    WHERE s.Property_ID = p.Property_ID
    AND s.Client_Person_ID IS NOT NULL
    AND s.Sale_Date IS NOT NULL
    AND pt.Type_Description = p.Property_Type
    GROUP BY s.Agent_Person_ID, s.Client_Person_ID, s.Sale_Date, s.Property_ID, pt.Type_ID, s.Price
);    

ALTER TABLE MRE_Sale_TempFACT
ADD Time_ID CHAR(6);
    
UPDATE MRE_Sale_TempFACT 
SET Time_ID = TO_CHAR(Sale_Date, 'YYYYMM');
     
CREATE TABLE MRE_Sale_FACT AS ( 
    SELECT 
        Agent_Person_ID,
        Client_Person_ID,
        Time_ID,
        Property_ID,
        Type_ID,
        Total_Sales_Price,
        Number_of_Sales
    FROM MRE_Sale_TempFACT
);            

-- MRE_Rent_FACT
CREATE TABLE MRE_Rent_TempFACT AS (
    SELECT
        r.Agent_Person_ID,
        r.Client_Person_ID,
        r.Property_ID,
        r.Rent_Start_Date,
        r.Rent_End_Date,
        p.Property_No_of_Bedrooms AS Number_of_bedrooms,
        COUNT(pf.Feature_Code) AS Number_of_features,
        COUNT(DISTINCT r.Rent_ID) AS Number_of_Rent
    FROM MRE_Rent r, MRE_Property p, MRE_Property_Feature pf
    WHERE r.Property_ID = p.Property_ID
    AND pf.Property_ID = p.Property_ID
    AND r.Client_Person_ID IS NOT NULL
    AND r.Rent_Start_Date IS NOT NULL
    AND r.Rent_End_Date IS NOT NULL
    GROUP BY r.Agent_Person_ID, r.Client_Person_ID, r.Property_ID, r.Rent_Start_Date, r.Rent_End_Date, p.Property_No_of_Bedrooms
);

ALTER TABLE MRE_Rent_TempFACT 
ADD (Scale_ID NUMBER,
     Feature_Cat_ID NUMBER);
     
UPDATE MRE_Rent_TempFACT
SET Feature_Cat_ID = 
        (CASE
            WHEN Number_of_features < 10 THEN 1
            WHEN Number_of_features BETWEEN 10 AND 20 THEN 2
            WHEN Number_of_features > 20 THEN 3
        END),
    Scale_ID = 
        (CASE
            WHEN Number_of_bedrooms <= 1 THEN 1
            WHEN Number_of_bedrooms BETWEEN 2 AND 3 THEN 2
            WHEN Number_of_bedrooms BETWEEN 4 AND 6 THEN 3
            --WHEN Number_of_bedrooms BETWEEN 3 AND 6 THEN 3
            WHEN Number_of_bedrooms BETWEEN 7 AND 10 THEN 4
            --WHEN Number_of_bedrooms BETWEEN 6 AND 10 THEN 4
            WHEN Number_of_bedrooms > 10 THEN 5
        END);    

CREATE TABLE MRE_Rent_FACT AS (
    SELECT
        Agent_Person_ID,
        Client_Person_ID,
        Property_ID,
        Rent_Start_Date,
        Rent_End_Date,
        Scale_ID,
        Feature_Cat_ID,
        Number_of_Rent
    FROM MRE_Rent_TempFACT   
);   

-- MRE_Client_FACT
CREATE TABLE MRE_Client_TempFACT AS (
    SELECT 
        Person_ID AS Client_Person_ID,
        Min_Budget,
        Max_Budget,
        COUNT(Person_ID) AS Number_of_Clients
    FROM Client_DIM
    GROUP BY Person_ID, Min_Budget, Max_Budget
);

ALTER TABLE MRE_Client_TempFACT
ADD Budget_ID VARCHAR2(2);

UPDATE MRE_Client_TempFACT
SET Budget_ID = 
    (CASE
        WHEN Min_Budget >= 0 AND Max_Budget <= 1000 THEN 1
        WHEN Min_Budget >= 1001 AND Max_Budget <= 100000 THEN 3
        WHEN Min_Budget >= 100001 AND Max_Budget <= 10000000 THEN 5
    END);    

UPDATE MRE_Client_TempFACT
SET Budget_ID = 
    (CASE
        WHEN Min_Budget >= 0 AND Max_Budget <= 100000 THEN 2
        WHEN Min_Budget >= 1001 AND Max_Budget <= 10000000 THEN 4
    END)
WHERE Budget_ID IS NULL;    

CREATE TABLE MRE_Client_FACT AS (
    SELECT 
        Client_Person_ID,
        Budget_ID,
        Number_of_Clients
    FROM MRE_Client_TempFACT
);    

-- MRE_Agent_FACT
CREATE TABLE MRE_Agent_FACT AS (
    SELECT 
        a.person_id AS Agent_Person_ID,
        p.gender,
        a.salary AS Total_Earnings
    FROM MRE_Agent a, Person_DIM p
    WHERE a.person_id = p.person_id
);

-- MRE_Visit_FACT
CREATE TABLE MRE_Visit_TempFACT AS (
    SELECT DISTINCT 
        Client_Person_ID,
        Agent_Person_ID,
        Property_ID,
        Visit_Date,
        COUNT(*) AS Number_of_Visits
    FROM MRE_Visit 
    GROUP BY Client_Person_ID, Agent_Person_ID, Property_ID, Visit_Date
);

ALTER TABLE MRE_Visit_TempFACT 
ADD Visit_Time_ID VARCHAR2(5);

UPDATE MRE_Visit_TempFACT
SET Visit_Time_ID = TO_CHAR(Visit_Date, 'MM') || TO_CHAR(Visit_Date, 'DY');

CREATE TABLE MRE_Visit_FACT AS (
    SELECT 
        Client_Person_ID,
        Agent_Person_ID,
        Property_ID,
        Visit_Time_ID,
        Number_of_Visits
    FROM MRE_Visit_TempFACT    
);

-- MRE_Advert_FACT
CREATE TABLE MRE_Advert_TempFACT AS (
    SELECT DISTINCT
        pa.Property_ID,
        pa.Advert_ID,
        p.Property_Date_Added,
        COUNT(pa.Advert_ID) AS Number_of_Adverts
    FROM MRE_Property_Advert pa, MRE_Property p 
    WHERE pa.property_id = p.property_id
    GROUP BY pa.Property_ID, pa.Advert_ID, p.Property_Date_Added
);

ALTER TABLE MRE_Advert_TempFACT
ADD Time_ID CHAR(6);

UPDATE MRE_Advert_TempFACT
SET Time_ID = TO_CHAR(Property_Date_Added, 'YYYYMM');

CREATE TABLE MRE_Advert_FACT AS (
    SELECT
        Property_ID,
        Advert_ID,
        Time_ID,
        Number_of_Adverts
    FROM MRE_Advert_TempFACT    
);

----------------------------------------------------
-- Two-column methodology checking of fact tables --
----------------------------------------------------
-- MRE_Sale_FACT
SELECT SUM(Total_Sales_Price), SUM(Number_of_Sales) FROM MRE_Sale_FACT; -- 702,593,752 and 916
SELECT Agent_Person_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT GROUP BY Agent_Person_ID ORDER BY Agent_Person_ID; -- 702,593,752 and 916
SELECT Client_Person_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT GROUP BY Client_Person_ID ORDER BY Client_Person_ID; -- 702,593,752 and 916 
SELECT Time_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT GROUP BY Time_ID ORDER BY Time_ID; -- 702,593,752 and 916 
SELECT Property_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT GROUP BY Property_ID ORDER BY Property_ID; -- 702,593,752 and 916  
SELECT Type_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT GROUP BY Type_ID ORDER BY Type_ID; -- 702,593,752 and 916  

-- MRE_Rent_FACT
SELECT SUM(Number_of_Rent) FROM MRE_Rent_FACT; -- 1116
SELECT Agent_Person_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT GROUP BY Agent_Person_ID ORDER BY Agent_Person_ID; -- 1116
SELECT Client_Person_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT GROUP BY Client_Person_ID ORDER BY Client_Person_ID; -- 1116
SELECT Property_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT GROUP BY Property_ID ORDER BY Property_ID; -- 1116
SELECT Rent_Start_Date, SUM(Number_Of_Rent) FROM MRE_Rent_FACT GROUP BY Rent_Start_Date ORDER BY Rent_Start_Date; -- 1116
SELECT Rent_End_Date, SUM(Number_Of_Rent) FROM MRE_Rent_FACT GROUP BY Rent_End_Date ORDER BY Rent_End_Date; -- 1116
SELECT Scale_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT GROUP BY Scale_ID ORDER BY Scale_ID; -- 1116
SELECT Feature_Cat_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT GROUP BY Feature_Cat_ID ORDER BY Feature_Cat_ID; -- 1116

-- MRE_Client_FACT
SELECT SUM(Number_Of_Clients) FROM MRE_Client_FACT; -- 3339
SELECT Client_Person_ID, SUM(Number_Of_Clients) FROM MRE_Client_FACT GROUP BY Client_Person_ID ORDER BY Client_Person_ID; -- 3339
SELECT Budget_ID, SUM(Number_Of_Clients) FROM MRE_Client_FACT GROUP BY Budget_ID ORDER BY Budget_ID; -- 3339

-- MRE_Agent_FACT
SELECT SUM(Total_Earnings) FROM MRE_Agent_FACT; -- 477,290,000
SELECT Agent_Person_ID, SUM(Total_Earnings) FROM MRE_Agent_FACT GROUP BY Agent_Person_ID ORDER BY Agent_Person_ID; -- 477,290,000
SELECT Gender, SUM(Total_Earnings) FROM MRE_Agent_FACT GROUP BY Gender ORDER BY Gender; -- 477,290,000


-- MRE_Visit_FACT
SELECT SUM(Number_of_Visits) FROM MRE_Visit_FACT; -- 575
SELECT Client_Person_ID, SUM(Number_of_Visits) FROM MRE_Visit_FACT GROUP BY Client_Person_ID ORDER BY Client_Person_ID; -- 575
SELECT Agent_Person_ID, SUM(Number_of_Visits) FROM MRE_Visit_FACT GROUP BY Agent_Person_ID ORDER BY Agent_Person_ID; -- 575
SELECT Property_ID, SUM(Number_of_Visits) FROM MRE_Visit_FACT GROUP BY Property_ID ORDER BY Property_ID; -- 575
SELECT Visit_Time_ID, SUM(Number_of_Visits) FROM MRE_Visit_FACT GROUP BY Visit_Time_ID ORDER BY Visit_Time_ID; -- 575

-- MRE_Advert_FACT
SELECT SUM(Number_of_Adverts) FROM MRE_Advert_FACT; -- 3646
SELECT Property_ID, SUM(Number_of_Adverts) FROM MRE_Advert_FACT GROUP BY Property_ID ORDER BY Property_ID; -- 3646
SELECT Advert_ID, SUM(Number_of_Adverts) FROM MRE_Advert_FACT GROUP BY Advert_ID ORDER BY Advert_ID; -- 3646
SELECT Time_ID, SUM(Number_of_Adverts) FROM MRE_Advert_FACT GROUP BY Time_ID ORDER BY Time_ID; -- 3646
