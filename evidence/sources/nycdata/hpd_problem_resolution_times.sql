with resolution_times as (

select 
    building_id
    , date_trunc('quarter', received_date) as quarter
    , house_number || street_name as building_address
    , date_diff('day', received_date, complaint_status_date) as days_to_resolution

from nyc_open_data.hpd_complaints
where
    complaint_status = 'CLOSE'
    and type != 'NON EMERGENCY'
    and received_date >= current_date - interval '5' year
    and building_id in (
    '811407'
    , '428710'
    , '411605'
    , '706059'
    , '661708'
    , '6131'
    , '13120'
    , '28340'
    , '27337'
    , '9051'
    , '114412'
    , '125695'
    , '51000'
    , '81982'
    , '65175'
    , '370489'
    , '294912'
    , '808361'
    , '313392'
    )
)

select
    building_id
    , building_address
    , max(days_to_resolution) as max_days_to_resolution
    , approx_percentile(days_to_resolution, 0.5) as median_days_to_resolution

from resolution_times
group by 1, 2
