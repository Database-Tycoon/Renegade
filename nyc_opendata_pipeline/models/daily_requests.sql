MODEL (
  name service_requests.daily_requests,
  kind FULL,
  cron '@daily',
  grain unique_key,

);

SELECT
  created_date::date,
  COUNT(DISTINCT unique_key) AS request_count
FROM service_requests.service_requests
GROUP BY 1
