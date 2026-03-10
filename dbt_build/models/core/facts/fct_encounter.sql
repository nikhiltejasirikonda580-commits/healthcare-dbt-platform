{{
    config(
        materialized='incremental',
        unique_key='encounter_id'
    )
}}

with base as (

    select *
    from {{ ref('stg_encounters') }}

    {% if is_incremental() %}
      where encounter_start_ts >= (
          select coalesce(max(encounter_start_ts), '1900-01-01'::timestamp)
          from {{ this }}
      )
    {% endif %}

),

final as (

    select
        encounter_id,
        patient_id,
        provider_id,
        organization_id,
        payer_id,
        encounter_start_ts,
        encounter_end_ts,
        encounter_date,
        encounter_month,
        encounter_class,
        encounter_code,
        encounter_description,
        reason_code,
        reason_description,
        encounter_duration_minutes,
        is_inpatient_flag,
        is_emergency_flag,
        is_ambulatory_flag,
        base_encounter_cost,
        total_claim_cost,
        payer_coverage,
        coalesce(total_claim_cost, 0) - coalesce(payer_coverage, 0) as patient_liability_amount
    from base

)

select * from final