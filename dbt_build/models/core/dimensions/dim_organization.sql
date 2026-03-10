{{ config(materialized='table') }}

select
    organization_id,
    organization_name,
    address,
    city,
    state,
    zip_code,
    latitude,
    longitude,
    phone,
    revenue,
    utilization
from {{ ref('organization_snapshot') }}
where dbt_valid_to is null