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

select
    agency
    , agency_name

from DBNAME.source__311_service_requests


