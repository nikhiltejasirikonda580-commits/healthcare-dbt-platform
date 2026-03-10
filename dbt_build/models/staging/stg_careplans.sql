{{ config(materialized='view') }}

select
    "Id"::text as careplan_id,
    nullif("START", '')::date as careplan_start_date,
    nullif("STOP", '')::date as careplan_end_date,
    "PATIENT"::text as patient_id,
    "ENCOUNTER"::text as encounter_id,
    "CODE"::text as careplan_code,
    "DESCRIPTION"::text as careplan_description,
    "REASONCODE"::text as reason_code,
    "REASONDESCRIPTION"::text as reason_description,
    case
        when nullif("STOP", '') is null or nullif("STOP", '')::date >= current_date then true
        else false
    end as is_active_careplan
from {{ source('synthea', 'careplans') }}