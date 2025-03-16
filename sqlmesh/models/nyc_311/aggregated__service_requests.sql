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
    grain aggregated_service_requests_id,
    audits (
      unique_values(columns := (aggregated_service_requests_id)),
      unique_combination_of_columns(columns := (request_month, agency, city_or_borough, complaint_type)),
      not_null(columns := (aggregated_service_requests_id, request_month, agency, complaint_type)),
      not_null_non_blocking(columns := (city_or_borough)),
    ),
    description 'Aggregated request information by agency and location rolled up by month',
    column_descriptions (
      aggregated_service_requests_id='Unique identifier of this model, unique across request_month, agency, city_or_borough, complaint_type',
      city_or_borough='City of incident location. If null, use borough provided by submitter.',
      total_unresolved_requests='Count of unique requests where status is not closed. Includes open, pending, in progress, etc.',
      total_closed_requests='Count of unique requests where status is closed.',
      total_requests='Count of unique requests.'
    )
);

with requests as (

    select * from staging.stg__service_requests

)

, metrics as (

    select
        date_trunc('month', requests.created_date) as request_month
        , agency
        /* in current data, city is rarely null but borough is never null */
        , coalesce(requests.city, requests.borough) as city_or_borough
        , requests.complaint_type
        , sum(case when status != 'Closed' then 1 else 0 end) as total_unresolved_requests
        , sum(case when status = 'Closed' then 1 else 0 end) as total_closed_requests
        , count(*) as total_requests

    from requests
    group by all

)

, final as (

    select
        /* Surrogate key */
        @GENERATE_SURROGATE_KEY(metrics.request_month, metrics.agency, metrics.city_or_borough, metrics.complaint_type) as aggregated_service_requests_id
        , metrics.*

    from metrics

)

select * from final
