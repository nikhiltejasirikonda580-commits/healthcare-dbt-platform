{% snapshot payer_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='payer_id',
        strategy='check',
        check_cols=[
            'payer_name',
            'ownership_type',
            'state_headquartered',
            'amount_covered',
            'amount_uncovered',
            'covered_encounters',
            'uncovered_encounters',
            'covered_medications',
            'uncovered_medications',
            'covered_procedures',
            'uncovered_procedures',
            'covered_immunizations',
            'uncovered_immunizations',
            'unique_customers',
            'member_months'
        ],
        invalidate_hard_deletes=True
    )
}}

select
    payer_id,
    payer_name,
    ownership_type,
    address,
    city,
    state_headquartered,
    zip_code,
    phone,
    amount_covered,
    amount_uncovered,
    revenue,
    covered_encounters,
    uncovered_encounters,
    covered_medications,
    uncovered_medications,
    covered_procedures,
    uncovered_procedures,
    covered_immunizations,
    uncovered_immunizations,
    unique_customers,
    qols_avg,
    member_months
from {{ ref('stg_payers') }}

{% endsnapshot %}