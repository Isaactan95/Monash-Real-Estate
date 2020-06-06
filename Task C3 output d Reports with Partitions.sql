--3
--d
--Report 11
SELECT  t.year as Year,
        p.property_type as Property_Type,
        s.state_name as State,
        SUM(f.number_of_sales) as Total_Number_of_Sales,
        RANK() OVER (PARTITION BY t.year ORDER BY SUM(f.number_of_sales) DESC) as RANK_BY_YEAR,
        RANK() OVER (PARTITION BY s.state_name ORDER BY SUM(f.number_of_sales) DESC) as RANK_BY_STATE
    FROM mre_sale_fact_l2 f, mre_property_dim_l2 p, mre_time_dim_l2 t, mre_address_dim_l2 a, mre_postcode_dim_l2 pc, mre_state_dim_l2 s
        WHERE f.property_id = p.property_id
        AND f.time_id = t.time_id
        AND p.address_id = a.address_id
        AND a.postcode = pc.postcode
        AND pc.state_code = s.state_code
            GROUP BY t.year, p.property_type, s.state_name;
        

--Report 12
SELECT  t.year as Year,
        ad.advert_name as Advertisement_Type,
        s.state_name as State,
        SUM(f.number_of_adverts) as Yearly_Total_Number_of_Adverts,
        RANK() OVER (PARTITION BY ad.advert_name ORDER BY SUM(f.number_of_adverts) DESC) as RANK_BY_ADVERT_TYPE,
        RANK() OVER (PARTITION BY s.state_name ORDER BY SUM(f.number_of_adverts) DESC) as RANK_BY_STATE
    FROM mre_advert_fact_l0 f, mre_advertisement_dim_l0 ad, mre_property_dim_l0 p, mre_address_dim_l0 a, mre_postcode_dim_l0 pc, mre_state_dim_l0 s, mre_time_dim_l0 t
        WHERE f.advert_id = ad.advert_id
        AND f.property_id = p.property_id
        AND p.address_id = a.address_id
        AND a.postcode = pc.postcode
        AND pc.state_code = s.state_code
        AND f.time_id = t.time_id
            GROUP BY t.year, ad.advert_name, s.state_name;