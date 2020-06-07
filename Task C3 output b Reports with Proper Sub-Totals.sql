--3
--b
--Report 4
SELECT  t.year||t.month as Time_Period,
        a.suburb as Suburb,
        p.property_type as Property_Type,
        to_char(SUM(f.total_rent_fee), '9,999,999,999.99') as Rental_Fees,
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
        to_char(SUM(f.total_rent_fee), '9,999,999,999.99') as Rental_Fees,
        DECODE(GROUPING(t.year||t.month), 1, 'All Periods', t.year||t.month) as Period,
        DECODE(GROUPING(a.suburb), 1, 'All Suburbs', a.suburb) as Suburbs,
        DECODE(GROUPING(p.property_type), 1, 'All Types', p.property_type) as Types
    FROM mre_rent_fact_l2 f, mre_time_dim_l2 t, mre_property_dim_l2 p, mre_address_dim_l2 a
        WHERE f.time_id = t.time_id
        AND f.property_id = p.property_id
        AND p.address_id = a.address_id
            GROUP BY a.suburb, CUBE(t.year||t.month, p.property_type);

--Report 6
SELECT  t.year||t.month as Time_period,
        st.state_name as State,
        SUM(s.total_sales_price) as Total_Revenue,
        DECODE(GROUPING(t.year||t.month), 1, 'All Periods', t.year||t.month) as Periods,
        DECODE(GROUPING(st.state_name), 1, 'All States', st.state_name) as States
    FROM mre_sale_fact_l2 s, mre_property_dim_l2 p, mre_address_dim_l2 a, mre_postcode_dim_l2 pc, mre_state_dim_l2 st, mre_time_dim_l2 t
        WHERE s.property_id = p.property_id
        AND p.address_id = a.address_id
        AND a.postcode = pc.postcode
        AND pc.state_code = st.state_code
        AND s.time_id = t.time_id
        AND p.property_type = 'House'
            GROUP BY ROLLUP (t.year||t.month, st.state_name);

--Report 7
SELECT  t.year||t.month as Time_period,
        st.state_name as State,
        SUM(s.total_sales_price) as Total_Revenue,
        DECODE(GROUPING(t.year||t.month), 1, 'All Periods', t.year||t.month) as Periods,
        DECODE(GROUPING(st.state_name), 1, 'All States', st.state_name) as States
    FROM mre_sale_fact_l2 s, mre_property_dim_l2 p, mre_address_dim_l2 a, mre_postcode_dim_l2 pc, mre_state_dim_l2 st, mre_time_dim_l2 t
        WHERE s.property_id = p.property_id
        AND p.address_id = a.address_id
        AND a.postcode = pc.postcode
        AND pc.state_code = st.state_code
        AND s.time_id = t.time_id
        AND p.property_type = 'House'
            GROUP BY st.state_name, ROLLUP (t.year||t.month);