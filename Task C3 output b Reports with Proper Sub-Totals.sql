--3
--b
--Report 4
SELECT  t.year||t.month as Time_Period,
        a.suburb as Suburb,
        p.property_type as Property_Type,
        SUM(f.total_rent_fee) as Rental_Fees,
        DECODE(GROUPING(t.year||t.month), 1, 'All Periods', t.year||t.month) as Period,
        DECODE(GROUPING(a.suburb), 1, 'All Suburbs', a.suburb) as Suburbs,
        DECODE(GROUPING(p.property_type), 1, 'All Types', p.property_type) as Types
    FROM mre_rent_fact_l2 f, mre_time_dim_l2 t, mre_property_dim_l2 p, mre_address_dim_l2 a
        WHERE f.time_id = t.time_id
        AND f.property_id = p.property_id
        AND p.address_id = a.address_id
            GROUP BY CUBE(t.year||t.month, a.suburb, p.property_type);
            
--Report 5
SELECT  t.year||t.month as Time_Period,
        a.suburb as Suburb,
        p.property_type as Property_Type,
        SUM(f.total_rent_fee) as Rental_Fees,
        DECODE(GROUPING(t.year||t.month), 1, 'All Periods', t.year||t.month) as Period,
        DECODE(GROUPING(a.suburb), 1, 'All Suburbs', a.suburb) as Suburbs,
        DECODE(GROUPING(p.property_type), 1, 'All Types', p.property_type) as Types
    FROM mre_rent_fact_l2 f, mre_time_dim_l2 t, mre_property_dim_l2 p, mre_address_dim_l2 a
        WHERE f.time_id = t.time_id
        AND f.property_id = p.property_id
        AND p.address_id = a.address_id
            GROUP BY a.suburb, CUBE(t.year||t.month, p.property_type);

--Report 6


--Report 7