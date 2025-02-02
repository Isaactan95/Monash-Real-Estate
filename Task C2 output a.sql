-- Task c 2b)
-- Level 2 multi-fact star schema
DROP TABLE MRE_scale_DIM_l2 PURGE;
DROP TABLE MRE_feature_cat_DIM_l2 PURGE;
DROP TABLE MRE_property_dim_l2 PURGE;
DROP TABLE MRE_property_feature_bridge_l2 PURGE;
DROP TABLE MRE_feature_dim_l2 PURGE;
DROP TABLE MRE_property_type_dim_l2 PURGE;
DROP TABLE MRE_address_dim_l2 PURGE;
DROP TABLE MRE_postcode_dim_l2 PURGE;
DROP TABLE MRE_state_dim_l2 PURGE;
DROP TABLE MRE_advertisement_dim_l2 PURGE;
DROP TABLE MRE_person_dim_l2 PURGE;
DROP TABLE MRE_agent_office_dim_l2 PURGE;
DROP TABLE MRE_office_dim_l2 PURGE;
DROP TABLE MRE_budget_dim_l2 PURGE;
DROP TABLE MRE_rental_period_dim_l2 PURGE;
DROP TABLE MRE_wishlist_dim_l2 PURGE;
DROP TABLE MRE_rent_price_dim_l2 PURGE;
DROP TABLE MRE_temp_time_dim_l2 PURGE;
DROP TABLE MRE_time_dim_l2 PURGE;
DROP TABLE MRE_season_dim_l2 PURGE;
DROP TABLE MRE_agent_fact_l2 PURGE;
DROP TABLE MRE_temp_client_l2 PURGE;
DROP TABLE MRE_client_fact_l2 PURGE;
DROP TABLE MRE_temp_rent_fact_l2 PURGE;
DROP TABLE MRE_rent_fact_l2 PURGE;
DROP TABLE MRE_temp_visit_l2 PURGE;
DROP TABLE MRE_visit_fact_l2 PURGE;
DROP TABLE MRE_temp_sale_fact_l2 PURGE;
DROP TABLE MRE_sale_fact_l2 PURGE;
DROP TABLE MRE_temp_advert_l2 PURGE;
DROP TABLE MRE_advert_fact_l2 PURGE;

-- Dimension tables
-- Scale dimension
create table mre_scale_dim_l2 (
    scale_id numeric(1),
    scale_description char(20));

insert into mre_scale_dim_l2 values(1, 'extra small');
insert into mre_scale_dim_l2 values(2, 'small');
insert into mre_scale_dim_l2 values(3, 'medium');
insert into mre_scale_dim_l2 values(4, 'large');
insert into mre_scale_dim_l2 values(5, 'extra large');

-- Feature catagory dimension
create table mre_feature_cat_dim_l2(
    feature_cat_id numeric(1),
    feature_cat_description char(15));

insert into mre_feature_cat_dim_l2 values(1,'basic');
insert into mre_feature_cat_dim_l2 values(2,'standard');
insert into mre_feature_cat_dim_l2 values(3,'luxurious');


-- Property dimension
create table mre_property_dim_l2
    as select property_id, address_id, property_type
        from mre_property;

-- Property feature bridge
create table mre_property_feature_bridge_l2
    as select distinct * 
        from mre_property_feature;

 
-- feature dim
create table mre_feature_dim_l2
    as select distinct *
        from mre_feature;

-- property type dimension
create table mre_property_type_dim_l2 
    as select distinct(property_type)
        from mre_property;

-- Address dim
create table mre_address_dim_l2
    as select distinct address_id, suburb, postcode
        from mre_address;

-- postcode dim
create table mre_postcode_dim_l2
    as select distinct * 
        from mre_postcode;

-- state dim
create table mre_state_dim_l2
    as select * 
        from mre_state;

-- Advertisment dim
create table mre_advertisement_dim_l2
    as select distinct *
        from mre_advertisement;

-- person dim        
create table mre_person_dim_l2
    as select person_id, first_name, last_name, gender, address_id
        from mre_person;

-- agent office dim
create table mre_agent_office_dim_l2
    as select distinct person_id as agent_person_id, office_id 
        from mre_agent_office;

-- office dim        
create table mre_office_dim_l2
    as select *
        from mre_office;

alter table mre_office_dim_l2
    add office_size char(10);

update mre_office_dim_l2 t
    set office_size = 
        (select case 
                    when count(person_id) < 4 then 'small'
                    when count(person_id) between 4 and 12 then 'medium'
                    else 'big'
                end
                from mre_agent_office ao
                where t.office_id = ao.office_id);

-- Budget dimension 
create table mre_budget_dim_l2(
    budget_id numeric(1),
    budget_description varchar(100));

insert into mre_budget_dim_l2 values (1, 'Budget between 0 and 1000');
insert into mre_budget_dim_l2 values (2, 'Budget between 1001 and 100000');
insert into mre_budget_dim_l2 values (3, 'Budget more than 100001');

-- Rental period DIM
create table mre_rental_period_dim_l2(
    rental_period_id numeric(2),
    rental_period_description varchar(50));

insert into mre_rental_period_dim_l2 values (1, 'short');
insert into mre_rental_period_dim_l2 values (2, 'medium');
insert into mre_rental_period_dim_l2 values (3, 'long');

-- whishlist dim
create table mre_wishlist_dim_l2
    as select distinct * 
        from mre_client_wish;

-- Rent price dimension
create table mre_rent_price_dim_l2
    as select property_id, rent_start_date, rent_end_date, price
        from mre_rent;

