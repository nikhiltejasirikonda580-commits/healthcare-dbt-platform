{{ config(materialized='view') }}

with base as (

    select
        "PATIENT"::text as patient_id,
        "MEMBERID"::text as member_id,
        "PAYER"::text as payer_id,
        "SECONDARY_PAYER"::text as secondary_payer_id,
        "PLAN_OWNERSHIP"::text as plan_ownership,
        "OWNER_NAME"::text as owner_name,
        "START_DATE"::text as raw_start_date,
        "END_DATE"::text as raw_end_date
    from {{ source('synthea', 'payer_transitions') }}

),

final as (

    select
        md5(concat_ws(
            '||',
            patient_id,
            member_id,
            payer_id,
            secondary_payer_id,
            raw_start_date
        )) as patient_payer_transition_id,

        patient_id,
        member_id,

        case
            when raw_start_date is null or raw_start_date = '' then null
            else split_part(raw_start_date, 'T', 1)::date
        end as coverage_start_date,

        case
            when raw_end_date is null or raw_end_date = '' then null
            when raw_end_date like '292278994%' then null
            else split_part(raw_end_date, 'T', 1)::date
        end as coverage_end_date,

        payer_id,
        secondary_payer_id,
        plan_ownership,
        owner_name,

        case
            when raw_end_date is null or raw_end_date = '' then true
            when raw_end_date like '292278994%' then true
            when split_part(raw_end_date, 'T', 1)::date >= current_date then true
            else false
        end as is_current_coverage,

        case
            when raw_start_date is not null
            and raw_start_date <> ''
            and raw_end_date is not null
            and raw_end_date <> ''
            and raw_end_date not like '292278994%'
            and split_part(raw_end_date, 'T', 1)::date >= split_part(raw_start_date, 'T', 1)::date
            then split_part(raw_end_date, 'T', 1)::date - split_part(raw_start_date, 'T', 1)::date
            else null
        end as coverage_duration_days

    from base

)

select * from final