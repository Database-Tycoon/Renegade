/* Intended to answer questions about agencies, like:
- How long has this agency existed in the data?
- What is median time to close/resolve requests?
- What are most complained-to agencies?
- What are top complaint types by agency?
*/

MODEL (
   name enriched.aggregated__agencies,
   kind VIEW, 
   cron '@daily',
   grain unique_key,
   description 'This model includes all agencies represented in the 311 service requests dataset',
   audits (
     not_null(columns := (agency, agency_name, median_days_to_close)),
     unique_values(columns := (agency))
    ),
   column_descriptions (
       agency='Acronym of responding City Government Agency',
       agency_name='Full Agency name of responding City Government Agency',
       median_days_to_close='For closed complaints only, median number of days between open date and close date for the previous 3 months',
       first_request_date='Created date of earliest requests',
       most_recent_request_date='Created date of most recent request opened with agency',
       total_requests='Count of requests associated with agency for all time'
   )
);

with resolution_last_3_months as (

    select
        agency
        , median(closed_date - created_date) as median_days_to_close

    from staging.stg__service_requests
    where closed_date >= current_date - interval '3 months'
    group by 1

)

select
    requests.agency
    /* API docs say there is an open bug with agency_name, need to confirm behavior isn't causing fan-out */
    , requests.agency_name
    , coalesce(resolution_last_3_months.median_days_to_close::text, 'unknown') as median_days_to_close
    , min(requests.created_date) as first_request_date
    , max(requests.created_date) as most_recent_request_date
    , count(*) as total_requests

from staging.stg__service_requests as requests
left join resolution_last_3_months on requests.agency = resolution_last_3_months.agency
group by 1, 2, 3

