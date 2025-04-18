# HPD Problem Buildings Exploration

The City of New York makes available [data surrounding complaints made to the Department of Housing Preservation and Development (HPD)](
https://data.cityofnewyork.us/Housing-Development/Housing-Maintenance-Code-Complaints-and-Problems/ygpa-z7cr/about_data). Using this dataset, let's explore buildings in each borough with a high incidence of complaints. This dataset contains records from ~2003 to 2025.

## Overall Dataset, 2020-2025

### Problem Categories, Severity, and Seasonality
```hpd_overall_categories
select date_trunc('quarter', (received_month || '-01')::date) as quarter, major_category, sum(problem_count) as problem_count 
from nycdata.hpd_problem_categories
group by 1, 2
order by 1, 3
```

Looking at the overall data, these are the most common categories of problems reported:
<BarChart 
    data={hpd_overall_categories}
    x=quarter
    y=problem_count
    series=major_category
    title="Problem Counts by Category, Last 5 years"
/>  

**Heating/Hot Water** is the most common problem category overall, and clearly peaks in the colder months. **Unsanitary Condition** is the second most common category.

```hpd_overall_types
select date_trunc('quarter', (received_month || '-01')::date) as quarter, type, sum(problem_count) as problem_count 
from nycdata.hpd_problem_categories
group by 1, 2
order by 1, 3
```

These problems are also reported at varying severities:
<LineChart 
    data={hpd_overall_types}
    x=quarter
    y=problem_count
    series=type
    title="Problem Counts by Type, Last 5 years"
/>
The seasonality is very clear here.

```hpd_overall_dimensions
select date_trunc('quarter', (received_month || '-01')::date) as quarter, major_category, minor_category, type, space_type, borough, problem_count 
from nycdata.hpd_problem_categories
```


## Problem Buildings

In each borough, let's explore the top-ranked buildings by count of problem calls where the severity is emergency:
```top_5_problem_buildings
select *, building_address || ' (' || building_id || ')' as building_id_address from nycdata.hpd_top_5_emergency_problem_buildings
```
<BarChart 
    data={top_5_problem_buildings}
    x=building_id_address
    y=total_emergency_problems
    series=borough
    title="Emergency Problems, Top 5 Buildings per Borough, All Time"
    swapXY=true
/>

By default, I'm including all of the top 25 problem buildings in the charts below, but we can also filter on individual buildings. The building_ids are the values in parentheses above.

```sql building_ids
select building_id from nycdata.hpd_top_5_emergency_problem_buildings
```
<Dropdown
    name=selected_building
    data={building_ids}
    value=building_id
>
    <DropdownOption value="%" valueLabel="All Buildings"/>
</Dropdown>


```sql top_buildings_counts_over_time
select
    year
    , building_address
    , sum(problem_count) as problem_count
from nycdata.hpd_top_5_building_problems_yearly
where building_id like '${inputs.selected_building.value}'
group by 1, 2
```

### Problem Reports Over Time

Are these buildings consistently high in problem count over time?
<LineChart 
    data={top_buildings_counts_over_time}
    x=year
    y=problem_count
    series=building_address
    title="Count of Emergency Problems Annually by Building"
/>

### Resolution Times
```sql resolution_times
select * from nycdata.hpd_problem_resolution_times
where building_id like '${inputs.selected_building.value}'
```
<LineChart 
    data={resolution_times}
    x=year
    y=median_days_to_resolution
    series=building_address
    title="Median Days to Complaint Closure"
/>

## Appendix

### Counts by Dimension

<DimensionGrid
     data={hpd_overall_dimensions}
     metric='sum(problem_count)'
     name=selected_dimensions
/> 
<LineChart
     data={hpd_overall_dimensions}
     x=quarter
     handleMissing=zero
     title="Problem Count by Selected Dimensions"
/>

