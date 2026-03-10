{{ config(materialized='view') }}

select
    md5(concat_ws(
        '||',
        "PATIENT",
        "ENCOUNTER",
        "CODE",
        "DATE"
    )) as supply_event_id,
    nullif("DATE", '')::timestamp as supply_ts,
    nullif("DATE", '')::timestamp::date as supply_date,
    "PATIENT"::text as patient_id,
    "ENCOUNTER"::text as encounter_id,
    "CODE"::text as supply_code,
    "DESCRIPTION"::text as supply_description,
    nullif("QUANTITY", '')::numeric as quantity
from {{ source('synthea', 'supplies') }}