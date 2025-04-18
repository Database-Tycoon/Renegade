select
  format_datetime(request_month, 'yyyy-MM') as request_month -- this column fails if brought in normally
  , agency
  , city_or_borough
  , complaint_type
  , total_requests
  , total_closed_requests
  , total_unresolved_requests 

from dbtycoon_renegade.dbt.aggregated__service_requests