with by_borough as (

    select
        borough
        , building_id
        , house_number || ' ' || street_name as building_address
        , count(distinct problem_id) as total_emergency_problems
        , rank() over (partition by borough order by count(*) desc) as ranking

    from nyc_open_data.hpd_complaints 
    where type != 'NON EMERGENCY'
    group by 1, 2, 3

) 

select * from by_borough where ranking < 6
