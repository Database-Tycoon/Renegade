select
    format_datetime(received_date, 'yyyy-MM') as received_month
    , major_category
    , minor_category
    , space_type
    , unit_type
    , type
    , borough
    , complaint_anonymous_flag
    , count(*) as problem_count

from nyc_open_data.hpd_complaints
where received_date >= current_date - interval '5' year
group by 1, 2, 3, 4, 5, 6, 7, 8
order by 1
