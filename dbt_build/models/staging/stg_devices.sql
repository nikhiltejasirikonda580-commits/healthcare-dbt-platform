{{ config(materialized='view') }}

select
    md5(concat_ws(
        '||',
        "PATIENT",
        "ENCOUNTER",
        "CODE",
        "START",
        "UDI"
    )) as device_event_id,
    nullif("START", '')::date as device_start_date,
    nullif("STOP", '')::date as device_end_date,
    "PATIENT"::text as patient_id,
    "ENCOUNTER"::text as encounter_id,
    "CODE"::text as device_code,
    "DESCRIPTION"::text as device_description,
    "UDI"::text as unique_device_identifier
from {{ source('synthea', 'devices') }}