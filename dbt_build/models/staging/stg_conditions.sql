{{ config(materialized='view') }}

select
    md5(concat_ws(
        '||',
        "PATIENT",
        "ENCOUNTER",
        "SYSTEM",
        "CODE",
        "START"
    )) as condition_occurrence_id,
    nullif("START", '')::date as condition_start_date,
    nullif("STOP", '')::date as condition_end_date,
    "PATIENT"::text as patient_id,
    "ENCOUNTER"::text as encounter_id,
    "SYSTEM"::text as condition_code_system,
    "CODE"::text as condition_code,
    "DESCRIPTION"::text as condition_description,
    case
        when nullif("STOP", '') is null or nullif("STOP", '')::date >= current_date then true
        else false
    end as is_active_condition,
    case
        when nullif("START", '') is not null and nullif("STOP", '') is not null
            then (nullif("STOP", '')::date - nullif("START", '')::date)
        else null
    end as condition_duration_days
from {{ source('synthea', 'conditions') }}