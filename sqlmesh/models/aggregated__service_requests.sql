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
    grain (complaint_month, agency)
);

with requests as (

    select * from staging.source__311_service_requests

)

, metrics as (

    select
        date_trunc('month', created_date) as complaint_month
        , agency
--        , closed_ratio
--        , top_resolved_type
--        , top_unresolved_type
        , count(*) as total_complaints

    from requests
    group by all

)

select * from metrics
