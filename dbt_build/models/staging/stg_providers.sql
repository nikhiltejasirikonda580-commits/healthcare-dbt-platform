{{ config(materialized='view') }}

select
    "Id"::text as provider_id,
    "ORGANIZATION"::text as organization_id,
    "NAME"::text as provider_name,
    "GENDER"::text as provider_gender,
    "SPECIALITY"::text as specialty,
    "ADDRESS"::text as address,
    "CITY"::text as city,
    "STATE"::text as state,
    "ZIP"::text as zip_code,
    nullif("LAT", '')::numeric as latitude,
    nullif("LON", '')::numeric as longitude,
    nullif("ENCOUNTERS", '')::int as source_encounter_count,
    nullif("PROCEDURES", '')::int as source_procedure_count
from {{ source('synthea', 'providers') }}