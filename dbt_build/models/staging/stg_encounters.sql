{{ config(materialized='view') }}

select
    "Id"::text as encounter_id,
    nullif("START", '')::timestamp as encounter_start_ts,
    nullif("STOP", '')::timestamp as encounter_end_ts,
    "PATIENT"::text as patient_id,
    "ORGANIZATION"::text as organization_id,
    "PROVIDER"::text as provider_id,
    "PAYER"::text as payer_id,
    "ENCOUNTERCLASS"::text as encounter_class,
    "CODE"::text as encounter_code,
    "DESCRIPTION"::text as encounter_description,
    nullif("BASE_ENCOUNTER_COST", '')::numeric as base_encounter_cost,
    nullif("TOTAL_CLAIM_COST", '')::numeric as total_claim_cost,
    nullif("PAYER_COVERAGE", '')::numeric as payer_coverage,
    "REASONCODE"::text as reason_code,
    "REASONDESCRIPTION"::text as reason_description,
    nullif("START", '')::timestamp::date as encounter_date,
    date_trunc('month', nullif("START", '')::timestamp)::date as encounter_month,
    case
        when nullif("START", '') is not null and nullif("STOP", '') is not null
            then extract(epoch from (nullif("STOP", '')::timestamp - nullif("START", '')::timestamp)) / 60.0
        else null
    end as encounter_duration_minutes,
    case when upper("ENCOUNTERCLASS") = 'INPATIENT' then true else false end as is_inpatient_flag,
    case when upper("ENCOUNTERCLASS") = 'EMERGENCY' then true else false end as is_emergency_flag,
    case when upper("ENCOUNTERCLASS") = 'AMBULATORY' then true else false end as is_ambulatory_flag
from {{ source('synthea', 'encounters') }}