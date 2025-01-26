/*
Use this model for higher-level reporting by month, like:
- How many complaints received by city, agency, and month?
- What do annual trends look like?
- What is top complaint type by month?
- What is resolved/unresolved ratio of requests?

Need to confirm in a larger dataset that coalesce(city, borough) is reliable.
*/

MODEL(
    name enriched.aggregated__service_requests,
    kind FULL,
    start '2010-01-01',
    cron '@weekly',
    grain (request_month, agency, city_or_borough, complaint_type),
    audits (
      unique_combination_of_columns(columns := (request_month, agency, city_or_borough, complaint_type)),
      not_null(columns := (request_month, agency, complaint_type)),
      not_null_non_blocking(columns := (city_or_borough)),
    ),
    description 'Aggregated request information by agency and location rolled up by month',
    column_descriptions (
      city_or_borough='City of incident location. If null, use borough provided by submitter.',
      total_unresolved_requests='Count of unique requests where status is not closed. Includes open, pending, in progress, etc.',
      total_closed_requests='Count of unique requests where status is closed.',
      total_requests='Count of unique requests.'
    )
);

with requests as (

    select * from staging.service_requests

)

, metrics as (

    select
        date_trunc('month', requests.created_date) as request_month
        , agency
        /* in current data, city is rarely null but borough is never null */
        , coalesce(city, borough) as city_or_borough
        , complaint_type
        , sum(case when status != 'Closed' then 1 else 0 end) as total_unresolved_requests
        , sum(case when status = 'Closed' then 1 else 0 end) as total_closed_requests
        , count(*) as total_requests

    from requests
    group by all

)

select * from metrics
