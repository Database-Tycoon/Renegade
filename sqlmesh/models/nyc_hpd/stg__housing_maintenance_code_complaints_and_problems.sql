MODEL (
  name staging.stg__housing_maintenance_code_complaints_and_problems,
  kind full, # revisit, unsure if compound time column can be used 
  cron '@daily',
  grain unique_key,
  description 'Each row is a problem reported by the complainant to the Department of Housing Preservation and Development (HPD)',
  audits (
    not_null(columns := (unique_key)),
    unique_values(columns := (unique_key))
  ),
  column_descriptions (
    receiveddate='Date when the complaint was received',
    problemid='Unique identifier of this problem',
    complaintid='Unique identifier of the complaint this problem is associated with',
    buildingid='Unique identifier given to a building record',
    borough='Complaint borough, example values: Manhattan, Bronx, Brooklyn',
    housenumber='Complaint house number',
    streetname='Complaint street name',
    zip='Complaint zip code',
    block='Number assigned by the NYC Dept of Finance identifying the tax block the lot is on',
    lot='Unique number assigned by the NYC Dept of Finance within a Block identifying a lot',
    apartment='Number of the unit or apartment in a building',
    communityboard='Unique number identifying a Community District/Board, which is a political geographical area within a borough of the City of NY, values 1-18',
    unittype='Type of space where the problem was reported, example values: Apartment, Building, Public area',
    spacetype='Type of space where the problem was reported',
    type='Code indicating the problem type, example values: Emergency, Hazardous, Non emergency',
    majorcategory='The major category of the problem',
    minorcategory='The minor category of the problem',
    problemcode='The problem code',
    complaintstatus='The status of the complaint, example values: Close, Open',
    complaintstatusdate='Date when the complaint status was updated',
    problemstatus='The status of the problem',
    problemstatusdate='Date when the problem status was updated',
    statusdescription='Status description',
    problemduplicateflag='Duplicate complaint Indicator',
    complaintanonymousflag='Anonymous complaint Indicator',
    unique_key='Unique identifier of a Service Request (SR) in the open data set. Links to the to the open dataset 311 Service Requests from 2010 to Present'
    )
);

with historical as (
    /* this file has records prior to Feb 2025
       TODO need to create a mechanism to union historical to newly loaded incremental files */

    select *
    from read_parquet('s3://proj-renegade/dlt/landing/nyc_open_data/hpd_complaints/historical/loaded_on_2025_02_08/1738986252.467247.df5c3f1fc6.parquet')

)

, renamed as (

    select
        ReceivedDate
        ProblemID
        ComplaintID
        BuildingID
        Borough
        HouseNumber
        StreetName
        Zip
        Block
        Lot
        Apartment
        CommunityBoard
        UnitType
        SpaceType
        Type
        MajorCategory
        MinorCategory
        ProblemCode
        ComplaintStatus
        ComplaintStatusDate
        ProblemStatus
        ProblemStatusDate
        StatusDescription
        ProblemDuplicateFlag
        ComplaintAnonymousFlag
        Unique Key

    from historical

)

, reordered as (

)

select * from reordered
