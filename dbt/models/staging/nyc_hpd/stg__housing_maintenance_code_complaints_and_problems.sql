{{
    config(
        materialized = 'table',
        table_format = 'iceberg',
        description = 'Each row is a problem reported by the complainant to the Department of Housing Preservation and Development (HPD)',
    )
}}

with historical as (
    
    select * 
    from {{ source('nyc_open_data', 'hpd_complaints') }}
    where extract(year from received_date) >= 2025  -- for now, ingest partial data

)

, deduplicated as (
    /* Raw data includes literal duplicates */

    select * 
    from (
        select
            *,
            row_number() over (
                partition by problem_id
                order by received_date desc
            ) as rn
        from historical
    ) t
    where rn = 1

)

, reordered as (

    select
        /* Primary key */
        problem_id

        /* Foreign keys and IDs */
        , unique_key
        , complaint_id
        , building_id
        , bin

        /* Dates and timestamps 
           despite name these are timestamps */
        , CAST(complaint_status_date AS timestamp with time zone) as complaint_status_updated_at
        , CAST(received_date AS timestamp with time zone) as received_at
        , CAST(problem_status_date AS timestamp with time zone) as problem_status_updated_at

        /* Attributes - location */
        , borough
        , house_number
        , street_name
        , post_code
        , block
        , lot
        , apartment
        , community_board
        , unit_type
        , space_type
        , CAST(latitude AS decimal(9,6)) as latitude
        , CAST(longitude AS decimal(9,6)) as longitude
        , council_district
        , census_tract
        , bbl
        , nta

        /* Attributes - complaint/problem-related */
        , type as problem_type
        , major_category
        , problem_status
        , minor_category
        , problem_code
        , complaint_status
        , status_description
        , problem_duplicate_flag as is_duplicate_problem
        , complaint_anonymous_flag as is_anonymous_complaint

        /* Metadata */
        , _dlt_load_id
        , _dlt_id

    from deduplicated

)

select * from reordered 