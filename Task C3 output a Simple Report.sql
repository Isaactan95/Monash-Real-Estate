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




--Report 3
