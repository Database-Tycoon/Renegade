MODEL (
  name staging.stg__housing_maintenance_code_complaints_and_problems,
  kind full, 
  cron '@daily',
  grain 'problem_id',
  description 'Each row is a problem reported by the complainant to the Department of Housing Preservation and Development (HPD)',
  audits (
    not_null(columns := (problem_id, problem_type, major_category, borough)),
    unique_values(columns := (problem_id))
  ),
  column_descriptions (
    received_at='Date when the complaint was received',
    problem_id='Unique identifier of this problem',
    complaint_id='Unique identifier of the complaint this problem is associated with',
    building_id='Unique identifier given to a building record',
    borough='Complaint borough, example values: Manhattan, Bronx, Brooklyn',
    house_number='Complaint house number',
    street_name='Complaint street name',
    block='Number assigned by the NYC Dept of Finance identifying the tax block the lot is on',
    lot='Unique number assigned by the NYC Dept of Finance within a Block identifying a lot',
    apartment='Number of the unit or apartment in a building',
    community_board='Unique number identifying a Community District/Board, which is a political geographical area within a borough of the City of NY, values 1-18',
    unit_type='Type of space where the problem was reported, example values: Apartment, Building, Public area',
    space_type='Type of space where the problem was reported',
    problem_type='Code indicating the problem type, example values: Emergency, Hazardous, Non emergency',
    major_category='The major category of the problem',
    minor_category='The minor category of the problem',
    problem_code='The problem code',
    complaint_status='The status of the complaint, example values: Close, Open',
    complaint_status_updated_at='Date when the complaint status was updated',
    problem_status='The status of the problem',
    problem_status_updated_at='Date when the problem status was updated',
    status_description='Status description',
    is_duplicate_problem='Duplicate complaint Indicator',
    is_anonymous_complaint='Anonymous complaint Indicator',
    unique_key='Unique identifier of a Service Request (SR) in the open data set. Links to the to the open dataset 311 Service Requests from 2010 to Present',
    bin='Building identification number',
    bbl='Borough-Block-Lot, parcel number to identify location of a building',
    nta='Neighborhood tabulation area',
    _dlt_load_id='Identifier for dlt pipeline load job',
    _dlt_id='Unique identifier for record within an individual dlt pipeline run'
    )
);

with historical as (
    /* TODO need to point this to an Iceberg table? that handles incremental dlt file loads
       currently pointing at one arbitrary load in S3 */

   select * from read_parquet('s3://proj-renegade/dlt/landing/nyc_open_data/hpd_complaints/data/00000-0-e70d021d-b5b4-4784-9bf0-9076d76f667e.parquet')

)

, deduplicated as (
    /* Raw data includes literal duplicates */

    select
        * 
    from historical
    qualify row_number() over (
        partition by problem_id
        order by received_date desc
    ) = 1

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
        , complaint_status_date::timestamptz as complaint_status_updated_at
        , received_date::timestamptz as received_at
        , problem_status_date::timestamptz as problem_status_updated_at

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
        , latitude::decimal(9,6) as latitude
        , longitude::decimal(9,6) as longitude
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
        , problem_duplicate_flag::boolean as is_duplicate_problem
        , complaint_anonymous_flag::boolean as is_anonymous_complaint

        /* Metadata */
        , _dlt_load_id
        , _dlt_id

    from deduplicated

)

select * from reordered
