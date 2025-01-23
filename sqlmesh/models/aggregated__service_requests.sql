/*
Use this model for higher-level reporting by month, like:
- How many complaints received by agency and month?
- What do annual trends look like?
- What is top complaint type by agency/month?
- What is resolved/unresolved ratio of requests?
*/

MODEL(
    name enriched.aggregated__service_requests,
    kind FULL,
    start '2010-01-01',
    cron '@daily',
    grain (complaint_month, agency),
    description 'Aggregated request information by agency'
);

with requests as (

    select * from staging.service_requests

)

, total_types as (

    select
        agency
        , date_trunc('month', created_date) as request_month
        , complaint_type
        , borough
        , count(*) as total_requests

    from requests
    group by all

)

, metrics as (

    select
        date_trunc('month', requests.created_date) as request_month
        , requests.agency
        , max_by(total_types.complaint_type, total_requests) as top_complaint_type
        , max_by(total_types.borough, total_requests) as top_complaint_origination_borough
        , sum(case when requests.status = 'Closed' then 1.0 else 0.0 end) / count(*) as overall_close_ratio
        , count(*) as total_requests

    from requests
    left join total_types on requests.agency = total_types.agency
        and date_trunc('month', requests.created_date) = total_types.request_month
    group by all

)

select * from metrics
