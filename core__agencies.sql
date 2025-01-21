/* this could also be a view, want to include count complaints and resolution time, agency metadata */

MODEL (
   name TBD_DB_NAME.core__agencies,
   kind INCREMENTAL_BY_UNIQUE_KEY, 
   cron '@daily',
   grain unique_key,
   description 'This model includes all agencies represented in the 311 service requests dataset',
   audits (
     not_null(columns := (agency)
    ),
     unique_values(columns := (agency))
   ),
   column_descriptions (
   )
);

with resolution_last_3_months as (

    select
        agency
        , median(closed_date - created_date) as median_days_to_close

    from DBNAME.source__311_service_requests
    where closed_date >= current_date - interval '3 months'

)

select
    agency
    , agency_name -- confirm bug doesn't cause fanout
    , coalesce(median_days_to_close, 'unknown') as median_days_to_close
    , min(created_date) as first_complaint_date
    , max(created_date) as most_recent_complaint_date
    , count(*) over (partition by agency) as total_complaints

from DBNAME.source__311_service_requests
left join resolution_last_3_months on source__311_service_requests.agency = resolution_last_3_months.agency
group by 1, 2

