{{ config(materialized='view') }}

select
    md5(concat_ws(
        '||',
        "PATIENT",
        "ENCOUNTER",
        "CODE",
        "DATE",
        "VALUE"
    )) as observation_id,
    nullif("DATE", '')::timestamp as observation_ts,
    nullif("DATE", '')::timestamp::date as observation_date,
    "PATIENT"::text as patient_id,
    "ENCOUNTER"::text as encounter_id,
    "CATEGORY"::text as observation_category,
    "CODE"::text as observation_code,
    "DESCRIPTION"::text as observation_description,
    "VALUE"::text as observation_value,
    "UNITS"::text as observation_units,
    "TYPE"::text as observation_type
from {{ source('synthea', 'observations') }}