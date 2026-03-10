{{ config(materialized='table') }}

with condition_counts as (

    select
        patient_id,
        count(*) as total_condition_records,
        count(distinct condition_code) as distinct_condition_count,
        sum(case when is_active_condition then 1 else 0 end) as active_condition_count
    from {{ ref('fct_condition') }}
    group by 1

),

encounter_summary as (

    select
        patient_id,
        count(*) as total_encounters,
        sum(case when is_inpatient_flag then 1 else 0 end) as inpatient_encounter_count,
        sum(case when is_emergency_flag then 1 else 0 end) as emergency_encounter_count,
        sum(coalesce(total_claim_cost, 0)) as total_claim_cost
    from {{ ref('fct_encounter') }}
    group by 1

),

patient_lookup as (

    select
        patient_id,
        patient_full_name,
        current_age,
        age_band,
        gender,
        race,
        ethnicity,
        state
    from {{ ref('dim_patient') }}

),

final as (

    select
        p.patient_id,
        p.patient_full_name,
        p.current_age,
        p.age_band,
        p.gender,
        p.race,
        p.ethnicity,
        p.state,
        coalesce(c.total_condition_records, 0) as total_condition_records,
        coalesce(c.distinct_condition_count, 0) as distinct_condition_count,
        coalesce(c.active_condition_count, 0) as active_condition_count,
        coalesce(e.total_encounters, 0) as total_encounters,
        coalesce(e.inpatient_encounter_count, 0) as inpatient_encounter_count,
        coalesce(e.emergency_encounter_count, 0) as emergency_encounter_count,
        coalesce(e.total_claim_cost, 0) as total_claim_cost,
        case
            when coalesce(c.active_condition_count, 0) >= 5 then 'Very High'
            when coalesce(c.active_condition_count, 0) >= 3 then 'High'
            when coalesce(c.active_condition_count, 0) >= 1 then 'Moderate'
            else 'Low'
        end as chronic_burden_segment
    from patient_lookup p
    left join condition_counts c on p.patient_id = c.patient_id
    left join encounter_summary e on p.patient_id = e.patient_id

)

select * from final