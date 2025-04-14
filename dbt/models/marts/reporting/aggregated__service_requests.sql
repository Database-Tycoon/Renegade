{{
    config(
        materialized = 'table',
        table_format = 'iceberg',
        description = 'Aggregated request information by agency and location rolled up by month'
    )
}}

/*
Use this model for higher-level reporting by month, like:
- How many complaints received by city, agency, and month?
- What do annual trends look like?
- What is top complaint type by month?
- What is resolved/unresolved ratio of requests?

Need to confirm in a larger dataset that coalesce(city, borough) is reliable.
*/

with requests as (

    select * from {{ ref('stg__service_requests') }}

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
    group by 1, 2, 3, 4

)

, final as (

    select
        /* Surrogate key */
        {{ dbt_utils.generate_surrogate_key(['metrics.request_month', 'metrics.agency', 'metrics.city_or_borough', 'metrics.complaint_type']) }} as aggregated_service_requests_id
        , metrics.*

    from metrics

)

select * from final 