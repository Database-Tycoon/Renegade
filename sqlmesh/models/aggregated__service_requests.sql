with requests as (

    select * from source__311_service_requests

)

, metrics as (

    select
        date_trunc('month', created_date) as complaint_month
        , agency
        , location
        , closed_ratio
        , top_resolved_type
        , top_unresolved_type
        , count(*) as total_complaints

    from requests

)

select * from metrics
