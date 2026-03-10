{{ config(materialized='table') }}

with encounter_rollup as (

    select
        encounter_month,
        organization_id,
        encounter_class,
        count(*) as encounter_count,
        count(distinct patient_id) as unique_patient_count,
        count(distinct provider_id) as unique_provider_count,
        sum(coalesce(total_claim_cost, 0)) as total_claim_cost,
        sum(coalesce(payer_coverage, 0)) as total_payer_coverage,
        sum(coalesce(patient_liability_amount, 0)) as total_patient_liability,
        avg(coalesce(total_claim_cost, 0)) as avg_claim_cost_per_encounter,
        avg(coalesce(encounter_duration_minutes, 0)) as avg_encounter_duration_minutes,
        sum(case when is_inpatient_flag then 1 else 0 end) as inpatient_encounter_count,
        sum(case when is_emergency_flag then 1 else 0 end) as emergency_encounter_count,
        sum(case when is_ambulatory_flag then 1 else 0 end) as ambulatory_encounter_count
    from {{ ref('fct_encounter') }}
    group by 1, 2, 3

),

org_lookup as (

    select
        organization_id,
        organization_name,
        city,
        state
    from {{ ref('dim_organization') }}

),

final as (

    select
        md5(concat_ws(
            '||',
            encounter_rollup.encounter_month::text,
            encounter_rollup.organization_id,
            encounter_rollup.encounter_class
        )) as utilization_month_sk,
        encounter_rollup.encounter_month,
        encounter_rollup.organization_id,
        org_lookup.organization_name,
        org_lookup.city as organization_city,
        org_lookup.state as organization_state,
        encounter_rollup.encounter_class,
        encounter_rollup.encounter_count,
        encounter_rollup.unique_patient_count,
        encounter_rollup.unique_provider_count,
        encounter_rollup.total_claim_cost,
        encounter_rollup.total_payer_coverage,
        encounter_rollup.total_patient_liability,
        encounter_rollup.avg_claim_cost_per_encounter,
        encounter_rollup.avg_encounter_duration_minutes,
        encounter_rollup.inpatient_encounter_count,
        encounter_rollup.emergency_encounter_count,
        encounter_rollup.ambulatory_encounter_count
    from encounter_rollup
    left join org_lookup
      on encounter_rollup.organization_id = org_lookup.organization_id

)

select * from final