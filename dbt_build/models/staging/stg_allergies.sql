{{ config(materialized='view') }}

select
    md5(concat_ws(
        '||',
        "PATIENT",
        "ENCOUNTER",
        "CODE",
        "START"
    )) as allergy_event_id,
    nullif("START", '')::date as allergy_start_date,
    nullif("STOP", '')::date as allergy_end_date,
    "PATIENT"::text as patient_id,
    "ENCOUNTER"::text as encounter_id,
    "CODE"::text as allergy_code,
    "SYSTEM"::text as allergy_code_system,
    "DESCRIPTION"::text as allergy_description,
    "TYPE"::text as allergy_type,
    "CATEGORY"::text as allergy_category,
    "REACTION1"::text as reaction_1_code,
    "DESCRIPTION1"::text as reaction_1_description,
    "SEVERITY1"::text as reaction_1_severity,
    "REACTION2"::text as reaction_2_code,
    "DESCRIPTION2"::text as reaction_2_description,
    "SEVERITY2"::text as reaction_2_severity,
    case
        when nullif("STOP", '') is null or nullif("STOP", '')::date >= current_date then true
        else false
    end as is_active_allergy
from {{ source('synthea', 'allergies') }}