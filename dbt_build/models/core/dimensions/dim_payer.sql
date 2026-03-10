{{ config(materialized='table') }}

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
from {{ ref('payer_snapshot') }}
where dbt_valid_to is null