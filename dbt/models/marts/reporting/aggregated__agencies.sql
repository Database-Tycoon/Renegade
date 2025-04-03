{{
    config(
        materialized = 'view',
        table_format = 'iceberg',
        description = 'This model includes all agencies represented in the 311 service requests dataset'
    )
}}

/* Intended to answer questions about agencies, like:
- How long has this agency existed in the data?
- What is median time to close/resolve requests?
- What are most complained-to agencies?
- What are top complaint types by agency?
*/

with resolution_last_3_months as (

    select
        agency
        , approx_percentile(date_diff('day', created_date, closed_date), 0.5) as median_days_to_close

    from {{ ref('stg__service_requests') }}
    where closed_date >= date_add('month', -3, current_date)
    group by 1

)

, metrics as (

    select
        requests.agency
        , requests.agency_name
        , coalesce(cast(resolution_last_3_months.median_days_to_close as varchar), 'unknown') as median_days_to_close
        , min(requests.created_date) as first_request_date
        , max(requests.created_date) as most_recent_request_date
        , count(*) as total_requests

    from {{ ref('stg__service_requests') }} as requests
    left join resolution_last_3_months on requests.agency = resolution_last_3_months.agency
    group by 1, 2, 3

)

, final as (

    select
        /* Surrogate key */
        {{ dbt_utils.generate_surrogate_key(['metrics.agency']) }} as agency_id
        , metrics.*

    from metrics

)

select * from final 