{{ config(materialized='view') }}

select
    "Id"::text as organization_id,
    "NAME"::text as organization_name,
    "ADDRESS"::text as address,
    "CITY"::text as city,
    "STATE"::text as state,
    "ZIP"::text as zip_code,
    nullif("LAT", '')::numeric as latitude,
    nullif("LON", '')::numeric as longitude,
    "PHONE"::text as phone,
    nullif("REVENUE", '')::numeric as revenue,
    nullif("UTILIZATION", '')::int as utilization
from {{ source('synthea', 'organizations') }}