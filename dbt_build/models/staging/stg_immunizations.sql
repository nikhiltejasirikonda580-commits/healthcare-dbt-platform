{{ config(materialized='view') }}

select
    md5(concat_ws(
        '||',
        "PATIENT",
        "ENCOUNTER",
        "CODE",
        "DATE"
    )) as immunization_id,
    nullif("DATE", '')::timestamp as immunization_ts,
    nullif("DATE", '')::timestamp::date as immunization_date,
    "PATIENT"::text as patient_id,
    "ENCOUNTER"::text as encounter_id,
    "CODE"::text as immunization_code,
    "DESCRIPTION"::text as immunization_description,
    nullif("BASE_COST", '')::numeric as base_cost
from {{ source('synthea', 'immunizations') }}