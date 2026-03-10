{{
    config(
        materialized='incremental',
        unique_key='medication_event_id'
    )
}}

with base as (

    select *
    from {{ ref('stg_medications') }}

    {% if is_incremental() %}
      where medication_start_date >= (
          select coalesce(max(medication_start_date), '1900-01-01'::date)
          from {{ this }}
      )
    {% endif %}

),

final as (

    select
        medication_event_id,
        patient_id,
        encounter_id,
        payer_id,
        medication_start_date,
        medication_end_date,
        is_active_medication,
        medication_duration_days,
        medication_code,
        medication_description,
        reason_code,
        reason_description,
        dispense_count,
        base_cost,
        payer_coverage,
        total_cost,
        patient_out_of_pocket_cost
    from base

)

select * from final