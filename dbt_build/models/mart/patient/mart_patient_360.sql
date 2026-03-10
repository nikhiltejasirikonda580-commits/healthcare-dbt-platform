{{ config(materialized='table') }}

with patient_base as (

    select *
    from {{ ref('dim_patient') }}

),

encounter_summary as (

    select
        patient_id,
        count(*) as total_encounters,
        count(distinct encounter_month) as active_months_with_encounters,
        min(encounter_date) as first_encounter_date,
        max(encounter_date) as latest_encounter_date,
        sum(coalesce(total_claim_cost, 0)) as total_encounter_claim_cost,
        sum(coalesce(payer_coverage, 0)) as total_encounter_payer_coverage,
        sum(coalesce(patient_liability_amount, 0)) as total_encounter_patient_liability,
        sum(case when is_inpatient_flag then 1 else 0 end) as inpatient_encounter_count,
        sum(case when is_emergency_flag then 1 else 0 end) as emergency_encounter_count,
        sum(case when is_ambulatory_flag then 1 else 0 end) as ambulatory_encounter_count
    from {{ ref('fct_encounter') }}
    group by 1

),

condition_summary as (

    select
        patient_id,
        count(*) as total_condition_records,
        count(distinct condition_code) as distinct_condition_count,
        sum(case when is_active_condition then 1 else 0 end) as active_condition_count
    from {{ ref('fct_condition') }}
    group by 1

),

medication_summary as (

    select
        patient_id,
        count(*) as total_medication_records,
        count(distinct medication_code) as distinct_medication_count,
        sum(case when is_active_medication then 1 else 0 end) as active_medication_count,
        sum(coalesce(total_cost, 0)) as total_medication_cost,
        sum(coalesce(payer_coverage, 0)) as total_medication_payer_coverage,
        sum(coalesce(patient_out_of_pocket_cost, 0)) as total_medication_out_of_pocket_cost
    from {{ ref('fct_medication') }}
    group by 1

),

claim_summary as (

    select
        patient_id,
        count(*) as total_claim_line_count,
        count(distinct claim_id) as distinct_claim_count,
        sum(coalesce(transaction_amount, 0)) as total_claim_transaction_amount,
        sum(coalesce(payment_amount, 0)) as total_claim_payment_amount,
        sum(coalesce(adjustment_amount, 0)) as total_claim_adjustment_amount,
        sum(coalesce(outstanding_amount, 0)) as total_claim_outstanding_amount
    from {{ ref('fct_claim_line') }}
    group by 1

),

latest_coverage as (

    select *
    from (
        select
            patient_id,
            payer_id,
            secondary_payer_id,
            member_id,
            coverage_start_date,
            coverage_end_date,
            is_current_coverage,
            row_number() over (
                partition by patient_id
                order by
                    is_current_coverage desc,
                    coverage_start_date desc nulls last
            ) as rn
        from {{ ref('bridge_patient_payer_coverage') }}
    ) x
    where rn = 1

),

payer_lookup as (

    select
        payer_id,
        payer_name,
        ownership_type
    from {{ ref('dim_payer') }}

),

final as (

    select
        p.patient_id,
        p.patient_full_name,
        p.birth_date,
        p.death_date,
        p.is_deceased,
        p.current_age,
        p.age_band,
        p.gender,
        p.race,
        p.ethnicity,
        p.marital_status,
        p.city,
        p.state,
        p.county,
        p.zip_code,
        p.income,
        p.healthcare_expenses,
        p.healthcare_coverage,

        coalesce(e.total_encounters, 0) as total_encounters,
        coalesce(e.active_months_with_encounters, 0) as active_months_with_encounters,
        e.first_encounter_date,
        e.latest_encounter_date,
        coalesce(e.total_encounter_claim_cost, 0) as total_encounter_claim_cost,
        coalesce(e.total_encounter_payer_coverage, 0) as total_encounter_payer_coverage,
        coalesce(e.total_encounter_patient_liability, 0) as total_encounter_patient_liability,
        coalesce(e.inpatient_encounter_count, 0) as inpatient_encounter_count,
        coalesce(e.emergency_encounter_count, 0) as emergency_encounter_count,
        coalesce(e.ambulatory_encounter_count, 0) as ambulatory_encounter_count,

        coalesce(c.total_condition_records, 0) as total_condition_records,
        coalesce(c.distinct_condition_count, 0) as distinct_condition_count,
        coalesce(c.active_condition_count, 0) as active_condition_count,

        coalesce(m.total_medication_records, 0) as total_medication_records,
        coalesce(m.distinct_medication_count, 0) as distinct_medication_count,
        coalesce(m.active_medication_count, 0) as active_medication_count,
        coalesce(m.total_medication_cost, 0) as total_medication_cost,
        coalesce(m.total_medication_payer_coverage, 0) as total_medication_payer_coverage,
        coalesce(m.total_medication_out_of_pocket_cost, 0) as total_medication_out_of_pocket_cost,

        coalesce(cl.total_claim_line_count, 0) as total_claim_line_count,
        coalesce(cl.distinct_claim_count, 0) as distinct_claim_count,
        coalesce(cl.total_claim_transaction_amount, 0) as total_claim_transaction_amount,
        coalesce(cl.total_claim_payment_amount, 0) as total_claim_payment_amount,
        coalesce(cl.total_claim_adjustment_amount, 0) as total_claim_adjustment_amount,
        coalesce(cl.total_claim_outstanding_amount, 0) as total_claim_outstanding_amount,

        lc.payer_id as latest_payer_id,
        pl.payer_name as latest_payer_name,
        pl.ownership_type as latest_payer_ownership_type,
        lc.secondary_payer_id as latest_secondary_payer_id,
        lc.member_id as latest_member_id,
        lc.coverage_start_date as latest_coverage_start_date,
        lc.coverage_end_date as latest_coverage_end_date,
        lc.is_current_coverage,

        case
            when coalesce(c.active_condition_count, 0) >= 5 then 'Very High'
            when coalesce(c.active_condition_count, 0) >= 3 then 'High'
            when coalesce(c.active_condition_count, 0) >= 1 then 'Moderate'
            else 'Low'
        end as chronic_burden_segment

    from patient_base p
    left join encounter_summary e on p.patient_id = e.patient_id
    left join condition_summary c on p.patient_id = c.patient_id
    left join medication_summary m on p.patient_id = m.patient_id
    left join claim_summary cl on p.patient_id = cl.patient_id
    left join latest_coverage lc on p.patient_id = lc.patient_id
    left join payer_lookup pl on lc.payer_id = pl.payer_id

)

select * from final