-- Time dimension 
create table mre_temp_time_dim_l2
    as select *
        from (select distinct sale_date as dates from mre_sale
                    where sale_date is not null
                union 
                select distinct rent_start_date from mre_rent
                    where rent_start_date is not null
                union 
                select distinct rent_end_date from mre_rent
                    where rent_end_date is not null
                );

alter table mre_temp_time_dim_l2
    add (
        time_id varchar(20),
        Year numeric(4),
        Month numeric(2),
        Season_id numeric(1));       

update mre_temp_time_dim_l2
    set time_id = to_char(dates, 'YYYYMMDY'),
        year = to_char(dates, 'YYYY'),
        month = to_char(dates, 'MM');

update mre_temp_time_dim_l2
    set season_id = 
        case
            when month between 3 and 5 then 1
            when month between 6 and 8 then 2
            when month between 9 and 11 then 3
            else 4
        end;

create table mre_time_dim_l2
    as select DISTINCT(time_id), year, month, season_id
        from mre_temp_time_dim_l2;

-- Season DIM
create table mre_season_dim_l2(
    season_id numeric(1),
    season_description char(10));

insert into mre_season_dim_l2 values(1, 'Spring');
insert into mre_season_dim_l2 values(2, 'Summer');
insert into mre_season_dim_l2 values(3, 'Autumn');
insert into mre_season_dim_l2 values(4, 'Winter');

-- Fact tables
-- Agent fact table
create table mre_agent_fact_l2
as select a.person_id as agent_person_id, sum(nvl(s.price, 0)) + nvl(sum(nvl(r.price, 0)/7*(r.rent_end_date - r.rent_start_date)), 0) as total_earnings
    from mre_agent a, mre_sale s, mre_rent r
        where a.person_id = s.agent_person_id (+)
        and a.person_id = r.agent_person_id (+)
            group by a.person_id;
   
-- client fact table 
create table mre_temp_client_l2
    as select max_budget from mre_client;

alter table mre_temp_client_l2 
    add budget_id numeric(1);

update mre_temp_client_l2
    set budget_id = case 
        when max_budget between 0 and 1000 then 1
        when max_budget between 1001 and 100000 then 2
        else 3 end;

create table mre_client_fact_l2
    as select budget_id , count(*) as total_number_of_client
        from mre_temp_client_l2
            group by budget_id;

-- rent fact
create table mre_temp_rent_fact_l2
    as select distinct 
        r.property_id ,
        r.rent_start_date as dates, 
        p.property_no_of_bedrooms, 
        COUNT(*) as number_of_features, 
        r.price,
        r.rent_end_date,
        r.rent_start_date,
        count(distinct(rent_id)) as num_of_rent
            from mre_rent r, mre_property p, mre_property_feature f
                where r.property_id = p.property_id
                    and p.property_id = f.property_id
                    and r.rent_start_date is not null
                        GROUP BY r.property_id, p.property_no_of_bedrooms, r.price, r.rent_end_date, r.rent_start_date;

alter table mre_temp_rent_fact_l2 add (
    time_id varchar(20),
    scale_id numeric(1),
    feature_cat_id numeric(1));

update mre_temp_rent_fact_l2
    set time_id = to_char(rent_start_date, 'YYYYMMDY'),
        scale_id =
            case 
                when property_no_of_bedrooms between 0 and 1 then 1
                when property_no_of_bedrooms between 2 and 3 then 2
                when property_no_of_bedrooms between 4 and 6 then 3
                when property_no_of_bedrooms between 7 and 10 then 4
                else 5
            end;
            
update mre_temp_rent_fact_l2 t
       set feature_cat_id = 
        (case when number_of_features < 10 then 1
                    when number_of_features between 10 and 20 then 2
                    else 3
                end);

create table mre_rent_fact_l2
    as select property_id, time_id, scale_id, feature_cat_id, (price / 7 *(rent_end_date - rent_start_date)) as total_rent_fee, num_of_rent as number_of_rent
        from mre_temp_rent_fact_l2;
            
-- visit fact
create table mre_temp_visit_l2
    as select visit_date 
        from mre_visit;

alter table mre_temp_visit_l2 
    add visit_time_id varchar(20);

update mre_temp_visit_l2
    set visit_time_id = to_char(visit_date, 'YYYYMMDY');

create table mre_visit_fact_l2
    as select visit_time_id, count(*) as number_of_visit
        from mre_temp_visit_l2
            group by visit_time_id;

-- sale fact
create table mre_temp_sale_fact_l2
    as select s.property_id, s.sale_date, p.property_type, s.price
        from mre_sale s, mre_property p
            where s.property_id = p.property_id
                and sale_date is not null;

alter table mre_temp_sale_fact_l2 add (
    time_id varchar(20));

set define off;
update mre_temp_sale_fact_l2
    set time_id = to_char(sale_date, 'YYYYMMDY');

create table mre_sale_fact_l2
    as select property_id, time_id, sum(price) as total_sales_price, count(*) as number_of_sales
        from mre_temp_sale_fact_l2
            group by property_id, time_id;

-- Advert fact
create table mre_temp_advert_l2
    as select distinct a.advert_id, p.property_date_added
        from mre_property_advert a, mre_property p
            where p.property_id = a.property_id;

alter table mre_temp_advert_l2
    add time_id varchar(20);

update mre_temp_advert_l2
    set time_id = to_char(property_date_added, 'YYYYMMDY');

create table mre_advert_fact_l2
    as select time_id, advert_id, count(*) as number_of_adverts
        from mre_temp_advert_l2
            group by time_id, advert_id;

commit;