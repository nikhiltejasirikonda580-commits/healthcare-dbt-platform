{{
    config(
        materialized='incremental',
        unique_key='condition_occurrence_id'
    )
}}

with base as (

    select *
    from {{ ref('stg_conditions') }}

    {% if is_incremental() %}
      where condition_start_date >= (
          select coalesce(max(condition_start_date), '1900-01-01'::date)
          from {{ this }}
      )
    {% endif %}

),

final as (

    select
        condition_occurrence_id,
        patient_id,
        encounter_id,
        condition_start_date,
        condition_end_date,
        is_active_condition,
        condition_duration_days,
        condition_code_system,
        condition_code,
        condition_description
    from base

)

select * from final