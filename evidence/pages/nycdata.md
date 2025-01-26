### Overview - All Time

```total_requests_by_agency_all_time
select
    agency
    , sum(total_requests) as total_requests
from nycdata.aggregated__agencies
group by 1
```

<BarChart 
    data={total_requests_by_agency_all_time} 
    x=agency
    y=total_requests
    title='Total Requests by Agency'
/>

```total_request_types
select
    complaint_type
    , sum(total_requests) as total_requests
from nycdata.aggregated__monthly_requests_type
group by 1
limit 20
```

<BarChart 
    data={total_request_types} 
    x=complaint_type
    y=total_requests
    title='Top 20 Complaint Types'
    swapXY=true
/>

```total_request_location

select
    city_or_borough
    , sum(total_requests) as total_requests
from nycdata.aggregated__monthly_requests_type
group by 1
limit 20
```

<BarChart 
    data={total_request_location} 
    x=city_or_borough
    y=total_requests
    title='Top 20 Locations Originating Complaints'
    xAxisTitle='Request City or Borough'
    swapXY=true
/>

### These will be more interesting with more data

```total_requests_with_closed_line
select
    request_month
    , sum(total_requests) as total_requests
    , sum(total_closed_requests) as total_closed_requests
from nycdata.aggregated__monthly_requests_type
group by 1
```

<BarChart 
    data={total_requests_with_closed_line} 
    x=request_month
    y=total_requests
    y2=total_closed_requests
    y2SeriesType=line
    title='Total Requests by Month'
    xAxisTitle='Month by Request Creation Date'
    yAxisTitle='Count of total requests'
    y2AxisTitle='Count of closed requests'
/>

```total_requests_agency_month
select
    request_month
    , agency
    , sum(total_requests) as total_requests
from nycdata.aggregated__monthly_requests_type
group by 1, 2
```

<BarChart 
    data={total_requests_agency_month} 
    x=request_month
    y=total_requests
    title='Requests by Agency'
    series=agency
    xAxisTitle='Month by Request Creation Date'
    yAxisTitle='Count of Requests'
/>
