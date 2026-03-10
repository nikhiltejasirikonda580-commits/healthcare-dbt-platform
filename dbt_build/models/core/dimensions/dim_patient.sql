{{ config(materialized='table') }}

with current_records as (

    select *
    from {{ ref('patient_snapshot') }}
    where dbt_valid_to is null

),

final as (

    select
        patient_id,
        patient_full_name,
        birth_date,
        death_date,
        is_deceased,
        current_age,
        case
            when current_age < 18 then '0-17'
            when current_age between 18 and 34 then '18-34'
            when current_age between 35 and 49 then '35-49'
            when current_age between 50 and 64 then '50-64'
            when current_age >= 65 then '65+'
            else 'Unknown'
        end as age_band,
        gender,
        race,
        ethnicity,
        marital_status,
        city,
        state,
        county,
        zip_code,
        income,
        healthcare_expenses,
        healthcare_coverage,
        dbt_valid_from,
        dbt_valid_to
    from current_records

)

select * from final