    -- Task C 2b)
-- Level 0 multi-fact star schema
DROP TABLE MRE_Scale_DIM_lo PURGE;
DROP TABLE MRE_Feature_Cat_DIM_lo PURGE;
DROP TABLE MRE_Property_DIM_lo PURGE;
DROP TABLE MRE_Property_Feature_Bridge_lo PURGE;
DROP TABLE MRE_Feature_DIM_lo PURGE;
DROP TABLE MRE_MRE_Wishlist_DIM_L0 PURGE;
DROP TABLE MRE_Property_Type_DIM_lo PURGE;
DROP TABLE MRE_Address_DIM_lo PURGE;
DROP TABLE MRE_Postcode_DIM_lo PURGE;
DROP TABLE MRE_State_DIM_lo PURGE;
DROP TABLE MRE_Advertisement_DIM_lo PURGE;
DROP TABLE MRE_Person_DIM_lo PURGE;
DROP TABLE MRE_Agent_Office_DIM_lo PURGE;
DROP TABLE MRE_Office_DIM_lo PURGE;
DROP TABLE MRE_Budget_DIM_lo PURGE;
DROP TABLE MRE_Rental_Peroid_DIM_lo PURGE;
DROP TABLE MRE_Rent_Price_DIM_lo PURGE;
DROP TABLE MRE_Season_DIM_lo PURGE;
DROP TABLE MRE_Time_DIM_lo PURGE;
DROP TABLE MRE_Sale_FACT_lo PURGE;
DROP TABLE MRE_Rent_TempFACT_lo PURGE;
DROP TABLE MRE_Rent_FACT_lo PURGE;
DROP TABLE MRE_Client_TempFACT_lo PURGE;
DROP TABLE MRE_Client_FACT_lo PURGE;
DROP TABLE MRE_Agent_FACT_lo PURGE;
DROP TABLE MRE_Visit_TempFACT_lo PURGE;
DROP TABLE MRE_Visit_FACT_lo PURGE;
DROP TABLE MRE_Advert_FACT_lo PURGE;

--------------------------------
-- Implement dimension tables --
--------------------------------
-- MRE_Scale_DIM_L0
CREATE TABLE MRE_Scale_DIM_L0 (
    Scale_ID NUMBER,
    Scale_Description VARCHAR2(100)
);

INSERT INTO MRE_Scale_DIM_L0 VALUES (1, 'Extra small: <= 1 bedroom');
INSERT INTO MRE_Scale_DIM_L0 VALUES (2, 'Small: 2-3 bedrooms');
INSERT INTO MRE_Scale_DIM_L0 VALUES (3, 'Medium: 3-6 bedrooms');
INSERT INTO MRE_Scale_DIM_L0 VALUES (4, 'Large: 6-10 bedrooms');
INSERT INTO MRE_Scale_DIM_L0 VALUES (5, 'Extra large: > 10 bedrooms');

-- MRE_Feature_CAT_DIM_L0
CREATE TABLE MRE_Feature_CAT_DIM_L0 (
    Feature_CAT_ID NUMBER,
    Feature_CAT_Description VARCHAR2(100)
);

INSERT INTO MRE_Feature_CAT_DIM_L0 VALUES (1, 'Very basic: < 10 features');
INSERT INTO MRE_Feature_CAT_DIM_L0 VALUES (2, 'Standard: 10-20 features');
INSERT INTO MRE_Feature_CAT_DIM_L0 VALUES (3, 'Luxurious: > 20 features');
    
-- MRE_Property_DIM_L0
CREATE TABLE MRE_Property_DIM_L0 AS (
    SELECT 
        p.Property_ID,
        p.Property_Date_Added,
        a.Suburb
    FROM MRE_Property p, MRE_Address a
    WHERE p.Address_ID = a.Address_ID
);    

-- Property_Feature_Bridge_L0
CREATE TABLE Property_Feature_Bridge_L0 AS (
    SELECT DISTINCT * FROM MRE_Property_Feature
);

-- MRE_Feature_DIM_L0
CREATE TABLE MRE_Feature_DIM_L0 AS (
    SELECT DISTINCT * FROM MRE_Feature
);    

