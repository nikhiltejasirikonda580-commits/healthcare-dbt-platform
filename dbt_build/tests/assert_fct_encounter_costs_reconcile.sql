select *
from {{ ref('fct_encounter') }}
where abs(
    coalesce(total_claim_cost, 0)
    - coalesce(payer_coverage, 0)
    - coalesce(patient_liability_amount, 0)
) > 0.01