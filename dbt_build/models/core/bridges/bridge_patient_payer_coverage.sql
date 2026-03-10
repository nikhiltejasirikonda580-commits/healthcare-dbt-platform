{{ config(materialized='table') }}

with base as (

    select *
    from {{ ref('stg_payer_transitions') }}

),

final as (

    select
        patient_payer_transition_id as patient_payer_coverage_sk,
        patient_id,
        payer_id,
        secondary_payer_id,
        member_id,
        coverage_start_date,
        coverage_end_date,
        is_current_coverage,
        coverage_duration_days,
        plan_ownership,
        owner_name
    from base

)

select * from final