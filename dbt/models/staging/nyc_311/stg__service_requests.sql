{{
    config(
        materialized = 'incremental',
        table_format = 'iceberg',
        unique_key = 'unique_key',
        description = 'One row per service request to 311, from NYC Open Data Project'
    )
}}

/*
  This model is intended to stage and do basic cleaning/casting on the raw API data
  Some columns were missing from spec (location), need to confirm.
*/

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

      from {{ source('nyc_open_data', 'nyc_311_service_requests') }}

)

, final as (

    select
        /* Primary key */
        unique_key

        /* Dates and times */
        , date(created_date) as created_date
        , date(closed_date) as closed_date
        , date(due_date) as due_date
        , date(resolution_action_updated_date) as resolution_action_updated_date

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
        , cast(latitude as decimal(9,6)) as latitude
        , cast(longitude as decimal(9,6)) as longitude
        , cast(location__latitude as decimal(9,6)) as location__latitude
        , cast(location__longitude as decimal(9,6)) as location__longitude
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
{% if is_incremental() %}
  where created_date > (select max(created_date) from {{ this }})
{% endif %} 
