select
    extract(year from received_date) as year
    , building_id
    , borough
    , house_number || ' ' || street_name as building_address
    , count(*) as problem_count

from nyc_open_data.hpd_complaints
where
    building_id in (
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
    and type != 'NON EMERGENCY'
group by 1, 2, 3, 4