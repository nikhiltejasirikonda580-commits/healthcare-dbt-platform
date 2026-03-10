{% snapshot patient_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='patient_id',
        strategy='check',
        check_cols=[
            'patient_full_name',
            'birth_date',
            'death_date',
            'marital_status',
            'race',
            'ethnicity',
            'gender',
            'city',
            'state',
            'county',
            'zip_code',
            'income',
            'healthcare_expenses',
            'healthcare_coverage'
        ],
        invalidate_hard_deletes=True
    )
}}

select
    patient_id,
    patient_full_name,
    birth_date,
    death_date,
    is_deceased,
    current_age,
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
    healthcare_coverage
from {{ ref('stg_patients') }}

{% endsnapshot %}