-- MRE_Wishlist_DIM_L0
CREATE TABLE MRE_Wishlist_DIM_L0 AS (
    SELECT 
        Person_ID AS Client_Person_ID,
        Feature_Code    
    FROM MRE_Client_Wish
);

-- MRE_Property_Type_DIM_L0
CREATE TABLE MRE_Property_Type_DIM_L0 AS (
    SELECT 
        ROW_NUMBER() OVER(ORDER BY 1) AS Type_ID,
        Type_Description
    FROM (SELECT DISTINCT    
            Property_Type AS Type_Description
          FROM MRE_Property)
);

-- MRE_Address_DIM_L0
CREATE TABLE MRE_Address_DIM_L0 AS (
    SELECT DISTINCT
        Address_ID,
        Street,
        Suburb,
        Postcode
    FROM MRE_Address    
);

-- MRE_Postcode_DIM_L0
CREATE TABLE MRE_Postcode_DIM_L0 AS (
    SELECT DISTINCT * FROM MRE_Postcode
);    

-- MRE_State_DIM_L0
CREATE TABLE MRE_State_DIM_L0 AS (
    SELECT DISTINCT * FROM MRE_State
);    

-- MRE_Advertisement_DIM_L0
CREATE TABLE MRE_Advertisement_DIM_L0 AS (
    SELECT DISTINCT * FROM MRE_Advertisement
);    

-- MRE_Person_DIM_L0
CREATE TABLE MRE_Person_DIM_L0 AS (
    SELECT DISTINCT
        Person_ID,
        First_Name,
        Last_Name,
        Gender,
        Address_ID
    FROM MRE_Person    
);

-- MRE_Agent_Office_DIM_L0
CREATE TABLE MRE_Agent_Office_DIM_L0 AS (
    SELECT DISTINCT 
        Person_ID AS Agent_Person_ID,
        Office_ID
    FROM MRE_Agent_Office
);

-- MRE_Office_DIM_L0
CREATE TABLE MRE_Office_DIM_L0 AS (
    SELECT DISTINCT * FROM MRE_Office
);

-- MRE_Budget_DIM_L0
CREATE TABLE MRE_Budget_DIM_L0 (
    Budget_ID NUMBER,
    Budget_Description VARCHAR2(100),
    Min_Budget NUMBER,
    Max_Budget NUMBER    
);

INSERT INTO MRE_Budget_DIM_L0 VALUES (1, 'Low [0 to 1,000]', 0, 1000);
INSERT INTO MRE_Budget_DIM_L0 VALUES (3, 'Medium [1,001 to 100,000]', 1001, 100000);
INSERT INTO MRE_Budget_DIM_L0 VALUES (5, 'High [100,001 to 10,000,000]', 100001, 10000000);    

-- MRE_Rental_Period_DIM_L0
CREATE TABLE MRE_Rental_Period_DIM_L0 (
    Rental_Period_ID NUMBER,
    Rental_Period_Description VARCHAR2(60)
);

INSERT INTO MRE_Rental_Period_DIM_L0 VALUES (1, 'Short: < 6 months');
INSERT INTO MRE_Rental_Period_DIM_L0 VALUES (2, 'Medium: 6 - 12 months');
INSERT INTO MRE_Rental_Period_DIM_L0 VALUES (3, 'Long: > 12 months');

-- MRE_Rent_Price_DIM_L0
CREATE TABLE MRE_Rent_Price_DIM_L0 AS (
    SELECT DISTINCT
        Property_ID,
        Rent_Start_Date AS Start_date,
        Rent_End_Date AS End_date,
        Price
    FROM MRE_Rent    
);

-- MRE_Season_DIM_L0
CREATE TABLE MRE_Season_DIM_L0 (
    Season_ID NUMBER,
    Season_Description VARCHAR2(10)
);

INSERT INTO MRE_Season_DIM_L0 VALUES (1, 'Summer');
INSERT INTO MRE_Season_DIM_L0 VALUES (2, 'Autumn');
INSERT INTO MRE_Season_DIM_L0 VALUES (3, 'Winter');
INSERT INTO MRE_Season_DIM_L0 VALUES (4, 'Spring');

