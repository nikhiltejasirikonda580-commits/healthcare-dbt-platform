{{ config(materialized='table') }}

select
    provider_id,
    organization_id,
    provider_name,
    provider_gender,
    specialty,
    city,
    state,
    zip_code,
    latitude,
    longitude,
    source_encounter_count,
    source_procedure_count,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('provider_snapshot') }}
where dbt_valid_to is null