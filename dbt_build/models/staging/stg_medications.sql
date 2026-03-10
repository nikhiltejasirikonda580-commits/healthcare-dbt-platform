{{ config(materialized='view') }}

select
    md5(concat_ws(
        '||',
        coalesce("PATIENT", ''),
        coalesce("ENCOUNTER", ''),
        coalesce("PAYER", ''),
        coalesce("CODE", ''),
        coalesce("START", ''),
        coalesce("STOP", ''),
        coalesce("DESCRIPTION", ''),
        coalesce("REASONCODE", ''),
        coalesce("TOTALCOST", '')
    )) as medication_event_id,
    nullif("START", '')::date as medication_start_date,
    nullif("STOP", '')::date as medication_end_date,
    "PATIENT"::text as patient_id,
    "PAYER"::text as payer_id,
    "ENCOUNTER"::text as encounter_id,
    "CODE"::text as medication_code,
    "DESCRIPTION"::text as medication_description,
    nullif("BASE_COST", '')::numeric as base_cost,
    nullif("PAYER_COVERAGE", '')::numeric as payer_coverage,
    nullif("DISPENSES", '')::int as dispense_count,
    nullif("TOTALCOST", '')::numeric as total_cost,
    "REASONCODE"::text as reason_code,
    "REASONDESCRIPTION"::text as reason_description,
    case
        when nullif("STOP", '') is null or nullif("STOP", '')::date >= current_date then true
        else false
    end as is_active_medication,
    case
        when nullif("START", '') is not null and nullif("STOP", '') is not null
            then (nullif("STOP", '')::date - nullif("START", '')::date)
        else null
    end as medication_duration_days,
    coalesce(nullif("TOTALCOST", '')::numeric, 0) - coalesce(nullif("PAYER_COVERAGE", '')::numeric, 0) as patient_out_of_pocket_cost
from {{ source('synthea', 'medications') }}