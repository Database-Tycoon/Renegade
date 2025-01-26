/* revisit kind, incremental could make sense
   This model is intended to stage and do basic cleaning/casting on the raw API data
   Some columns were missing from spec (location), need to confirm.
*/

MODEL (
  name staging.service_requests,
  kind INCREMENTAL_BY_UNIQUE_KEY (
    unique_key unique_key
  ),
  cron '@daily',
  grain unique_key,
  description 'One row per service request to 311, from NYC Open Data Project',
  audits (
    not_null(columns := (unique_key, created_date, complaint_type)),
    unique_values(columns := (unique_key))
  ),
  column_descriptions (
    unique_key=' Unique identifier of a Service Request (SR) in the open data set',
    created_date='Date SR was created',
    closed_date='Date SR was closed by responding agency',
    due_date='Date when responding agency is expected to update the SR. This is based on the Complaint Type and internal Service Level Agreements (SLAs).',
    resolution_description='Describes the last action taken on the SR by the responding agency. May describe next or future steps.',
    resolution_action_updated_date='Date when responding agency last updated the SR.',
    agency='Acronym of responding City Government Agency',
    agency_name='Full Agency name of responding City Government Agency',
    complaint_type='This is the first level of a hierarchy identifying the topic of the incident or condition. Complaint Type may have a corresponding Descriptor (below) or may stand alone.',
    descriptor='This is associated to the Complaint Type, and provides further detail on the incident or condition. Descriptor values are dependent on the Complaint Type, and are not always required in SR.',
    status='Status of SR submitted',

    location_type='Describes the type of location used in the address information',
    incident_zip='Incident location zip code, provided by geo validation.',
    incident_address='House number of incident address provided by submitter.',
    street_name='Street name of incident address provided by the submitter',
    cross_street_1='First Cross street based on the geo validated incident location',
    cross_street_2='Second Cross Street based on the geo validated incident location',
    intersection_street_1='First intersecting street based on geo validated incident location',
    intersection_street_2='Second intersecting street based on geo validated incident location',
    address_type='Type of incident location information available.',
    city='City of the incident location provided by geovalidation.',
    community_board='Provided by geovalidation.',
    bbl='Borough Block and Lot, provided by geovalidation. Parcel number to identify the location of location of buildings and properties in NYC.',
    borough='Provided by the submitter and confirmed by geovalidation.',
    x_coordinate_state_plane='Geo validated, X coordinate of the incident location.',
    y_coordinate_state_plane='Geo validated, Y coordinate of the incident location.',
    latitude='Geo based Lat of the incident location',
    longitude='Geo based Long of the incident location',
    --location='Combination of the geo based lat & long of the incident location',

    facility_type='If available, this field describes the type of city facility associated to the SR',
    landmark='If the incident location is identified as a Landmark the name of the landmark will display here',
    park_facility_name='If the incident location is a Parks Dept facility, the Name of the facility will appear here',
    park_borough='The borough of incident if it is a Parks Dept facility',
    vehicle_type='If the incident is a taxi, this field describes the type of TLC vehicle.',
    taxi_company_borough='If the incident is identified as a taxi, this field will display the borough of the taxi company.',
    taxi_pick_up_location='If the incident is identified as a taxi, this field displays the taxi pick up location',
    bridge_highway_name='If the incident is identified as a Bridge/Highway, the name will be displayed here.',
    bridge_highway_direction='If the incident is identified as a Bridge/Highway, the direction where the issue took place would be displayed here.',
    road_ramp='If the incident location was Bridge/Highway this column differentiates if the issue was on the Road or the Ramp.',
    bridge_highway_segment='Additional information on the section of the Bridge/Highway were the incident took place.',

    open_data_channel_type='Indicates how the SR was submitted to 311. i.e. By Phone, Online, Mobile, Other or Unknown.',
    _dlt_id='Alphanumeric id value generated for each row in a dlt run.',
    _dlt_load_id='Decimal value associated with each pipeline load for each dlt pipeline run.'
  )
);

with renamed as (

    select
        unique_key
        , created_date
        , closed_date
        , agency
        , agency_name
        , complaint_type
        , descriptor
        , location_type
        , incident_zip
        , incident_address
        , street_name
        , cross_street_1
        , cross_street_2
        , intersection_street_1
        , intersection_street_2 
        , address_type
        , city 
        , landmark 
        , facility_type
        , status
        , due_date
        , resolution_description
        , resolution_action_updated_date
        , community_board
        , bbl
        , borough
        , x_coordinate_state_plane
        , y_coordinate_state_plane
        , open_data_channel_type
        , park_facility_name
        , park_borough
        , vehicle_type
        , taxi_company_borough
        , taxi_pick_up_location
        , bridge_highway_name
        , bridge_highway_direction
        , road_ramp
        , bridge_highway_segment
        , latitude
        , longitude
        /* did not see these fields in documentation */
        , location__latitude
        , location__longitude
        , location__human_address
        , _acomputed_region_efsh_h5xi
        , _acomputed_region_f5dn_yrer
        , _acomputed_region_yeji_bk3q
        , _acomputed_region_92fq_4b7q
        , _acomputed_region_sbqj_enih
        , _acomputed_region_7mpf_4k6g
        /* dlt fields */
        , _dlt_load_id
        , _dlt_id

      from read_parquet('s3://proj-renegade/nyc_open_data/nyc_311_service_requests/1737131049.359875.2421389fb8.parquet')

)

, final as (

    select
        /* Primary key */
        unique_key

        /* Dates and times */
        , created_date::date as created_date
        , closed_date::date as closed_date
        , due_date::date as due_date
        , resolution_action_updated_date::date as resolution_action_updated_date

        /* Attributes */
        , agency
        , agency_name
        , complaint_type
        , descriptor
        , resolution_description 
        , status

        /* Attributions - location-related */
        , location_type
        , incident_zip
        , incident_address
        , street_name
        , cross_street_1
        , cross_street_2
        , intersection_street_1
        , intersection_street_2 
        , address_type
        , city 
        , community_board
        , bbl
        , borough
        , x_coordinate_state_plane
        , y_coordinate_state_plane
        , latitude::decimal(9,6) as latitude
        , longitude::decimal(9,6) as longitude
        , location__latitude::decimal(9,6) as location__latitude
        , location__longitude::decimal(9,6) as location__longitude
        , location__human_address
        , _acomputed_region_efsh_h5xi
        , _acomputed_region_f5dn_yrer
        , _acomputed_region_yeji_bk3q
        , _acomputed_region_92fq_4b7q
        , _acomputed_region_sbqj_enih
        , _acomputed_region_7mpf_4k6g

        /* Attributes - specific for types of incidents */
        , facility_type
        , landmark
        , park_facility_name
        , park_borough
        , vehicle_type
        , taxi_company_borough
        , taxi_pick_up_location
        , bridge_highway_name
        , bridge_highway_direction
        , road_ramp
        , bridge_highway_segment

        /* Metadata */
        , open_data_channel_type
        , _dlt_id
        , _dlt_load_id

    from renamed

)

select * from final
