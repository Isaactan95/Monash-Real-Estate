--3
--c
--Report 8
SELECT  year,
        SUM(total_clients) as Number_of_Clients,
        SUM(SUM(total_clients)) OVER (ORDER BY year ROWS UNBOUNDED PRECEDING) as Cumulative_Total
FROM
(SELECT * FROM
(SELECT t.year, SUM(f.number_of_clients) as total_clients
    FROM mre_client_fact_l0 f, mre_budget_dim_l0 b, mre_rent_fact_l0 rf, mre_time_dim_l0 t
        WHERE f.budget_id = b.budget_id
        AND f.client_person_id = rf.client_person_id
        AND rf.rent_start_date = t.time_id
        AND b.budget_description LIKE 'High%'
            GROUP BY t.year)
UNION
(SELECT t.year, SUM(f.number_of_clients) as total_clients
    FROM mre_client_fact_l0 f, mre_budget_dim_l0 b,  mre_sale_fact_l0 sf, mre_time_dim_l0 t
        WHERE f.budget_id = b.budget_id
        AND f.client_person_id = sf.client_person_id
        AND sf.time_id = t.time_id
        AND b.budget_description LIKE 'High%'
            GROUP BY t.year))
                GROUP BY year
                    ORDER BY year;

--Report 9
SELECT  t.year,
        t.month,
        SUM(number_of_visit) as Number_of_Visits,
        to_char(AVG(SUM(f.number_of_visit)) OVER (ORDER BY t.year, t.month ROWS 2 PRECEDING), '999,999') as Average_3_Month_Visits
    FROM mre_visit_fact_l2 f, mre_time_dim_l2 t
        WHERE f.visit_time_id =t.time_id
            GROUP BY t.year, t.month
                ORDER BY year, month +0;

--Report 10
SELECT  t.year as Year,
        t.month as Month,
        SUM(Number_of_Rent) as Number_of_Rents,
        SUM(SUM(number_of_rent)) OVER (ORDER BY t.year, t.month ROWS UNBOUNDED PRECEDING) as Cumulative_Number_of_Rent
    FROM mre_rent_fact_l2 f, mre_time_dim_l2 t
        WHERE f.time_id = t.time_id
            GROUP BY t.year, t.month
                ORDER BY year, month +0;