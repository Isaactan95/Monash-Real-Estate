--3
--a
--Report 1
SELECT 	s.scale_description as Scale,
		a.suburb as Suburb, 
		SUM(f.number_of_rent) as Number_of_Rents,
        ROW_NUMBER() OVER(ORDER BY SUM(f.number_of_rent) DESC) as RANK
	FROM mre_rent_fact_l2 f, mre_scale_dim_l2 s, mre_property_dim_l2 p, mre_address_dim_l2 a
		WHERE f.scale_id = s.scale_id
		AND f.property_id = p.property_id
		AND p.address_id = a.address_id
        AND ROWNUM <= 16
			GROUP BY s.scale_description, a.suburb
                ORDER BY ROW_NUMBER() OVER(ORDER BY SUM(f.number_of_rent) DESC) ASC;


--Report 2
SELECT *
    FROM (
SELECT  t.year as Year,
        t.month as Month,
        p.property_type as Property_Type,
        SUM(f.total_sales_price) as Total_Sales_Price,
        SUM(f.number_of_sales) as Number_of_Sales,
        PERCENT_RANK() OVER (ORDER BY SUM(f.total_sales_price) DESC) as Revenue_Ranking
    FROM mre_sale_fact_l2 f, mre_property_dim_l2 p, mre_time_dim_l2 t
        WHERE f.time_id = t.time_id
            GROUP BY t.year, t.month, p.property_type)
                WHERE Revenue_Ranking >= 0.85
                    ORDER BY Revenue_Ranking DESC;



--Report 3
SELECT  t.year as Year,
        s.season_description as season,
        a.suburb as suburb,
        SUM(number_of_visits) as Number_of_Visits
    FROM mre_visit_fact_l0 f, mre_time_dim_l0 t, mre_season_dim_l0 s, mre_property_dim_l0 p, mre_address_dim_l0 a
        WHERE f.time_id = t.time_id
        AND t.season_id = s.season_id
        AND f.property_id = p.property_id
        AND p.address_id = a.address_id
            GROUP BY t.year, s.season_description, a.suburb
                ORDER BY t.year, s.season_description, a.suburb;