-- MRE_Time_DIM_L0
CREATE TABLE MRE_Time_DIM_L0 AS (
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
      
ALTER TABLE MRE_Time_DIM_L0
ADD Season_ID NUMBER;

UPDATE MRE_Time_DIM_L0
SET Season_ID = 
    (CASE
        WHEN Month = 12 OR Month BETWEEN 1 AND 2 THEN 1
        WHEN Month BETWEEN 3 AND 5 THEN 2
        WHEN Month BETWEEN 6 AND 8 THEN 3
        WHEN Month BETWEEN 9 AND 11 THEN 4
    END);    

---------------------------
-- Implement fact tables --
---------------------------
-- MRE_Sale_FACT_L0
CREATE TABLE MRE_Sale_FACT_L0 AS (
    SELECT 
        s.Agent_Person_ID,
        s.Client_Person_ID,
        TO_CHAR(s.Sale_Date, 'YYYYMMDy') AS Time_ID,
        s.Property_ID,
        pt.Type_ID,
        s.Price AS Total_Sales_Price,
        COUNT(s.Sale_ID) AS Number_of_Sales
    FROM MRE_Sale s, MRE_Property p, MRE_Property_Type_DIM_L0 pt
    WHERE s.Property_ID = p.Property_ID
    AND s.Client_Person_ID IS NOT NULL
    AND s.Sale_Date IS NOT NULL
    AND pt.Type_Description = p.Property_Type
    GROUP BY s.Agent_Person_ID, s.Client_Person_ID, TO_CHAR(s.Sale_Date, 'YYYYMMDy'), s.Property_ID, pt.Type_ID, s.Price
);           

-- MRE_Rent_FACT_L0
CREATE TABLE MRE_Rent_TempFACT_L0 AS (
    SELECT
        r.Agent_Person_ID,
        r.Client_Person_ID,
        r.Property_ID,
        r.Rent_Start_Date,
        r.Rent_End_Date,        
        p.Property_No_of_Bedrooms AS Number_of_bedrooms,
        COUNT(pf.Feature_Code) AS Number_of_features,
        r.Price AS Weekly_Rent_Fee,
        to_number(to_char(Rent_End_Date, 'WW')) - to_number(to_char(Rent_Start_Date, 'WW')) AS Total_Weeks,
        COUNT(DISTINCT r.Rent_ID) AS Number_of_Rent
    FROM MRE_Rent r, MRE_Property p, MRE_Property_Feature pf
    WHERE r.Property_ID = p.Property_ID
    AND pf.Property_ID = p.Property_ID
    AND r.Client_Person_ID IS NOT NULL
    AND r.Rent_Start_Date IS NOT NULL
    AND r.Rent_End_Date IS NOT NULL
    GROUP BY r.Agent_Person_ID, r.Client_Person_ID, r.Property_ID, r.Rent_Start_Date, r.Rent_End_Date, 
             p.Property_No_of_Bedrooms, r.Price, TO_NUMBER(TO_CHAR(Rent_End_Date, 'WW')) - TO_NUMBER(TO_CHAR(Rent_Start_Date, 'WW'))
);

ALTER TABLE MRE_Rent_TempFACT_L0 
ADD (Rental_Period_ID NUMBER,
     Scale_ID NUMBER,
     Feature_Cat_ID NUMBER,
     Total_Rent_Fee NUMBER);
     
UPDATE MRE_Rent_TempFACT_L0
SET Rental_Period_ID = 
        (CASE
            WHEN MONTHS_BETWEEN(Rent_Start_Date, Rent_End_Date) < 6 THEN 1
            WHEN MONTHS_BETWEEN(Rent_Start_Date, Rent_End_Date) BETWEEN 6 AND 12 THEN 2
            WHEN MONTHS_BETWEEN(Rent_Start_Date, Rent_End_Date) > 12 THEN 3
        END),    
    Scale_ID = 
        (CASE
            WHEN Number_of_bedrooms <= 1 THEN 1
            WHEN Number_of_bedrooms BETWEEN 2 AND 3 THEN 2
            WHEN Number_of_bedrooms BETWEEN 4 AND 6 THEN 3            
            WHEN Number_of_bedrooms BETWEEN 7 AND 10 THEN 4            
            WHEN Number_of_bedrooms > 10 THEN 5
        END),
    Feature_Cat_ID = 
        (CASE
            WHEN Number_of_features < 10 THEN 1
            WHEN Number_of_features BETWEEN 10 AND 20 THEN 2
            WHEN Number_of_features > 20 THEN 3
        END),
    Total_Rent_Fee = Weekly_Rent_Fee * Total_Weeks
;    

CREATE TABLE MRE_Rent_FACT_L0 AS (
    SELECT
        Agent_Person_ID,
        Client_Person_ID,
        Property_ID,
        Rent_Start_Date,
        Rent_End_Date,
        Rental_Period_ID,
        Scale_ID,
        Feature_Cat_ID,
        Total_Rent_Fee,
        Number_of_Rent
    FROM MRE_Rent_TempFACT_L0
);   

-- MRE_Client_FACT_L0
CREATE TABLE MRE_Client_TempFACT_L0 AS (
    SELECT 
        Person_ID AS Client_Person_ID,
        Max_Budget,
        COUNT(Person_ID) AS Number_of_Clients
    FROM MRE_Client
    GROUP BY Person_ID, Min_Budget, Max_Budget
);

ALTER TABLE MRE_Client_TempFACT_L0
ADD Budget_ID VARCHAR2(2);

UPDATE MRE_Client_TempFACT_L0
SET Budget_ID = 
    (CASE
        WHEN Max_Budget >= 0 AND Max_Budget <= 1000 THEN 1
        WHEN Max_Budget >= 1001 AND Max_Budget <= 100000 THEN 3
        WHEN Max_Budget >= 100001 AND Max_Budget <= 10000000 THEN 5
    END);    

CREATE TABLE MRE_Client_FACT_L0 AS (
    SELECT 
        Client_Person_ID,
        Budget_ID,
        Number_of_Clients
    FROM MRE_Client_TempFACT_L0
);    

-- MRE_Agent_FACT_L0
CREATE TABLE MRE_Agent_FACT_L0 AS (
    SELECT 
        Person_ID AS Agent_Person_ID,
        Salary AS Total_Earnings
    FROM MRE_Agent
);

-- MRE_Visit_FACT_L0
CREATE TABLE MRE_Visit_TempFACT_L0 AS (
    SELECT DISTINCT 
        Client_Person_ID,
        Agent_Person_ID,
        Property_ID,
        Visit_Date,
        COUNT(*) AS Number_of_Visits
    FROM MRE_Visit 
    GROUP BY Client_Person_ID, Agent_Person_ID, Property_ID, Visit_Date
);

ALTER TABLE MRE_Visit_TempFACT_L0
ADD Visit_Time_ID VARCHAR2(5);

UPDATE MRE_Visit_TempFACT_L0
SET Visit_Time_ID = TO_CHAR(Visit_Date, 'MMDY');

CREATE TABLE MRE_Visit_FACT_L0 AS (
    SELECT 
        Client_Person_ID,
        Agent_Person_ID,
        Property_ID,
        Visit_Time_ID,
        Number_of_Visits
    FROM MRE_Visit_TempFACT    
);

-- MRE_Advert_FACT_L0
CREATE TABLE MRE_Advert_FACT_L0 AS (
    SELECT DISTINCT
        pa.Property_ID,
        pa.Advert_ID,
        TO_CHAR(p.Property_Date_Added, 'YYYYMMDy') AS Time_ID,
        COUNT(pa.Advert_ID) AS Number_of_Adverts
    FROM MRE_Property_Advert pa, MRE_Property p 
    WHERE pa.Property_ID = p.Property_ID
    GROUP BY pa.Property_ID, pa.Advert_ID, TO_CHAR(p.Property_Date_Added, 'YYYYMMDy')
);


----------------------------------------------------
-- Two-column methodology checking of fact tables --
----------------------------------------------------
-- Numbers should be wrong since tested on non-cleaned data.

-- MRE_Sale_FACT_L0
SELECT SUM(Total_Sales_Price), SUM(Number_of_Sales) FROM MRE_Sale_FACT_L0; -- 702,593,752 and 916
SELECT Agent_Person_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT_L0 GROUP BY Agent_Person_ID ORDER BY Agent_Person_ID; -- 702,593,752 and 916
SELECT Client_Person_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT_L0 GROUP BY Client_Person_ID ORDER BY Client_Person_ID; -- 702,593,752 and 916 
SELECT Time_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT_L0 GROUP BY Time_ID ORDER BY Time_ID; -- 702,593,752 and 916 
SELECT Property_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT_L0 GROUP BY Property_ID ORDER BY Property_ID; -- 702,593,752 and 916  
SELECT Type_ID, SUM(Total_Sales_Price), SUM(Number_Of_Sales) FROM MRE_Sale_FACT_L0 GROUP BY Type_ID ORDER BY Type_ID; -- 702,593,752 and 916  

-- MRE_Rent_FACT_L0
SELECT SUM(Number_of_Rent) FROM MRE_Rent_FACT_L0; -- 1116
SELECT Agent_Person_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT_L0 GROUP BY Agent_Person_ID ORDER BY Agent_Person_ID; -- 1116
SELECT Client_Person_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT_L0 GROUP BY Client_Person_ID ORDER BY Client_Person_ID; -- 1116
SELECT Property_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT_L0 GROUP BY Property_ID ORDER BY Property_ID; -- 1116
SELECT Rent_Start_Date, SUM(Number_Of_Rent) FROM MRE_Rent_FACT_L0 GROUP BY Rent_Start_Date ORDER BY Rent_Start_Date; -- 1116
SELECT Rent_End_Date, SUM(Number_Of_Rent) FROM MRE_Rent_FACT_L0 GROUP BY Rent_End_Date ORDER BY Rent_End_Date; -- 1116
SELECT Scale_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT_L0 GROUP BY Scale_ID ORDER BY Scale_ID; -- 1116
SELECT Feature_Cat_ID, SUM(Number_Of_Rent) FROM MRE_Rent_FACT_L0 GROUP BY Feature_Cat_ID ORDER BY Feature_Cat_ID; -- 1116

-- MRE_Client_FACT_L0
SELECT SUM(Number_Of_Clients) FROM MRE_Client_FACT_L0; -- 3339
SELECT Client_Person_ID, SUM(Number_Of_Clients) FROM MRE_Client_FACT_L0 GROUP BY Client_Person_ID ORDER BY Client_Person_ID; -- 3339
SELECT Budget_ID, SUM(Number_Of_Clients) FROM MRE_Client_FACT_L0 GROUP BY Budget_ID ORDER BY Budget_ID; -- 3339

-- MRE_Agent_FACT_L0
SELECT SUM(Total_Earnings) FROM MRE_Agent_FACT_L0; -- 477,290,000
SELECT Agent_Person_ID, SUM(Total_Earnings) FROM MRE_Agent_FACT_L0 GROUP BY Agent_Person_ID ORDER BY Agent_Person_ID; -- 477,290,000

-- MRE_Visit_FACT_L0
SELECT SUM(Number_of_Visits) FROM MRE_Visit_FACT_L0; -- 575
SELECT Client_Person_ID, SUM(Number_of_Visits) FROM MRE_Visit_FACT_L0 GROUP BY Client_Person_ID ORDER BY Client_Person_ID; -- 575
SELECT Agent_Person_ID, SUM(Number_of_Visits) FROM MRE_Visit_FACT_L0 GROUP BY Agent_Person_ID ORDER BY Agent_Person_ID; -- 575
SELECT Property_ID, SUM(Number_of_Visits) FROM MRE_Visit_FACT_L0 GROUP BY Property_ID ORDER BY Property_ID; -- 575
SELECT Visit_Time_ID, SUM(Number_of_Visits) FROM MRE_Visit_FACT_L0 GROUP BY Visit_Time_ID ORDER BY Visit_Time_ID; -- 575

-- MRE_Advert_FACT_L0
SELECT SUM(Number_of_Adverts) FROM MRE_Advert_FACT_L0; -- 3646
SELECT Property_ID, SUM(Number_of_Adverts) FROM MRE_Advert_FACT_L0 GROUP BY Property_ID ORDER BY Property_ID; -- 3646
SELECT Advert_ID, SUM(Number_of_Adverts) FROM MRE_Advert_FACT_L0 GROUP BY Advert_ID ORDER BY Advert_ID; -- 3646
SELECT Time_ID, SUM(Number_of_Adverts) FROM MRE_Advert_FACT_L0 GROUP BY Time_ID ORDER BY Time_ID; -- 3646
